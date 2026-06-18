# pve-vm-module

Terraform configuration that provisions a single Proxmox VE VM pre-configured for [Talos Linux](https://www.talos.dev/). The VM boots from a Talos nocloud ISO in maintenance mode, after which you apply a machine config with `talosctl`.

State is stored in a MinIO-backed S3-compatible bucket. Deployments are driven by GitHub Actions workflows that run on a self-hosted runner with network access to the homelab.

## Repository layout

```
.
├── variables.tf          # Root-level input variables (Proxmox connection + VM config)
├── providers.tf          # Provider + S3/MinIO backend configuration
├── resources-vm.tf       # Wires root variables into the pve-vm child module
├── outputs.tf            # Re-exports module outputs
├── input.tfvars          # Example/default var file committed to the repo
└── pve-vm/               # Reusable child module
    ├── variables-vm.tf
    ├── variables-talos-image.tf
    ├── resources-vm.tf   # proxmox_virtual_environment_vm resource
    ├── outputs.tf
    └── providers.tf      # Provider version constraint
```

## Prerequisites

| Requirement | Notes |
|---|---|
| Self-hosted GitHub runner | Must have network access to Proxmox and MinIO |
| Talos nocloud ISO | Upload to Proxmox manually as `talos-<version>-nocloud-amd64.iso` in the ISO datastore |
| MinIO bucket | Default: `terraform-state`, key `pve-vm/terraform.tfstate` |
| Proxmox API token | Needs VM create/delete permissions on the target node |

## GitHub Actions setup

### Repository variables

| Variable | Description |
|---|---|
| `TF_VERSION` | Terraform version to install (e.g. `1.15.0`) |
| `PVE_API_URL` | Proxmox API endpoint (e.g. `https://pve01.example.com:8006/`) |
| `PVE_TOKEN_ID` | Proxmox API token ID (e.g. `root@pam!terraform`) |
| `DESTROY_VM` | Set to `true` to allow the destroy workflow to proceed |

### Repository secrets

| Secret | Description |
|---|---|
| `PVE_TOKEN_SECRET` | Proxmox API token secret (UUID) |
| `MINIO_ACCESS_KEY` | MinIO access key for the state backend |
| `MINIO_SECRET_KEY` | MinIO secret key for the state backend |

### Environments

Two [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) with required reviewers act as manual approval gates:

| Environment | Used by |
|---|---|
| `apply-approval` | `terraform-deploy` workflow |
| `destroy-approval` | `terraform-destroy` workflow |

Configure reviewers at **Settings → Environments**.

## Workflows

### `terraform-plan`

Runs automatically on pull requests to `main` that touch `.tf`, `.tftpl`, `manifests/`, or workflow files. Also triggerable manually (`workflow_dispatch`) with an optional var file override.

Steps: `fmt` → `init` → `validate` → `plan`. The plan artifact is uploaded and retained for 7 days.

### `terraform-deploy`

Manual-only (`workflow_dispatch`). Runs plan → waits for `apply-approval` environment approval → applies the saved plan artifact.

Concurrent deploys are serialised via the `terraform-apply` concurrency group.

### `terraform-destroy`

Manual-only (`workflow_dispatch`). Requires the `DESTROY_VM` organisation variable to be set to `true` as an extra guard. Runs destroy plan → waits for `destroy-approval` environment approval → destroys infrastructure.

## Inputs

### Proxmox connection

| Variable | Type | Default | Description |
|---|---|---|---|
| `pve_api_url` | `string` | — | Proxmox VE API endpoint |
| `pve_token_id` | `string` | — | Proxmox API token ID |
| `pve_token_secret` | `string` | — | Proxmox API token secret |
| `pve_node` | `string` | `pve-nzxt` | Proxmox node to create the VM on |
| `pve_tls_insecure` | `bool` | `true` | Skip TLS verification (self-signed certs) |
| `pve_ssh_username` | `string` | `root` | SSH user for snippet uploads |

### VM identity

| Variable | Type | Default | Description |
|---|---|---|---|
| `vm_name` | `string` | — | VM name / hostname |
| `vmid` | `number` | — | Proxmox VMID |
| `vm_description` | `string` | `Talos VM — managed by Terraform` | Human-readable description |
| `tags` | `list(string)` | `["terraform", "talos"]` | Tags applied to the VM |

### VM sizing

| Variable | Type | Default | Description |
|---|---|---|---|
| `cpu` | `number` | `2` | vCPU cores |
| `memory` | `number` | `2048` | Memory in MiB |
| `disk_size` | `number` | `32` | Boot disk size in GiB |
| `cpu_type` | `string` | `host` | QEMU CPU type |

### Storage

| Variable | Type | Default | Description |
|---|---|---|---|
| `vm_datastore_id` | `string` | `local-lvm` | Datastore for the boot disk |
| `cloudinit_datastore_id` | `string` | `local-lvm` | Datastore for the cloud-init drive |
| `disk_interface` | `string` | `scsi0` | Disk bus/interface |
| `iso_datastore_id` | `string` | `local` | Datastore holding the Talos ISO |

### Networking

| Variable | Type | Default | Description |
|---|---|---|---|
| `network_bridge` | `string` | `vmbr0` | Proxmox bridge interface |
| `vlan_id` | `number` | `null` | Optional VLAN tag |
| `ip_address` | `string` | — | Static IPv4 address |
| `network_prefix` | `number` | `24` | Network prefix length |
| `gateway` | `string` | — | Default gateway |
| `dns_servers` | `list(string)` | `["1.1.1.1", "8.8.8.8"]` | DNS servers |

### Talos image

| Variable | Type | Default | Description |
|---|---|---|---|
| `talos_version` | `string` | `v1.9.2` | Talos version; must match the ISO filename on Proxmox |

## Outputs

| Output | Description |
|---|---|
| `vmid` | Proxmox VMID of the created VM |
| `name` | VM name |
| `ip_address` | Configured static IP address |
| `mac_address` | MAC address of the primary NIC |

## Usage

1. Upload the Talos nocloud ISO to your Proxmox ISO datastore:

   ```
   talos-v1.9.2-nocloud-amd64.iso
   ```

2. Copy `input.tfvars` and fill in the required values:

   ```hcl
   vm_name        = "talos-node-01"
   vmid           = 8000
   ip_address     = "10.10.20.20"
   network_prefix = 24
   gateway        = "10.10.20.1"
   dns_servers    = ["10.10.20.1", "1.1.1.1"]
   ```

3. Run the `terraform-deploy` workflow from **Actions → terraform-deploy → Run workflow**, or apply locally:

   ```bash
   terraform init
   terraform plan -var-file=input.tfvars
   terraform apply -var-file=input.tfvars
   ```

4. Once the VM is up, apply a Talos machine config:

   ```bash
   talosctl apply-config --insecure -n <ip_address> --file <machine.yaml>
   ```

## Provider

Uses [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest) `~> 0.100`.

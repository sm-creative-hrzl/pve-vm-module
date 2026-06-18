###############################################################################
# Variables — Proxmox Talos VM
###############################################################################

# --- Proxmox connection ------------------------------------------------------

variable "pve_api_url" {
  description = "Proxmox VE API endpoint, e.g. https://pve01.example.com:8006/"
  type        = string
}

variable "pve_token_id" {
  description = "Proxmox API token ID, e.g. root@pam!terraform"
  type        = string
  sensitive   = true
}

variable "pve_token_secret" {
  description = "Proxmox API token secret (UUID)."
  type        = string
  sensitive   = true
}

variable "pve_node" {
  description = "Name of the Proxmox node on which to create the VM."
  type        = string
  default     = "pve-nzxt"
}

variable "pve_tls_insecure" {
  description = "Skip TLS verification against the Proxmox API (homelabs often use self-signed certs)."
  type        = bool
  default     = true
}

variable "pve_ssh_username" {
  description = "SSH username the Proxmox provider uses for snippet uploads and host-side operations."
  type        = string
  default     = "root"
}

# --- VM identity -------------------------------------------------------------

variable "vm_name" {
  description = "VM name / hostname."
  type        = string
}

variable "vmid" {
  description = "Proxmox VMID."
  type        = number
}

variable "vm_description" {
  description = "Human-readable VM description."
  type        = string
  default     = "Talos VM — managed by Terraform"
}

variable "tags" {
  description = "Tags applied to the VM."
  type        = list(string)
  default     = ["terraform", "talos"]
}

# --- VM sizing ---------------------------------------------------------------

variable "cpu" {
  description = "vCPU cores."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Boot disk size in GiB."
  type        = number
  default     = 32
}

variable "cpu_type" {
  description = "QEMU CPU type. 'host' gives best performance; use a stable model for live migration."
  type        = string
  default     = "host"
}

# --- Storage -----------------------------------------------------------------

variable "vm_datastore_id" {
  description = "Proxmox datastore for the VM boot disk (e.g. local-lvm, local-zfs, ceph)."
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_datastore_id" {
  description = "Proxmox datastore that holds the cloud-init drive."
  type        = string
  default     = "local-lvm"
}

variable "disk_interface" {
  description = "Disk bus/interface for the VM boot disk (e.g. scsi0, virtio0)."
  type        = string
  default     = "scsi0"
}

variable "iso_datastore_id" {
  description = "Proxmox datastore for the downloaded Talos ISO. Must support 'iso' content (e.g. local), not block storage."
  type        = string
  default     = "local"
}

# --- Networking --------------------------------------------------------------

variable "network_bridge" {
  description = "Proxmox bridge interface the VM NIC attaches to."
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "Optional VLAN tag for the VM NIC. Set to null to disable tagging."
  type        = number
  default     = null
}

variable "ip_address" {
  description = "Static IPv4 address for the VM."
  type        = string
}

variable "network_prefix" {
  description = "Network prefix length (e.g. 24 for /24)."
  type        = number
  default     = 24
}

variable "gateway" {
  description = "Default gateway for the VM."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the VM."
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

# --- Talos -------------------------------------------------------------------

# variable "talos_version" {
#   description = "Talos Linux version (used to name the ISO and derive the download URL)."
#   type        = string
#   default     = "v1.9.2"
# }

# variable "talos_image_factory_schematic" {
#   description = "Talos Image Factory schematic ID. Default is the stock schematic (no system extensions); generate your own at https://factory.talos.dev."
#   type        = string
#   default     = "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
# }

# variable "talos_iso_url" {
#   description = "Override for the full Talos nocloud ISO download URL. When null it is derived from talos_image_factory_schematic + talos_version."
#   type        = string
#   default     = null
# }

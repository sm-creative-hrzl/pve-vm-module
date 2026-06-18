# --- VM identity -------------------------------------------------------------
vm_name = "talos-vm-test-01"
vmid    = 8000

# --- Networking --------------------------------------------------------------
network_bridge = "vmbr0"
ip_address     = "10.10.20.20"
network_prefix = 24
gateway        = "10.10.20.1"
dns_servers    = ["10.10.20.1", "1.1.1.1"]

###############################################################################
# Optional overrides — defaults are usually fine. Uncomment to tune.
###############################################################################
# pve_node                      = "pve-nzxt"
# talos_version                 = "v1.9.2"
# talos_image_factory_schematic = "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
# talos_iso_url                 = null
# iso_datastore_id              = "local"
# vm_datastore_id               = "local-lvm"
# cloudinit_datastore_id        = "local-lvm"
# disk_interface                = "scsi0"
# cpu                           = 2
# memory                        = 2048
# disk_size                     = 32
# cpu_type                      = "host"
# vlan_id                       = null
# pve_tls_insecure              = true
# pve_ssh_username              = "root"

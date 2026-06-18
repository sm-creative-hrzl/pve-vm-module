###############################################################################
# Proxmox Talos VM
#
# Downloads the Talos nocloud ISO to Proxmox once, then creates a single VM
# that boots from it into maintenance mode. From there a machine config can be
# applied with:
#   talosctl apply-config --insecure -n <ip_address> --file <machine.yaml>
###############################################################################

# locals {
#   talos_iso_url = coalesce(
#     var.talos_iso_url,
#     "https://factory.talos.dev/image/${var.talos_image_factory_schematic}/${var.talos_version}/nocloud-amd64.iso",
#   )
# }

# resource "proxmox_virtual_environment_download_file" "talos_iso" {
#   content_type = "iso"
#   datastore_id = var.iso_datastore_id
#   node_name    = var.pve_node

#   url       = local.talos_iso_url
#   file_name = "talos-${var.talos_version}-nocloud-amd64.iso"

#   # Avoid re-downloading on every apply once the image is present.
#   overwrite = false
# }

module "talos_vm" {
  source = "./pve-vm"

  pve_node    = var.pve_node
  name        = var.vm_name
  vmid        = var.vmid
  description = var.vm_description
  tags        = var.tags

  iso_datastore_id = var.iso_datastore_id

  cpu       = var.cpu
  memory    = var.memory
  disk_size = var.disk_size
  cpu_type  = var.cpu_type

  datastore_id           = var.vm_datastore_id
  cloudinit_datastore_id = var.cloudinit_datastore_id
  disk_interface         = var.disk_interface

  network_bridge = var.network_bridge
  vlan_id        = var.vlan_id
  ip_address     = var.ip_address
  network_prefix = var.network_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
}

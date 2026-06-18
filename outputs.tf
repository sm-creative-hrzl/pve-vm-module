###############################################################################
# Outputs
###############################################################################

output "vmid" {
  description = "Proxmox VMID of the created VM."
  value       = module.talos_vm.vmid
}

output "name" {
  description = "VM name."
  value       = module.talos_vm.name
}

output "ip_address" {
  description = "Configured static IP address."
  value       = module.talos_vm.ip_address
}

output "mac_address" {
  description = "MAC address of the primary NIC."
  value       = module.talos_vm.mac_address
}

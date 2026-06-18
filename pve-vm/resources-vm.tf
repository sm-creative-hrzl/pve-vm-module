resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  vm_id       = var.vmid
  node_name   = var.pve_node
  description = var.description
  tags        = var.tags

  on_boot = true

  agent {
    enabled = true
    trim    = true
  }

  operating_system {
    type = "l26"
  }

  cdrom {
    file_id   = "${var.iso_datastore_id}:iso/talos-${var.talos_version}-nocloud-amd64.iso"
    interface = "ide3"
  }

  # First boot: disk is empty so firmware falls through to the ISO (maintenance
  # mode). After Talos installs itself to disk it boots from disk on every
  # subsequent start.
  boot_order = [var.disk_interface, "ide3"]

  cpu {
    cores = var.cpu
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = var.disk_interface
    size         = var.disk_size
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    vlan_id  = var.vlan_id
    firewall = false
  }

  initialization {
    datastore_id = var.cloudinit_datastore_id

    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.network_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }

  lifecycle {
    # Talos manages its own disk/boot once installed; avoid spurious diffs from
    # the cloud-init drive and disk metadata the guest mutates at runtime.
    ignore_changes = [
      initialization,
      disk[0].file_format,
    ]
  }
}

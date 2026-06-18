variable "talos_version" {
  description = "Talos Linux version. Used to match the ISO filename that was manually uploaded to Proxmox (talos-<version>-nocloud-amd64.iso)."
  type        = string
  default     = "v1.9.2"
}

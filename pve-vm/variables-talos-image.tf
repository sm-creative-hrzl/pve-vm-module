variable "talos_version" {
  description = "Talos Linux version (used to name the ISO and derive the download URL)."
  type        = string
  default     = "v1.9.2"
}

variable "talos_image_factory_schematic" {
  description = "Talos Image Factory schematic ID. Default is the stock schematic (no system extensions); generate your own at https://factory.talos.dev."
  type        = string
  default     = "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
}

variable "talos_iso_url" {
  description = "Override for the full Talos nocloud ISO download URL. When null it is derived from talos_image_factory_schematic + talos_version."
  type        = string
  default     = null
}

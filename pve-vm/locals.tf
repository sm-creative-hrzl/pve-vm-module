locals {
  talos_iso_url = coalesce(
    var.talos_iso_url,
    "https://factory.talos.dev/image/${var.talos_image_factory_schematic}/${var.talos_version}/nocloud-amd64.iso",
  )
}

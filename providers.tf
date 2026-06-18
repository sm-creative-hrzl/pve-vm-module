terraform {
  required_version = "~> 1.15"
  backend "s3" {
    bucket = "terraform-state"
    key    = "pve-vm/terraform.tfstate"
    endpoints = {
      s3 = "http://10.10.20.205:19000"
    }
    region                      = "pve-nzxt"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.109"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = "${var.pve_token_id}=${var.pve_token_secret}"
  insecure  = var.pve_tls_insecure
  ssh {
    agent    = true
    username = var.pve_ssh_username
  }
}

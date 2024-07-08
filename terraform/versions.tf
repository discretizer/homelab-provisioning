terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.60.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
    flux = {
      source = "fluxcd/flux"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.0.0"
    }
  }
}

provider "talos" {}

provider "http" {}

provider "external" {}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  api_token = var.proxmox_api_token
  ssh {
    agent    = true
    username = var.proxmox_username
  }

  tmp_dir = "/var/tmp"
}

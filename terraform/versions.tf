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
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
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
  }
}

provider "talos" {}

provider "http" {}

provider "external" {}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure

  api_token = var.proxmox.api_token
  ssh {
    agent    = true
    username = var.proxmox.username
  }

  tmp_dir = "/var/tmp"
}

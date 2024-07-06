# Terraform for Homelab Kubernetes Cluster Deployment

## Features

* Uses SOPS to encrypt secretes
* Uses OpenTofo state encryption


## Prerequisites

* An existing proxmox cluster
* Proxmox API and SSH credentials configured as specified in the proxmox provider documentation
    - [SSH Configuration](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-connection)
    - [API Token Authentication](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication)
* 
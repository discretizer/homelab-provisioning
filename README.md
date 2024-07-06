# Terraform for Homelab Kubernetes Cluster Deployment

## Features

* Uses SOPS to encrypt secrets
* Uses OpenTofo state encryption for a local state
    - allows the terraform/tofu state to be stored in the repo itself 

## Prerequisites

* An existing proxmox cluster
* Proxmox API and SSH credentials configured as specified in the proxmox provider documentation
    - [SSH Configuration](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-connection)
    - [API Token Authentication](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication)
* A DHCP server with 
* A github repo for FluxCD
* A github access token for FluxCD

## Initial Minimum Configuration

* Update 


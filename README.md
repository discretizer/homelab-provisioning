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
* A DHCP server that you control (most commercial routes support static assignment)
* A github repo for FluxCD
* A github access token for FluxCD

## Initial Minimum Configuration

* Generate a set of random MAC address for your cluster and set up your DHCP serice to assign those mac addresses
to your specific cluster IP addresses 
* Update [config.auto.tfvars](terraform/config.auto.tfvars) - with the appropriate configuration for you cluster 
* Update [secrets.enc.env](secrets.enc.env) - with YOUR appropriate secrets.  The format is as follows: 
```
export TF_VAR_github_owner="<GITHUB OWNER>"
export TF_VAR_github_token="<GITHUB TOKEN>"
export TF_VAR_github_repository="<GITHUB REPO NAME>"
export TF_VAR_proxmox_username="<PROXMOX USERNAME>"
export TF_VAR_proxmox_api_token="<PROXMOX API TOKEN>"
export TF_VAR_proxmox_endpoint="<PROXMOX ENDPOINT>"
export TF_ENCRYPTION='key_provider "pbkdf2" "passphrase_provider" { passphrase ="<RANDOM PASSPHRASE>"}'
``
* Add your [age]() key (or any other SOPS supported key) in the (.sops.yaml)[.sops.yaml]
* Encrypt your secrets: `sops -e -i secrets.enc.env`
* Source your secrets in your environment and run tofu
```
source ./tf_env
cd terraform 
tofu init
tofu apply
```
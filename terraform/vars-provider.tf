variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
  sensitive = true
}

variable "proxmox_api_token" {
  description = "Proxmox API token" 
  type        = string
  sensitive = true
}

variable "proxmox_insecure" {
  description = "Should proxmox client ignore SSL errors"
  type        = bool
  default = false
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox" {
  description = "Proxmox cluster auth"
  type        = object({
    endpoint = string
    username  = string
    api_token = string
    insecure = bool
  })
  sensitive = true
}

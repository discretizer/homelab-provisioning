
# Ideally we could configure this as part of some DHCP provisioning system, 
# but for now we'll just hardcode it here as the provider for my DHCP server
# doesn't support this yet
variable "node_mac_addresses" {
  description = "A map of IP addresses to MAC addresses for DHCP reservations"
  type = map(string)
}

# TODO: Figure out a good way to handle custom configurations for each node 
# (and maybe custom image configurations).  This would be useful for things 
# likes graphics cards, etc.  For now we just load talos with the nvidia driver
# and add the graphics cards manually. 
variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      cores = number
      memory = number
      disk_size = string
      vm_host = string 
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      cores = number
      memory = number
      disk_size = string
      vm_host = string 
      install_disk = string
      hostname     = optional(string)
      node_labels  = optional(map(string), {})
    }))
  })
}

variable "node_mac_addresses" {
  description = "A map of IP addresses to MAC addresses for DHCP reservations"
  type = map(string)
  default = {
    "192.168.1.12" = "08:00:69:a4:c7:f1"
    "192.168.1.13" = "08:00:69:be:eb:ff"
    "192.168.1.21" = "08:00:69:f0:4f:8e"
    "192.168.1.22" = "08:00:69:3d:22:8d"
    "192.168.1.31" = "08:00:69:74:40:cc"
    "192.168.1.32" = "08:00:69:94:0a:fe"
  }
}

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
  default = {
    controlplanes = {
      "192.168.1.12" = {
        cores = 4
        memory = 4096               # In Mb
        disk_size = 100             # In Gb
        vm_host = "pve1"
        install_disk = "/dev/sda"
        hostname     = "k8s-ctrl-1"
      },
      "192.168.1.21" = {
        cores = 4
        memory = 4096               # In Mb
        disk_size = 100             # In Gb
        vm_host = "pve2"
        install_disk = "/dev/sda"
        hostname     = "k8s-ctrl-2"
      },
      "192.168.1.31" = {
        cores = 4
        memory = 4096               # In Mb
        disk_size = 100             # In Gb
        vm_host = "pve3"
        install_disk = "/dev/sda"
        hostname     = "k8s-ctrl-3"
      },
    }
    workers = {
      "192.168.1.13" = {
        cores = 8
        memory = 16384
        disk_size = 500 # 500GB
        vm_host = "pve1"
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-1"
      },
      "192.168.1.22" = {
        cores = 8
        memory = 16384
        disk_size = 500 # 500GB
        vm_host = "pve2"
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-2"
      }
      "192.168.1.32" = {
        cores = 8
        memory = 16384
        disk_size = 500 # 500GB
        vm_host = "pve3"
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-3"
      }
    }
  }
}

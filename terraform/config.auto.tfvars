cluster_vip = "192.168.1.50"
cluster_name = "geohomelab-cluster"

network_gateway = "192.168.1.1"
network_ip_prefix = 24

node_mac_addresses = {
    # For some reason SGI Inc got the prefix 08:00:69 from the IEEE - NICE!
    # Not sure if this is a good idea to use it, but it's a lab so who cares
    "192.168.1.12" = "08:00:69:a4:c7:f1"
    "192.168.1.13" = "08:00:69:be:eb:ff"	 
    "192.168.1.21" = "08:00:69:f0:4f:8e"
    "192.168.1.22" = "08:00:69:3d:22:8d"
    "192.168.1.31" = "08:00:69:74:40:cc"
    "192.168.1.32" = "08:00:69:94:0a:fe"
}

node_data = {
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
        cores = 16
        memory = 16384
        disk_size = 750 # 500GB
        vm_host = "pve1" 
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-1"
        node_labels  = {
          "node-role" = "worker",
          "accelerator-type" = "nvidia",
          "accelerator" = "nvidia-tesla-p40"
        }
      },
      "192.168.1.22" = {
        cores = 16
        memory = 16384 
        disk_size = 750 # 500GB
        vm_host = "pve2"
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-2"
        node_labels  = {
          "node-role" = "worker",
          "accelerator-type" = "nvidia",
          "accelerator" = "nvidia-rtx-2080ti"
        }
      }
      "192.168.1.32" = {
        cores = 16
        memory = 16384
        disk_size = 750 # 500GB
        vm_host = "pve3"
        install_disk = "/dev/sda"
        hostname     = "k8s-worker-3"
        node_labels  = {
          "node-role" = "worker",
          "accelerator-type" = "nvidia",
          "accelerator" = "nvidia-tesla-p4"
        }
      }
    }
}
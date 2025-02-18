
variable "talos_data" {
  description = "Talos OS configuration data"
  type        = object({
    talos_version = string
    k8s_version = string
    cilium_version = string
    secure_boot = bool
  })
  default = {
    talos_version = "1.7.5"
    k8s_version = "1.30.1"
    cilium_version = "1.15.6"
    secure_boot = true
  }
}


variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_vip" {
  description = "The cluster VIP"
  type        = string
}

variable "cluster_domain" {
  description = "The domain name for the cluster"
  type        = string
  default     = "cluster.local"
}

variable "cluster_endpoint_port" {
  description = "The port for the cluster endpoint"
  type        = number
  default     = 6443
}

variable "cluster_endpoint" {
  description = "The cluster endpoint"
  type        = string
  default     = ""
}

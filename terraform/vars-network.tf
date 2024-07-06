variable "network_gateway" {
    description = "The network gateway"
    type        = string
    default     = "192.168.1.1"
}

variable "network_ip_prefix" {
  description = "Network IP network prefix"
  type        = number
  default     = 24
}

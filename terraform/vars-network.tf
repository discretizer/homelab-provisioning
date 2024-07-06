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
variable "router_ip" {
  description = "IP address of the router, uses network_gateway as default value"
  type        = string
  default     = ""
}

variable "router_asn" {
  description = "Router ASN for use with Cilium BGP"
  type        = number
  default     = 64501
}

variable "cilium_asn" {
  type    = number
  default = 64500
}

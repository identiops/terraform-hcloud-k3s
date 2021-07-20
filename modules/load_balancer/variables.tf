variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  default     = "hetzner"
}

variable "id" {
  description = "Load balancer id"
}

variable "location" {
  description = "Hetzner location where resources reside: hel1 (Helsinki), nbg1 (Nürnberg), or fsn1 (Falkenstein)"
  default     = "hel1"
}

variable "load_balancer_type" {
  description = "Load balancer type"
  default     = "lb11"
  validation {
    condition     = can(regex("^lb[1-3]1$", var.load_balancer_type))
    error_message = "Load balancer type is not valid."
  }
}

variable "service" {
  description = "Load balancer services"
  # type        = object({ destination_port = number, protocol = string })
  default = {}
}

variable "target" {
  description = "Load balancer targets"
  type        = list(string)
  default     = []
}

variable "hcloud_network" {
  description = "Herzner cloud network"
}


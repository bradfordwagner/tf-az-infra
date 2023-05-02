variable "enabled" {
  type    = bool
  default = false
}

variable "resource_group_name" {
  type = string
}

variable "node_count" {
  type    = number
  default = 5
}

variable "k8s_version" {
  default = "1.25.6"
}

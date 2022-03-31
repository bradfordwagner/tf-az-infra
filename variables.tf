variable "node_count" {
  type    = number
  default = 1
}

variable "region" {
  type    = string
  default = "eastus2"
}

variable "k8s_version" {
  default = "1.21.9"
}

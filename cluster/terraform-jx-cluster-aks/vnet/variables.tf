variable "resource_group" {
  type = string
}
variable "vnet_cidr" {
  type = string
}
variable "subnet_cidr" {
  type = string
}
variable "network_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "location" {
  type = string
}
variable "enable_apiserver_vnet_integration" {
  type        = bool
  default     = false
  description = "Flag to enable API server VNET integration."
}
variable "api_server_subnet_cidr" {
  type        = string
  description = "CIDR for the API server VNET integration subnet. Minimum /28."
}

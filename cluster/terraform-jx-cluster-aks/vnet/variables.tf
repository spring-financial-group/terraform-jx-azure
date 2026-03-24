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
variable "cluster_name" {
  type = string
}
variable "cluster_managed_outbound_ip_count" {
  type        = number
  description = "The number of public IPs to create for NAT Gateway outbound traffic."
}
variable "nat_gateway_idle_timeout_in_minutes" {
  type        = number
  default     = 10
  description = "The idle timeout in minutes for the NAT Gateway."
}

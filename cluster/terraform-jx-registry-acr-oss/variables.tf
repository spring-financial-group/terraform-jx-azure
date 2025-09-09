variable "resource_group_name" {
  description = "Resource group in which to create registry"
  type        = string
  default     = ""
}
variable "oss_registry_name" {
  description = "Name of the Open Source container registry"
  type        = string
  default     = ""
}
variable "location" {
  description = "Location in which to create registry"
  type        = string
  default     = "australiaeast"
}
variable "principal_id" {
  description = "Principal id of the identity to give authorisation to push/pull to container registry"
  type        = string
}
variable "oss_registry_scope_map_name" {
  description = "Name of OSS registry scope map"
  type        = string
  default     = ""
}
variable "oss_registry_token_name" {
  description = "Name of OSS registry token"
  type        = string
  default     = ""
}
variable "sku" {
  description = "SKU of the container registry"
  type        = string
  default     = "Standard"
}

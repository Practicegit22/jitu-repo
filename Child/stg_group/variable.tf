
variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "shiva-rg"

}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Australia East"
  
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Région Azure cible"
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit être dev, staging ou prod."
  }
}

variable "tags" {
  type    = map(string)
  default = { project = "3tier", managed_by = "terraform" }
}

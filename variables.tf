variable "region" {
  description = "AWS region hosting the estate."
  type        = string
  default     = "us-west-2"
}

variable "name_prefix" {
  description = "Prefix shared by every resource name in this estate."
  type        = string
  default     = "soc2-workshop"
}

variable "db_password" {
  description = "Master password for soc2-workshop-db."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 128
    error_message = "RDS requires a master password of 8-128 characters."
  }

  validation {
    condition     = !can(regex("[/\"@ ]", var.db_password))
    error_message = "RDS forbids /, \", @ and spaces in the master password."
  }
}

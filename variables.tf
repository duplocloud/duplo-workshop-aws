variable "region" {
  description = "AWS region hosting the estate."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix shared by every resource name in this estate."
  type        = string
  default     = "soc2-workshop"
}

variable "db_password" {
  description = <<-EOT
    Master password for soc2-workshop-db. The live value is not readable via the
    AWS API, so it cannot be reproduced from the running instance. Supply it to
    create the instance from scratch; on `terraform import` it is ignored (see
    the lifecycle block on aws_db_instance.workshop).
  EOT
  type        = string
  sensitive   = true
}

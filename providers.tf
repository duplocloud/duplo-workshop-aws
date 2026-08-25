provider "aws" {
  region = var.region

  # Applied to every taggable resource in the estate rather than repeated on
  # each one. The sub-resources that configure the S3 buckets (ACL, ownership
  # controls, public access block, encryption, policy) take no tags, so these
  # land on 7 of the 16 resources.
  default_tags {
    tags = {
      ManagedBy = "terraform"
      Extension = "soc2-posture"
    }
  }
}

# The security group and RDS instance live in the account's default VPC for
# whichever region var.region resolves to.
data "aws_vpc" "default" {
  default = true
}

# Used to suffix the S3 bucket names below, since both are unqualified enough
# that another account may already hold them.
data "aws_caller_identity" "current" {}

terraform {
  # use_lockfile (S3-native state locking) requires Terraform 1.11+.
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket = "duplocloud-workshop-tfstate"
    key    = "soc2-resources/terraform.tfstate"
    region = "us-west-2"

    encrypt = true

    # S3-native locking. Replaces the legacy DynamoDB lock table, which is
    # deprecated and needs no separate resource.
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

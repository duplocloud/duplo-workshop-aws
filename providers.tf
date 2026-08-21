provider "aws" {
  region = var.region

  # Every resource in this estate carries exactly one tag, ManagedBy=terraform,
  # so it is expressed once here rather than repeated on each resource.
  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

# The security group and RDS instance live in the account's default VPC
# (vpc-0a9bf6c1794f55cb0, 172.31.0.0/16).
data "aws_vpc" "default" {
  default = true
}

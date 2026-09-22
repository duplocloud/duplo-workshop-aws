###############################################################################
# soc2-workshop-db-subnet-group
#
# The account/region has no "default" DB subnet group, which is what RDS
# falls back to when db_subnet_group_name is omitted or set to "default".
# Declared explicitly here from the default VPC's subnets so the RDS instance
# in rds.tf doesn't hit DBSubnetGroupNotFoundFault.
###############################################################################

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "workshop" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

###############################################################################
# soc2-workshop-app-sg
#
# Lives in the account's default VPC. Inline ingress/egress blocks are used so
# the group and its rules import as a single resource, matching how the live
# group is structured.
###############################################################################

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.1/32"]
  }

  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

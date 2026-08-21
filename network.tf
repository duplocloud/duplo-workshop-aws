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
    cidr_blocks = ["0.0.0.0/0"]
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

###############################################################################
# soc2-workshop-service-user and the policy attached to it
#
# The user has no access keys, no inline policies, and no group memberships.
###############################################################################

resource "aws_iam_user" "service" {
  name = "${var.name_prefix}-service-user"
  path = "/"
}

resource "aws_iam_policy" "wildcard" {
  name        = "${var.name_prefix}-wildcard-policy"
  path        = "/"
  description = "Overly permissive policy for workshop purposes"
  policy      = data.aws_iam_policy_document.wildcard.json
}

data "aws_iam_policy_document" "wildcard" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy_attachment" "service_wildcard" {
  user       = aws_iam_user.service.name
  policy_arn = aws_iam_policy.wildcard.arn
}

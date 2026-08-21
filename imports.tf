###############################################################################
# Import blocks mapping the live us-east-1 resources onto this configuration.
#
#   terraform init
#   terraform plan -generate-config-out=/dev/null   # or just: terraform plan
#   terraform apply                                 # adopts, creates nothing
#
# A clean adoption shows "N to import, 0 to add, 0 to change, 0 to destroy".
# Once the state is adopted, this file can be deleted.
###############################################################################

import {
  to = aws_s3_bucket.data
  id = "soc2-workshop-data-bucket"
}

import {
  to = aws_s3_bucket_ownership_controls.data
  id = "soc2-workshop-data-bucket"
}

import {
  to = aws_s3_bucket_public_access_block.data
  id = "soc2-workshop-data-bucket"
}

import {
  to = aws_s3_bucket_acl.data
  id = "soc2-workshop-data-bucket,public-read"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.data
  id = "soc2-workshop-data-bucket"
}

import {
  to = aws_s3_bucket.trail_logs
  id = "soc2-workshop-trail-logs"
}

import {
  to = aws_s3_bucket_ownership_controls.trail_logs
  id = "soc2-workshop-trail-logs"
}

import {
  to = aws_s3_bucket_public_access_block.trail_logs
  id = "soc2-workshop-trail-logs"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.trail_logs
  id = "soc2-workshop-trail-logs"
}

import {
  to = aws_s3_bucket_policy.trail_logs
  id = "soc2-workshop-trail-logs"
}

import {
  to = aws_security_group.app
  id = "sg-0b98976923ed900c6"
}

import {
  to = aws_db_instance.workshop
  id = "soc2-workshop-db"
}

import {
  to = aws_cloudtrail.workshop
  id = "soc2-workshop-trail"
}

import {
  to = aws_iam_user.service
  id = "soc2-workshop-service-user"
}

import {
  to = aws_iam_policy.wildcard
  id = "arn:aws:iam::803817915563:policy/soc2-workshop-wildcard-policy"
}

import {
  to = aws_iam_user_policy_attachment.service_wildcard
  id = "soc2-workshop-service-user/arn:aws:iam::803817915563:policy/soc2-workshop-wildcard-policy"
}

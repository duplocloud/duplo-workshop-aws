###############################################################################
# soc2-workshop-trail
#
# Single-region trail writing to soc2-workshop-trail-logs. Logging is currently
# stopped, global service events are excluded, log file validation is off, and
# no event selectors or insight selectors are configured.
###############################################################################

resource "aws_cloudtrail" "workshop" {
  name           = "${var.name_prefix}-trail"
  s3_bucket_name = aws_s3_bucket.trail_logs.id

  enable_logging                = false
  include_global_service_events = false
  is_multi_region_trail         = false
  is_organization_trail         = false
  enable_log_file_validation    = false

  depends_on = [aws_s3_bucket_policy.trail_logs]
}

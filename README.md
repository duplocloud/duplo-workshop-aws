# soc2-workshop — as-built Terraform

Reverse-engineered from the live `us-east-1` resources in account `803817915563`
tagged `ManagedBy=terraform` and named `soc2-workshop-*`. Inspected 2026-08-21.

This is a faithful reproduction of the running state, not a target state. It is
written so that `terraform apply` against the existing resources adopts them
with no changes.

## Resources covered

| Terraform address | Live resource |
| --- | --- |
| `aws_s3_bucket.data` (+ ownership, PAB, ACL, SSE) | `soc2-workshop-data-bucket` |
| `aws_s3_bucket.trail_logs` (+ ownership, PAB, SSE, policy) | `soc2-workshop-trail-logs` |
| `aws_db_instance.workshop` | `soc2-workshop-db` |
| `aws_security_group.app` | `sg-0b98976923ed900c6` / `soc2-workshop-app-sg` |
| `aws_cloudtrail.workshop` | `soc2-workshop-trail` |
| `aws_iam_user.service` | `soc2-workshop-service-user` |
| `aws_iam_policy.wildcard` + attachment | `soc2-workshop-wildcard-policy` |

The account holds two other estates carrying the same `ManagedBy=terraform` tag
— `ecomm-workshop` (43 resources) and `firstbank` (17 ECS task-definition
revisions). Neither is in scope here.

## Adopting the existing resources

```sh
terraform init
cp terraform.tfvars.example terraform.tfvars   # any db_password value will do
terraform plan
```

A clean adoption reports `16 to import, 0 to add, 0 to change, 0 to destroy`.
After `terraform apply`, delete `imports.tf`.

## Referenced but not managed

These are AWS-provided or pre-existing and are looked up by name rather than
declared:

- the default VPC `vpc-0a9bf6c1794f55cb0` (`172.31.0.0/16`), via `data.aws_vpc.default`
- the `default` DB subnet group
- the `default.postgres15` parameter group and `default:postgres-15` option group

## Fidelity caveats

Three details of the live estate could not be carried over exactly:

- **DB master password** — not readable through the AWS API. It is a required
  variable, and `aws_db_instance.workshop` ignores changes to it so an imported
  instance does not show a permanent diff.
- **DB backup window** — RDS reports `08:51-09:21`, but rejects a backup window
  while `backup_retention_period` is `0`. Recorded as a comment in `rds.tf`
  rather than declared.
- **`skip_final_snapshot`** — set to `true`. It governs destroy-time behaviour
  only and has no counterpart on the running instance.

Absent configurations are represented by the absence of a resource: neither
bucket has versioning, access logging, lifecycle rules, CORS, replication,
notifications, or object lock, and the trail has no event or insight selectors.

Tagging is expressed once, as provider `default_tags`, because all seven
resources carry exactly the tag `ManagedBy=terraform`.

# soc2-workshop — as-built Terraform

Reverse-engineered from the live `us-east-1` resources in account `803817915563`
tagged `ManagedBy=terraform` and named `soc2-workshop-*`. Inspected 2026-08-21.

This is a faithful reproduction of the state those resources were in, not a
target state. The originals have since been deleted, so this config now creates
the estate from scratch.

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

## Creating the estate

```sh
terraform init
cp terraform.tfvars.example terraform.tfvars   # set a real db_password
terraform plan
```

A clean run reports `16 to add, 0 to change, 0 to destroy`. The RDS instance
takes roughly 5-10 minutes; everything else is quick.

An earlier revision carried an `imports.tf` of 16 import blocks for adopting the
original resources. It was removed once those resources were deleted, since an
import block naming a non-existent object fails the plan outright.

## Referenced but not managed

These are AWS-provided or pre-existing and are looked up by name rather than
declared:

- the default VPC `vpc-0a9bf6c1794f55cb0` (`172.31.0.0/16`), via `data.aws_vpc.default`
- the `default` DB subnet group
- the `default.postgres15` parameter group and `default:postgres-15` option group

## Fidelity caveats

Three details of the live estate could not be carried over exactly:

- **DB master password** — the original was not readable through the AWS API,
  so it could not be carried over. `var.db_password` sets a new one at create
  time.
- **DB backup window** — RDS reports `08:51-09:21`, but rejects a backup window
  while `backup_retention_period` is `0`. Recorded as a comment in `rds.tf`
  rather than declared.
- **`skip_final_snapshot`** — set to `true`. It governs destroy-time behaviour
  only and has no counterpart on the running instance.

Absent configurations are represented by the absence of a resource: neither
bucket has versioning, access logging, lifecycle rules, CORS, replication,
notifications, or object lock, and the trail has no event or insight selectors.

Tagging is expressed once, as provider `default_tags`: `ManagedBy=terraform`,
matching the original estate, plus `Extension=soc2-posture`.

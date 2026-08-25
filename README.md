# soc2-workshop

Terraform that stands up a small, deliberately non-compliant AWS estate in
`us-east-1`, for use as the target of a SOC 2 posture review.

Running it from a clean slate creates 17 resources across S3, RDS, EC2,
CloudTrail and IAM. Most of them are misconfigured on purpose: the estate is the
exercise, not a reference implementation.

## What gets created

| Resource | Name | Delivered configuration |
| --- | --- | --- |
| S3 bucket | `soc2-workshop-data-bucket-<account-id>` | SSE-S3, `BucketOwnerPreferred`, a **`public-read` ACL**, and **all four public access blocks off** |
| S3 bucket | `soc2-workshop-trail-logs-<account-id>` | SSE-S3, `BucketOwnerEnforced`, all four public access blocks on, plus a policy letting CloudTrail write |
| DB subnet group | `soc2-workshop-db-subnet-group` | Spans every subnet in the default VPC |
| RDS instance | `soc2-workshop-db` | PostgreSQL 15.7 on `db.t3.micro`, 20 GB gp2, **publicly accessible**, **unencrypted at rest**, **no backups** |
| Security group | `soc2-workshop-app-sg` | **Ports 22 and 3389 open to `0.0.0.0/0`**, all egress allowed |
| CloudTrail trail | `soc2-workshop-trail` | Single-region, **logging switched off**, no global service events, no log file validation |
| IAM user | `soc2-workshop-service-user` | No access keys, no inline policies |
| IAM policy | `soc2-workshop-wildcard-policy` | **`Action: *` on `Resource: *`**, attached to the user above |

Those eight are the AWS-visible resources. The other nine Terraform resources
configure the two buckets — ACL, ownership controls, public access block,
encryption and bucket policy are each their own resource in the AWS provider.

Every taggable resource gets `ManagedBy=terraform` and `Extension=soc2-posture`,
applied once through provider `default_tags`.

### The findings it is built to surface

A posture review of the result should flag, at minimum:

- a **world-readable S3 bucket** — public ACL with no public access block to
  override it, and no versioning, access logging or lifecycle rules
- an **internet-facing, unencrypted database** with backup retention at zero and
  deletion protection off, reachable from the wide-open security group
- **SSH and RDP exposed to the entire internet**
- **an audit trail that is not recording** — the trail exists, so it looks
  configured, but logging is stopped and it covers one region only
- **unrestricted IAM** — full administrative access granted to a service user
  via a wildcard policy

The `soc2-workshop-trail-logs` bucket is the one component that is locked down
correctly, so a review that flags every bucket indiscriminately is over-reporting.

## Prerequisites

- Terraform **1.11+** (the S3 backend uses `use_lockfile`)
- AWS provider `~> 6.0`, locked to 6.61.0 in `.terraform.lock.hcl`
- Credentials for the target account, and an existing **default VPC** in
  `us-east-1`
- A state bucket at `s3://duplo-darren-workshop-tfstate-803817915563`, versioned

## Running it

```sh
terraform init
cp terraform.tfvars.example terraform.tfvars   # set db_password
terraform plan
terraform apply
```

A clean run reports `16 to add, 0 to change, 0 to destroy`. The RDS instance
takes roughly 5–10 minutes to come up; everything else completes in seconds.

`db_password` is the only value you must supply. It sets the RDS master password
at create time and is validated up front against the RDS rules — 8–128
characters, no `/`, `"`, `@` or spaces — so a bad value fails at plan time rather
than partway through an apply.

State is kept in S3 under the key `soc2-resources/terraform.tfstate`, with
S3-native locking rather than a DynamoDB table.

## What it expects to already exist

These are looked up or referenced by name rather than declared, and the apply
fails without them:

- the account's **default VPC**, via `data.aws_vpc.default` — it carries the
  security group and, through its subnets, the database's DB subnet group
  (`aws_db_subnet_group.workshop`, managed in `network.tf`)
- the **`default.postgres15`** parameter group and **`default:postgres-15`**
  option group

## Notes

**It is pinned to `us-east-1`.** `var.region` exists, but the RDS instance
hardcodes `availability_zone = "us-east-1d"` and the S3 backend takes a literal
region, since backend blocks cannot reference variables. Changing `var.region`
alone will not relocate the estate.

**Bucket names are suffixed with the account ID.** `soc2-workshop-data-bucket`
and `soc2-workshop-trail-logs` were unqualified enough that another account
could hold them, so both now get `-${data.aws_caller_identity.current.account_id}`
appended in `s3.tf`.

**PostgreSQL 15.7 is on extended support.** `engine_lifecycle_support` is set to
`open-source-rds-extended-support`, which is billable once a version passes
standard support. Worth checking before leaving the estate running.

**Two settings have no live counterpart.** `skip_final_snapshot = true` governs
destroy-time behaviour only. And RDS reports a preferred backup window of
`08:51–09:21` but rejects one being set while `backup_retention_period` is `0`,
so it sits as a comment in `rds.tf` rather than a declared argument.

## Provenance

Reverse-engineered on 2026-08-21 from a live estate in account `803817915563`
tagged `ManagedBy=terraform` and named `soc2-workshop-*`, then reworked to create
from scratch after those resources were deleted. Configuration values reproduce
what was running rather than what should have been.

That account holds two unrelated estates carrying the same `ManagedBy=terraform`
tag — `ecomm-workshop` (43 resources) and `firstbank` (17 ECS task-definition
revisions). Neither is in scope here.

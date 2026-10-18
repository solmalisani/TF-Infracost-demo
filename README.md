# Governed Infrastructure Controlling Cost and Change with TF + GH + Infracost

**What it builds:** VPC, 2 public + 2 private subnets, internet gateway, one `t3.micro` EC2 instance (no inbound ports, access via SSM Session Manager), one `db.t4g.micro` PostgreSQL RDS instance in private subnets, and the IAM and security groups around them. No NAT gateway.

## Pipelines (GitHub Actions)
- **deploy-infra:** on pull requests, plans and comments the cost change. On merge to main, applies automatically if the monthly increase is within COST_THRESHOLD, otherwise sends Slack and email and waits for approval.
- **check-drift:** daily at 06:00 UTC and on demand. If real infrastructure differs from the state, it plans the restore, notifies, waits for approval, then applies.

*Approval works through a GitHub issue: an approver listed in APPROVERS replies approve or deny. This works on free private repositories.*

**Repository secrets** (Settings, Secrets and variables, Actions): AWS_ROLE, INFRACOST_API_KEY, SLACK_WEBHOOK_URL, SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, EMAIL_TO.

**Repository variables:** COST_THRESHOLD (maximum allowed monthly increase in USD, for example 10) and APPROVERS (comma-separated GitHub usernames).

*Commit infra/.terraform.lock.hcl so every run uses the same provider versions.*

## Demo

- **Front door:** in a pull request, change `instance_type` (for example `t3.xlarge`) and `db_instance_class` (for example `db.m5.large`). Infracost shows the monthly increase.
- **Back door:** in the AWS console, add an inbound SSH rule open to the world on the `governed-demo-app-sg` security group, or edit a tag on the EC2 instance. The next `terraform plan` shows the drift, and `apply` restores it.

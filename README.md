# Governed Infrastructure Controlling Cost and Change with TF + GH + Infracost

**What it builds:** VPC, 2 public + 2 private subnets, internet gateway, one `t3.micro` EC2 instance (no inbound ports, access via SSM Session Manager), one `db.t4g.micro` PostgreSQL RDS instance in private subnets, and the IAM and security groups around them. No NAT gateway.

**Rough cost if left running:** about $25-30 per month (about $1 per day), mostly RDS, EC2 and the public IPv4 address. These are estimates, so check them with Infracost. Destroy it after the demo.

## Setup

1. Install Terraform 1.10 or newer, the AWS CLI, and the Session Manager plugin. Log in to your AWS account (`aws configure sso` or access keys).
2. One-time bootstrap (state bucket + GitHub OIDC role):
   ```
   cd bootstrap
   terraform init
   terraform apply -var="github_repo=OWNER/REPO"
   ```
3. Put the `state_bucket` output into `infra/versions.tf` (replace `REPLACE-WITH-STATE-BUCKET`).
4. Build the stack (the database takes 5-10 minutes):
   ```
   cd ../infra
   terraform init
   terraform plan
   terraform apply
   ```
5. Connect to the server: run the `ssm_connect_command` output.
6. Tear down when finished: `terraform destroy` in `infra`, then in `bootstrap`.

## Demo hooks

- **Front door:** in a pull request, change `instance_type` (for example `t3.xlarge`) and `db_instance_class` (for example `db.m5.large`). Infracost shows the monthly increase.
- **Back door:** in the AWS console, add an inbound SSH rule open to the world on the `governed-demo-app-sg` security group, or edit a tag on the EC2 instance. The next `terraform plan` shows the drift, and `apply` restores it.

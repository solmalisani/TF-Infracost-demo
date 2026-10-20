# Governed Infrastructure Controlling Cost and Change with TF + GH + Infracost

**What it builds:** VPC, 2 public + 2 private subnets, internet gateway, one `t3.micro` EC2 instance (no inbound ports, access via SSM Session Manager), one `db.t4g.micro` PostgreSQL RDS instance in private subnets, and the IAM and security groups around them. No NAT gateway.

## GitHub Actions Workflows

### `infra-pr.yml` — Terraform PR Checks

**When it runs:** On pull requests that modify Terraform infrastructure files.

This workflow validates infrastructure changes before they are merged. It runs Terraform checks and uses Infracost to estimate the potential cost impact of the proposed changes, providing a cost comparison in the pull request. Cost estimates are informational only: they help reviewers make informed decisions without blocking the pipeline based on a cost threshold.

### `infra-deploy.yml` — Infrastructure Deployment

**When it runs:** When infrastructure changes are ready to be deployed from the main branch.

This workflow applies approved Terraform configuration changes to AWS, keeping the deployed infrastructure aligned with the configuration stored in the repository. It uses GitHub Actions with AWS authentication through OIDC, avoiding long-lived AWS credentials. This is the main workflow for deploying intentional infrastructure changes.

### `check-drift.yml` — Terraform Drift Detection

**When it runs:** Automatically every day at 06:00 UTC, or manually through `workflow_dispatch`.

This workflow detects infrastructure drift by comparing the Terraform configuration in the repository with the actual resources deployed in AWS. If drift is detected, it generates a detailed Terraform plan, publishes it as a workflow artifact, creates a GitHub issue with the findings and remediation plan, and sends a Slack notification linking to the issue. This makes unexpected infrastructure changes visible and provides a clear starting point for investigation and remediation.

### `drift-remediation.yml` — Terraform Drift Remediation

**When it runs:** Manually through `workflow_dispatch`.

This workflow restores the AWS infrastructure to the desired state defined in Terraform when drift is not intentional. It first generates and saves a Terraform plan, publishes a readable version in the GitHub Actions run summary, and sends a Slack notification that the remediation is waiting for approval. The apply job uses the saved plan and is gated by the `production-remediation` GitHub Environment, which requires manual approval before changes are applied. This separates plan review from execution and helps prevent unintended infrastructure changes.


## Repository Secrets and Variables

The workflows use GitHub Actions secrets and repository variables to configure AWS authentication, Slack notifications, and remediation approval alerts.

### Secrets

| Name | Description | Used for |
|---|---|---|
| `AWS_REGION` | AWS region where the infrastructure is deployed, for example, `eu-west-1`. | Configuring the AWS region for Terraform operations. |
| `AWS_ROLE` | ARN of the AWS IAM role assumed by GitHub Actions using OpenID Connect (OIDC). | Securely authenticating workflows with AWS to plan, inspect, and deploy infrastructure changes. |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL for the notification channel. | Sending workflow notifications to Slack, including drift alerts and pending remediation approvals. |

### Variables

| Name | Description | Example |
|---|---|---|
| `REMEDIATION_APPROVER_SLACK_IDS` | Slack user mention IDs notified when a Terraform drift remediation deployment is waiting for approval. Use Slack's mention syntax so users are tagged correctly. | `<@U0C9ZLEAS67>` |

### Configuration

Configure these values in the GitHub repository under **Settings → Secrets and variables → Actions**.

- Store sensitive values, such as the AWS role ARN and Slack webhook URL, as **repository secrets**.
- Store non-sensitive configuration, such as Slack approver mentions, as **repository variables**.
- Ensure the AWS IAM role trusts the GitHub Actions OIDC identity and grants only the permissions required by the workflows.
- Configure required reviewers for the `production-remediation` GitHub Environment to ensure remediation changes cannot be applied without approval.

## Demo

The demo shows two infrastructure governance scenarios: **preventing costly changes before deployment** and **detecting and remediating infrastructure drift**.

- **Front door — Cost visibility in pull requests:** Open a pull request and change `instance_type` (for example, to `t3.xlarge`) and `db_instance_class` (for example, to `db.m5.large`). The `infra-pr.yml` workflow runs Terraform checks and Infracost to display the estimated monthly cost impact of the proposed changes. This gives reviewers cost visibility before the infrastructure is deployed, without failing the pipeline based on cost thresholds.

- **Back door — Drift detection and controlled remediation:** In the AWS Console, manually modify a resource managed by Terraform. For example, add an inbound SSH rule open to the world on the `governed-demo-app-sg` security group, or change a tag on an EC2 instance. The scheduled `check-drift.yml` workflow detects the difference between the actual AWS infrastructure and the Terraform configuration, generates a remediation plan, creates a GitHub issue, and sends a Slack notification. After reviewing the findings, trigger `drift-remediation.yml` manually. The workflow publishes the plan summary and notifies the approvers in Slack. Once the deployment is approved through the `production-remediation` GitHub Environment, Terraform applies the saved plan to restore the infrastructure to the desired state defined in code.

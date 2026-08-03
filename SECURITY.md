# Security Policy

## Scope and support

This repository is a reference-only Terraform architecture. It is not a deployed production environment and does not include operational support, security monitoring, or a service-level commitment. Only the current default branch is maintained.

The routing and security-group resources demonstrate structural controls. They are not a complete production network policy, and the mocked test suite does not establish live AWS security or deployability.

## Report a vulnerability

Use GitHub private vulnerability reporting from the repository **Security** tab when it is available. If it is unavailable, contact the repository owner privately through the verified GitHub profile before disclosing technical details. Do not open a public issue containing exploit details, AWS account data, credentials, state files, internal addresses, or other sensitive information.

Include:

- The affected file and commit.
- A concise impact statement and a reproduction that does not contact an AWS account.
- Suggested remediation, if known.
- Whether the issue could expose credentials, Terraform state, IAM permissions, logs, or cloud resources.

You should receive an acknowledgment when the repository owner reviews the report. No response-time commitment is implied.

## Secrets and cloud access

Never commit Terraform state, environment-specific `.tfvars`, AWS access keys, session tokens, private keys, authentication caches, account IDs, customer data, or exported cloud configuration. Pull requests must be testable with backend-disabled initialization and without AWS authentication, planning, applying, deployment, or billable cloud calls.

Any future deployment process must use short-lived credentials, least-privilege IAM, protected environments, independent review, encrypted remote state with locking, and auditable approval controls.

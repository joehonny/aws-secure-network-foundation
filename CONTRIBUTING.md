# Contributing

Thank you for improving this AWS network foundation reference.

## Safety boundary

All configurations and examples are reference-only. They are not deployed production environments. Contributions must not require an AWS login, credentials, account ID, remote backend, plan, apply, deployment, or billable cloud call.

Do not commit Terraform state, environment-specific `.tfvars`, exported cloud configuration, authentication caches, or secrets. Use documentation-safe names and RFC 1918 address ranges.

## Development workflow

1. Create a focused branch or isolated worktree.
2. Keep module inputs and outputs stable unless the change explicitly updates and tests the contract.
3. Format and validate the root module and basic example.
4. Run Terraform tests, root and recursive TFLint, and the Trivy configuration scan.
5. Review the diff for secrets, account identifiers, backends, unsafe IAM, unexpected egress, and unintended resources.

```powershell
terraform fmt -recursive
terraform init -backend=false -lockfile=readonly -input=false
terraform validate -no-color
terraform test -no-color
terraform -chdir=examples/basic init -backend=false -input=false
terraform -chdir=examples/basic validate -no-color
tflint --init --config "$PWD/.tflint.hcl"
tflint --config "$PWD/.tflint.hcl" --format compact
tflint --config "$PWD/.tflint.hcl" --format compact --recursive
trivy config --severity HIGH,CRITICAL --exit-code 1 --skip-dirs .terraform --skip-dirs .tools .
```

## Pull requests

A pull request should explain the reference behavior changed, security and cost implications, verification performed, skipped live checks, and remaining uncertainty. Do not include deployment, customer, certification, performance, resilience, or cost claims without reproducible evidence.

GitHub Actions must use full 40-character commit SHAs from official repositories with readable version comments. CI must remain read-only and credential-free, with no AWS authentication, OIDC token permission, repository secrets, backend, plan, apply, or deployment.

Production adoption requires an independent architecture, security, identity, cost, compliance, operations, and rollback review.

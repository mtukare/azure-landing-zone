# Project 02 — Multi-Environment Deployment

One Terraform codebase deploying to three isolated Azure environments using **Terraform workspaces**, **branch-based promotion**, and **per-environment tfvars files**.

---

## What this project provisions

The same infrastructure stack as Project 01, deployed three times with environment-specific sizing and naming:

| Environment | Branch | Resource Group | VNet CIDR | Storage | Key Vault |
|-------------|--------|---------------|-----------|---------|-----------|
| dev | `dev` | `rg-dev-p2` | 10.0.0.0/16 | LRS | standard |
| staging | `staging` | `rg-staging-p2` | 10.1.0.0/16 | LRS | standard |
| prod | `main` | `rg-prod-p2` | 10.2.0.0/16 | GRS | standard |

Each environment is completely isolated — separate resource groups, separate VNet CIDR ranges, separate Terraform state files.

---

## How environment isolation works

**Three-layer isolation:**

```
Layer 1 — Branch controls which environment is targeted
  push to dev     → deploys dev
  push to staging → deploys staging
  push to main    → deploys prod

Layer 2 — Terraform workspace isolates state
  workspace=dev     → project2.tfstate/env:/dev/terraform.tfstate
  workspace=staging → project2.tfstate/env:/staging/terraform.tfstate
  workspace=prod    → project2.tfstate/env:/prod/terraform.tfstate

Layer 3 — tfvars file injects environment-specific values
  terraform apply -var-file=envs/dev.tfvars
  terraform apply -var-file=envs/staging.tfvars
  terraform apply -var-file=envs/prod.tfvars
```

All three environments can exist simultaneously in Azure — no teardown required between deployments.

---

## Folder structure

```
project2-multi-env/
├── main.tf          # all resources — parameterised, no hardcoded values
├── variables.tf     # variable declarations with validation rules
├── outputs.tf       # prints resource names + env confirmation after apply
├── backend.tf       # remote state config (blank — values injected by CI)
└── envs/
    ├── dev.tfvars      # dev: LRS storage, standard KV, 10.0.0.0/16
    ├── staging.tfvars  # staging: LRS storage, standard KV, 10.1.0.0/16
    └── prod.tfvars     # prod: GRS storage, standard KV, 10.2.0.0/16
```

**Why different VNet CIDRs per environment?** Each environment uses a unique IP range so they could be peered together in the future without IP conflicts. This mirrors real enterprise network design.

**Why GRS for prod storage?** Geo-redundant storage replicates data to a paired region — it survives a full regional Azure outage. Dev/staging use LRS (single datacenter) to save cost.

---

## CI/CD pipeline

Triggered by: any `.tf` or `.tfvars` file change inside `project2-multi-env/`, on branches `dev`, `staging`, or `main`

```
Push to dev / staging / main
          │
          ▼
  [resolve-env]         ← reads branch name, outputs environment + tfvars filename
          │
          ▼
  [validate]            ← fmt -check, validate, checks tfvars file exists
          │
          ├─── Pull Request? ──► [plan]    ← selects workspace, runs plan with -var-file
          │                                   posts plan output as PR comment with env badge
          │
          └─── Push to branch? ──► [apply] ← selects workspace, applies with -var-file
                                              prod apply pauses for manual approval
```

**Workflow file:** `.github/workflows/project2-pipeline.yml`

### Why this workflow is standalone (not using the reusable engine)

The shared `_terraform-reusable.yml` engine doesn't know about workspaces or `-var-file`. Multi-environment deployment requires workspace selection on every `terraform` command. Rather than bending the reusable workflow to handle this special case, Project 02 has its own self-contained pipeline that makes the workspace + var-file logic explicit and readable.

---

## Branch promotion flow

```
feature branch
      │
      ▼  Pull Request → plan comment shows what dev will change
    dev ──────────────────────────────────► rg-dev-p2 in Azure
      │
      ▼  Pull Request to staging → plan comment shows what staging will change
  staging ─────────────────────────────► rg-staging-p2 in Azure
      │
      ▼  Pull Request to main → plan comment shows what prod will change
    main ─────── (manual approval gate) ──► rg-prod-p2 in Azure
```

The manual approval gate on `main` is configured via **GitHub Environments** (Repo → Settings → Environments → prod → Required Reviewers). The workflow pauses until a reviewer clicks Approve in the Actions tab.

---

## Variable validation

Every variable in `variables.tf` has a `validation` block. For example:

```hcl
variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}
```

This catches typos at `terraform plan` time — before anything touches Azure. If someone creates a `staging.tfvars` with `env = "stging"`, the plan fails immediately with a clear error message.

---

## How to deploy locally

```bash
cd project2-multi-env

# Initialise backend
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstateXXXX" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=project2.tfstate"

# Select (or create) the dev workspace
terraform workspace select dev || terraform workspace new dev

# Plan for dev
terraform plan -var-file=envs/dev.tfvars

# Deploy dev
terraform apply -var-file=envs/dev.tfvars -auto-approve

# Switch to prod and deploy
terraform workspace select prod || terraform workspace new prod
terraform apply -var-file=envs/prod.tfvars -auto-approve
```

---

## Secrets required

Same 7 secrets as Project 01 — no additional secrets needed.

---

## Concepts demonstrated

- **Terraform workspaces** — one backend, three isolated state files, zero risk of cross-env apply
- **Branch-based promotion** — dev → staging → prod mirrors the industry-standard GitFlow approach
- **tfvars per environment** — environment differences are configuration, not code
- **Variable validation** — modules fail fast with useful error messages instead of cryptic Azure errors
- **Production approval gates** — GitHub Environments prevent accidental prod deploys
- **`concurrency` groups** — prevents two deploys racing to the same environment simultaneously

---

## Cleanup

```bash
cd project2-multi-env

terraform workspace select dev
terraform destroy -var-file=envs/dev.tfvars -auto-approve

terraform workspace select staging
terraform destroy -var-file=envs/staging.tfvars -auto-approve

# Keep prod for screenshots, then:
terraform workspace select prod
terraform destroy -var-file=envs/prod.tfvars -auto-approve
```

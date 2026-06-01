# Project 01 — Azure Landing Zone

Full infrastructure-as-code deployment of a production-ready Azure landing zone using Terraform modules and GitHub Actions CI/CD.

---

## What this project provisions

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `rg-portfolio-dev` | Logical container for all resources |
| Virtual Network | `vnet-portfolio-dev` | Network isolation and connectivity |
| Subnet — app | `app-subnet` | Application workload traffic |
| Subnet — mgmt | `mgmt-subnet` | Management and admin traffic |
| Network Security Group | `nsg-portfolio-dev` | Inbound/outbound traffic rules |
| Storage Account | `stportfolioXXXX` | General-purpose blob storage |
| Key Vault | `kv-portfolio-dev` | Secrets and credentials management |

---

## Architecture

```
Azure Subscription
└── rg-portfolio-dev
    ├── vnet-portfolio-dev (10.0.0.0/16)
    │   ├── app-subnet  (10.0.1.0/24)  ←── NSG attached
    │   └── mgmt-subnet (10.0.2.0/24)  ←── NSG attached
    ├── stportfolioXXXX (Storage Account)
    └── kv-portfolio-dev (Key Vault)

State backend (manually provisioned, separate RG):
└── rg-tfstate
    └── sttfstateXXXX
        └── tfstate container
            └── landing-zone.tfstate
```

---

## Folder structure

```
project1-landing-zone/
├── main.tf          # resource group, storage account, key vault
├── variables.tf     # input variable declarations
├── outputs.tf       # resource names and IDs printed after apply
├── backend.tf       # remote state config (values injected by CI)
└── modules/
    └── networking/
        ├── main.tf      # VNet, subnets, NSG, associations
        ├── variables.tf
        └── outputs.tf
```

**Why a networking module?** Keeping VNet and NSG resources in a module makes them reusable — Project 02 calls the same module with different variable values. This is exactly how real teams share infrastructure patterns.

---

## CI/CD pipeline

Triggered by: any `.tf` file change inside `project1-landing-zone/`

```
Pull Request opened
       │
       ▼
  [validate]          ← terraform fmt -check + terraform validate
       │                 no Azure connection needed
       ▼
  [plan]              ← terraform plan
       │                 output posted as PR comment
       │                 reviewers see exactly what will change
       ▼
  PR merged to main
       │
       ▼
  [apply]             ← terraform apply -auto-approve
                         resources created/updated in Azure
```

**Workflow file:** `.github/workflows/project1-pipeline.yml`
**Engine:** `.github/workflows/_terraform-reusable.yml`

---

## Remote state

State is stored in Azure Blob Storage, not locally. This means:

- State is never committed to Git (no secrets in version control)
- Azure Blob provides automatic lease locking — two `apply` runs cannot corrupt each other
- The state backend is bootstrapped manually once and never managed by Terraform itself

```hcl
terraform {
  backend "azurerm" {
    # Values injected at runtime by GitHub Actions -backend-config flags
    # resource_group_name  = from BACKEND_RESOURCE_GROUP secret
    # storage_account_name = from BACKEND_STORAGE_ACCOUNT secret
    # container_name       = from BACKEND_CONTAINER secret
    # key                  = "landing-zone.tfstate"
  }
}
```

---

## How to deploy

### Local deployment

```bash
cd project1-landing-zone

# Initialise with remote backend
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstateXXXX" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=landing-zone.tfstate"

# Review changes
terraform plan -out=tfplan

# Deploy
terraform apply tfplan
```

### Via GitHub Actions

1. Create a branch from `main`
2. Make a change (e.g. add a tag to a resource)
3. Open a Pull Request → `validate` and `plan` run automatically
4. Review the plan comment on the PR
5. Merge → `apply` runs and resources appear in Azure Portal

---

## Secrets required

| Secret | Value |
|--------|-------|
| `ARM_CLIENT_ID` | Service Principal app ID |
| `ARM_CLIENT_SECRET` | Service Principal password |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure AD tenant ID |
| `BACKEND_RESOURCE_GROUP` | `rg-tfstate` |
| `BACKEND_STORAGE_ACCOUNT` | `sttfstateXXXX` |
| `BACKEND_CONTAINER` | `tfstate` |

---

## Concepts demonstrated

- **Infrastructure as Code** — entire landing zone defined in `.tf` files, version-controlled, repeatable
- **Terraform modules** — networking resources extracted and reused across projects
- **Remote state** — Azure Blob Storage backend with lease locking prevents state corruption
- **Plan-on-PR / apply-on-merge** — standard GitOps pattern used in production teams
- **Least-privilege Service Principal** — GitHub Actions authenticates with a scoped SP, not owner credentials
- **Path filtering** — CI only triggers when this project's files change, not on unrelated repo activity

---

## Cleanup

```bash
cd project1-landing-zone
terraform destroy -auto-approve
# Keep rg-tfstate — the state backend is shared across all projects
```

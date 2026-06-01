# Azure Landing Zone — Portfolio

A hands-on cloud engineering portfolio built with **Terraform** and **GitHub Actions**, demonstrating real-world Azure infrastructure automation across five progressively advanced projects.

Each project is a standalone, deployable piece of infrastructure with its own CI/CD pipeline, remote state, and documentation. Together they cover the core skills expected of a junior to mid-level Cloud/DevOps Engineer.

---

## Projects

| # | Project | What it demonstrates | Cost |
|---|---------|----------------------|------|
| [01](./project1-landing-zone/) | Azure Landing Zone — full IaC | Terraform modules, remote state, plan-on-PR / apply-on-merge | ~₹5/mo |
| [02](./project2-multi-env/) | Multi-environment deployment | Terraform workspaces, branch-based promotion, tfvars per env | ~₹10/mo |
| [03](./project3-monitoring/) | Live portfolio site — Azure Blob + CDN | Static website hosting, CDN, dual-pipeline CI/CD (infra + content) | ~₹5/mo |
| [04](./project4-governance/) | Governance — Azure Policy + RBAC | Custom policy definitions, policy initiative, least-privilege RBAC | Free |
| [05](./project5-cicd/) | Reusable Terraform module library | Module design, variable validation, versioned releases | Free |

---

## Repository structure

```
azure-landing-zone/
├── .github/
│   └── workflows/
│       ├── _terraform-reusable.yml   # shared CI/CD engine (validate → plan → apply)
│       ├── project1-pipeline.yml
│       ├── project2-pipeline.yml
│       ├── project3-infra.yml
│       ├── project3-deploy.yml
│       ├── project4-pipeline.yml
│       └── project5-pipeline.yml
├── modules/                          # shared local Terraform modules
│   └── networking/                   # VNet + NSG module used by P1 and P2
├── project1-landing-zone/
├── project2-multi-env/
├── project3-monitoring/
├── project4-governance/
├── project5-cicd/
└── README.md
```

---

## CI/CD design

All projects share a reusable workflow engine (`.github/workflows/_terraform-reusable.yml`). Each project has its own lightweight caller file that passes the project name, working directory, and backend key. This means the CI/CD logic lives in one place — fix a bug once, it applies to all projects.

```
project1-pipeline.yml ──┐
project2-pipeline.yml ──┤
project3-infra.yml    ──┼──► _terraform-reusable.yml
project4-pipeline.yml ──┤        validate → plan → apply
project5-pipeline.yml ──┘
```

**Workflow behaviour:**

- **Pull Request** → `validate` + `plan` run; plan output is posted as a PR comment
- **Push to main** → `validate` + `apply` run; infrastructure is updated in Azure
- **Path filtering** → each workflow only triggers when its own project folder changes

---

## Prerequisites

### 1. Azure remote state backend

Before any Terraform can run, create the state backend manually (one time only):

```bash
az group create --name rg-tfstate --location eastus

az storage account create \
  --name sttfstateXXXX \
  --resource-group rg-tfstate \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name sttfstateXXXX
```

### 2. Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-tf-portfolio" \
  --role Contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth
```

### 3. GitHub Secrets

Add these in **Repo → Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `ARM_CLIENT_ID` | Service Principal app ID |
| `ARM_CLIENT_SECRET` | Service Principal password |
| `ARM_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `ARM_TENANT_ID` | Your Azure AD tenant ID |
| `BACKEND_RESOURCE_GROUP` | Resource group holding the state storage account |
| `BACKEND_STORAGE_ACCOUNT` | Storage account name for remote state |
| `BACKEND_CONTAINER` | Blob container name (e.g. `tfstate`) |

---

## Key concepts demonstrated

**Terraform**
- Remote state in Azure Blob Storage with lease locking
- Modular design — networking resources extracted into a reusable module
- Terraform workspaces for environment isolation
- Variable validation to fail fast with useful error messages
- `locals` for DRY resource naming across environments

**GitHub Actions**
- Reusable workflows (`workflow_call`) to avoid copy-paste CI/CD
- Path filtering so only the relevant project pipeline triggers
- Plan output posted as PR comments for reviewer visibility
- `concurrency` groups to prevent simultaneous deploys to the same environment
- GitHub Environments with required reviewer approval gates for production

**Azure**
- Least-privilege Service Principal scoped to the subscription
- Resource Groups, Virtual Networks, Subnets, NSGs, Storage Accounts, Key Vault
- Azure Blob static website hosting with CDN for global delivery
- Azure Policy and RBAC for governance enforcement

---

## Certifications

- **AZ-104** — Microsoft Azure Administrator
- **HashiCorp Terraform Associate**

---

## Author

**Mtukare** · [GitHub](https://github.com/mtukare) · [Live Portfolio](https://portfolio-endpoint.azureedge.net)

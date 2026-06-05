# Project 03 — Live Portfolio Site (Azure Blob + CDN)

A static portfolio website automatically deployed to **Azure Blob Storage** with **Azure CDN** for global delivery. Infrastructure provisioned by Terraform. Content deployed by a dedicated GitHub Actions pipeline on every push.

**Live site:** (https://stportfoliomtukare.z13.web.core.windows.net/)
#((https://portfolio-endpoint-abheh9gtanhqguby.z01.azurefd.net) :- After the test on CDN this was deleted to keep the cost down.

---

## What this project provisions

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `rg-portfolio-site` | Container for all site resources |
| Storage Account | `stportfoliomtukare` | Hosts the static website files |
| Blob Container | `$web` | Azure's special container for static website hosting |
| CDN Profile | `cdn-portfolio` | CDN management layer (Standard Microsoft tier) |
| CDN Endpoint | `portfolio-endpoint` | Public-facing URL pointing to the storage origin |

---

## Architecture

```
Visitor's browser
       │
       ▼
[https://portfolio-endpoint.azureedge.net ](https://portfolio-endpoint-abheh9gtanhqguby.z01.azurefd.net)  
       │
       ▼
Azure CDN (Standard Microsoft)
  · Global edge caching
  · Automatic HTTPS
  · Cache purged on every deploy
       │
       ▼
Azure Blob Storage — static website
  · $web container
  · index.html served at /
  · 404.html served on missing routes
       │
  origin: stportfoliomtukare.z13.web.core.windows.net
```

**Why CDN in front of Blob Storage?** The storage URL is long and ugly. The CDN gives you a clean `azureedge.net` URL, caches content at edge nodes globally (fast for visitors anywhere), and handles HTTPS automatically.

---

## Folder structure

```
project3-monitoring/
├── main.tf          # Storage Account + CDN Profile + CDN Endpoint
├── variables.tf     # storage account name, location, etc.
├── outputs.tf       # prints CDN URL + storage URL after apply
├── backend.tf       # remote state config (blank — values injected by CI)
└── site/
    ├── index.html   # portfolio page — your name, certs, projects
    └── 404.html     # error page
```

The `site/` subfolder is intentional — it separates HTML content from Terraform code, and it's what the deploy pipeline uploads to Azure.

---

## Two pipelines, two responsibilities

This project uses two separate workflow files:

### Pipeline 1 — Infrastructure (`project3-infra.yml`)

Triggered by changes to `*.tf` or `*.tfvars` files.

```
Pull Request with .tf changes
       │
       ▼
  [validate] ──► [plan]     ← plan comment shows what Azure resources will change
                                
Push to main with .tf changes
       │
       ▼
  [validate] ──► [apply]    ← Storage Account + CDN created/updated in Azure
```

Run this pipeline first — it creates the Azure infrastructure before any files can be uploaded.

### Pipeline 2 — Content deploy (`project3-deploy.yml`)

Triggered by changes to `site/**` files only.

```
Push to main with site/ changes
       │
       ▼
  [Azure Login]
       │
       ▼
  [az storage blob upload-batch]   ← uploads all files from site/ to $web container
       │
       ▼
  [az cdn endpoint purge]          ← flushes CDN cache so changes appear immediately
       │
       ▼
  Prints live URL to Actions log ✅
```

**Why two pipelines?** Changing a Terraform resource (e.g. CDN SKU) should not re-upload your HTML. Changing `index.html` should not re-run `terraform apply`. Separating them means each pipeline only runs when its own files change — faster, cleaner, less risk.

---

## CDN cache purge — why it matters

After uploading new HTML files, the CDN still serves the **old cached version** to visitors. Without a cache purge, your changes can take up to 4 hours to appear on the CDN URL. The deploy pipeline runs:

```bash
az cdn endpoint purge \
  --resource-group rg-portfolio-site \
  --profile-name cdn-portfolio \
  --name portfolio-endpoint \
  --content-paths "/*"
```

This tells all CDN edge nodes worldwide: discard your cached copies and fetch fresh files from origin. Changes appear within 1–2 minutes of the pipeline completing.

---

## How to deploy

### Step 1 — Run the infra pipeline first

Push any `.tf` change to `main` → `project3-infra.yml` runs → Storage Account and CDN are created in Azure.

After apply, the Actions log prints:
```
cdn_endpoint_url   = "https://portfolio-endpoint.azureedge.net"
storage_web_url    = "https://stportfoliomtukare.z13.web.core.windows.net"
storage_account_name = "stportfoliomtukare"
```

### Step 2 — Deploy the site content

Push any change to `site/index.html` → `project3-deploy.yml` runs → HTML files uploaded to `$web` container → CDN cache purged → site is live.

### Step 3 — Test the demo flow

Edit `index.html` locally → push to main → watch the deploy pipeline run in GitHub Actions → visit the CDN URL → see your change live. This is the interview demo moment.

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
| `PORTFOLIO_STORAGE_ACCOUNT` | `stportfoliomtukare` (used by the deploy pipeline) |

---

## Concepts demonstrated

- **Terraform-managed CDN** — CDN profile and endpoint provisioned as code, not via Portal clicks
- **Azure static website hosting** — `$web` container pattern, index/404 document configuration
- **Dual-pipeline CI/CD** — infra pipeline and content deploy pipeline with separate `paths:` triggers
- **CDN cache invalidation** — automated purge on every deploy, no stale content
- **Separation of concerns** — Terraform manages infrastructure; `az cli` manages content upload
- **Live URL for portfolio** — a real, publicly accessible URL to put on your resume and LinkedIn

---

## Cleanup

```bash
cd project3-monitoring
terraform destroy -auto-approve
# This deletes the Storage Account and CDN — the live URL will stop working
```

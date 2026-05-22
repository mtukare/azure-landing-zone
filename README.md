# azure-landing-zone

---

# 🚀 Azure Landing Zone with Terraform & GitHub Actions

This project provisions a basic Azure landing zone using **Terraform modules**, **remote state in Azure Storage**, and **GitHub Actions CI/CD**.

---

## 📦 What It Provisions
- Resource Group
- Virtual Network with 2 subnets (app + mgmt)
- Network Security Group with inbound/outbound rules
- Storage Account
- Key Vault

---

## 🛠️ Key Concepts
- **Terraform Modules** → Networking module for VNet + NSG
- **Remote State** → Azure Blob Storage with lease locking
- **CI/CD** → GitHub Actions workflow (plan on PR, apply on merge)
- **Security** → Least‑privilege Service Principal for automation

---

## ⚙️ How to Deploy
1. Clone this repo  
2. Configure `backend.tf` with your storage account details  
3. Add GitHub secrets (`AZURE_CREDENTIALS`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`)  
4. Push changes →  
   - **Pull Request** → runs `terraform plan` and posts output as PR comment  
   - **Merge to main** → runs `terraform apply`  

---

## 🖼️ Architecture Diagram

![Azure Terraform Architecture](https://copilot.microsoft.com/th/id/BCO.6701437d-fe99-4ed7-9c44-2f6c6a41b913.png)

## 📋 Resource Summary

| Resource Type | Name Example | Purpose | Provisioned By |
|----------------|--------------|----------|----------------|
| Resource Group | `rg-portfolio-dev` | Logical container for all resources | Terraform |
| Virtual Network | `vnet-portfolio-dev` | Provides network isolation and connectivity | Terraform (module: networking) |
| Subnets | `app-subnet`, `mgmt-subnet` | Separate application and management traffic | Terraform (module: networking) |
| Network Security Group | `nsg-portfolio-dev` | Controls inbound/outbound traffic rules | Terraform (module: networking) |
| Storage Account | `stportfolioXXXX` | Hosts remote Terraform state | Manual (backend.tf configured) |
| Blob Container | `tfstate` | Stores Terraform state file with lease locking | Manual |
| Key Vault | `kv-portfolio-dev` | Stores secrets and credentials securely | Terraform |
| Service Principal | `sp-tf-portfolio` | Provides least‑privilege access for GitHub Actions | Azure CLI |
| GitHub Actions Workflow | `.github/workflows/terraform.yml` | Automates plan/apply pipeline | GitHub Actions |

---

### 🧠 Highlights
- **Remote state** stored securely in Azure Blob with lease locking  
- **Modular design** for networking and security  
- **CI/CD automation** via GitHub Actions (plan on PR, apply on merge)  
- **Least‑privilege principle** enforced through Service Principal  


## 🧹 Cleanup
```bash
terraform destroy -auto-approve

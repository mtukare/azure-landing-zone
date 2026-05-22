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

## 🧹 Cleanup
```bash
terraform destroy -auto-approve

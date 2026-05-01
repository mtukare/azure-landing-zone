# azure-landing-zone
Portfolio
# Azure Landing Zone with Terraform + GitHub Actions

This project provisions a basic Azure landing zone using Terraform modules and GitHub Actions CI/CD.  
It demonstrates remote state management, modular design, and automated plan/apply workflows — ideal for showcasing cloud automation skills to recruiters.

---

## 📐 Architecture Diagram
![Architecture Diagram](docs/architecture.png)

**Components:**
- Resource Group
- Virtual Network with 2 subnets (app + mgmt)
- Network Security Group with rules
- Storage Account
- Key Vault

---

## 🚀 Features
- Remote state stored in Azure Blob with lease locking
- Modular Terraform design (`modules/networking`)
- GitHub Actions workflow: plan on PR, apply on merge
- Least‑privilege Service Principal for CI/CD

---

## 🛠️ Prerequisites
- Azure subscription
- Azure CLI installed
- Terraform installed
- GitHub account

---

## ⚙️ Setup Instructions
1. **Clone this repo**
   ```bash
   git clone https://github.com/<your-username>/azure-landing-zone.git
   cd azure-landing-zone

# Azure Cloud Solution – Infra & Bootstrap Scripts

![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)
![.NET](https://img.shields.io/badge/.NET-API-purple?logo=dotnet)
![Bash](https://img.shields.io/badge/Shell-Bash-black?logo=gnubash)
![Status](https://img.shields.io/badge/Status-Active-success)

Automated Azure infrastructure setup for a full-stack Web API solution using **Azure App Service, SQL Database, Key Vault, Application Insights, Storage, and Azure DevOps CI/CD**.

This project is split into two scripts:

- `bootstrap.sh` → environment + DevOps setup
- `infra.sh` → full Azure infrastructure provisioning

## 📦 Project Structure

```
.
├── bootstrap.sh # Environment + Azure DevOps setup
├── infra.sh # Azure infrastructure provisioning
├── README.md
└── app/ # (optional) .NET Web API project
```

## 🚀 What This Setup Creates

The scripts automatically provision:

- Azure App Service (Web API hosting)
- App Service Plan
- Azure SQL Server + Database (Entity Framework ready)
- Application Insights (monitoring & logging)
- Azure Storage Account (blob/static files)
- Azure Key Vault (secure secrets storage)
- Managed Identity integration
- Firewall rules & HTTPS enforcement
- Azure DevOps CI/CD pipeline support

## 🧭 Architecture Overview

```
Client
↓
Azure App Service (Web API)
↓
SQL Database (Azure SQL)
↓
Key Vault (Secrets)
↓
Application Insights (Monitoring)
↓
Storage Account (Blobs)
```

## ⚙️ Prerequisites

Before running the scripts:

- Azure CLI installed
- Logged in:
  ```bash
  az login
  ```
- Azure DevOps extension:
  ```
  az extension add -n azure-devops
  ```
- Proper Azure subscription permissions
- Bash shell (macOS / Linux / WSL)

## 🛠️ Setup Instructions

---

### 1. Deploy Infrastructure

Provision all Azure resources:

```
chmod +x infra.sh
./infra.sh
```

What it does:

- Creates Resource Group
- Deploys App Service + Plan
- Creates SQL Server + Database
- Configures firewall rules
- Sets up Application Insights
- Creates Storage Account
- Provisions Key Vault
- Assigns Managed Identity permissions
- Injects secrets into App Service

---

### 2. Bootstrap Environment

Initial setup of environment variables and Azure DevOps configuration:

```
chmod +x bootstrap.sh
./bootstrap.sh
```

What it does:

- Configures Azure DevOps organization & project
- Defines naming conventions
- Prepares environment variables
- Initializes project structure

## 🔐 Security Features

- HTTPS enforced on App Service
- SQL firewall IP restrictions
- Secrets stored in Azure Key Vault
- Managed Identity authentication (no passwords in code)
- Environment-based configuration

## 🔄 CI/CD Pipeline (Azure DevOps)

Supports automated deployment

Pipeline stages:

- Build (.NET Web API)
- Publish artifacts
- Deploy to Azure App Service

## 🧪 Example Variables

Defined in bootstrap.sh:

```bash
ORG="your-org"
PROJECT="your-project"
ENV="prod"
REGION="swedencentral"

PREFIX="${ORG}-${PROJECT}-${ENV}"

APP_NAME="${PREFIX}-app"
APP_PLAN="${PREFIX}-plan"

SQL_SERVER_NAME="${ORG}${PROJECT}${ENV}sql"
SQL_DB_NAME="${PROJECT}-${ENV}"

KV_NAME="${PREFIX}-kv"
STORAGE_NAME="${ORG}${PROJECT}${ENV}sa"
```

## 📊 Monitoring

Application Insights provides:

- Request tracking
- Performance metrics
- Live logs
- Failure diagnostics

Query example:

```kusto
requests| order by timestamp desc
```

## 🧹 Cleanup

To avoid unnecessary costs:

```
./cleanup.sh
```

## 📌 Notes

- Fully automated infrastructure (Infrastructure as Code via Azure CLI)
- Designed for reuse across multiple environments (dev/test/prod)
- No manual Azure portal configuration required
- Optimized for student lab + production-like setup

## 📜 License

For educational use.

## 👨‍💻 Author

Built as part of an Azure cloud deployment lab project.

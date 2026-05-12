# Azure Cloud Solution Script – Automated Infrastructure & CI/CD

![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)
![.NET](https://img.shields.io/badge/.NET-8-purple?logo=dotnet)
![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-CI%2FCD-0078D7?logo=azuredevops)
![Status](https://img.shields.io/badge/Status-Active-success)

Automated Azure infrastructure and deployment setup for a .NET Web API using:

- Azure App Service
- Azure SQL Database
- Azure Key Vault
- Application Insights
- Azure Storage Account
- Azure DevOps CI/CD
- Docker (local development)

The project is designed as a reusable cloud deployment template using Azure CLI and Bash scripting.

---

## 📦 Project Structure

```txt
.
├── modules
├── templates
├── bootstrap.sh
├── config.sh
├── deploy.sh
├── destroy.sh
└── README.md
```

## 🚀 What This Setup Creates

The scripts automatically provisions:

- Azure Resource Group
- Azure App Service (Web API hosting)
- App Service Plan
- Azure SQL Server
- Azure SQL Database
- Application Insights
- Azure Storage Account
- Azure Key Vault
- Managed Identity
- Azure DevOps CI/CD pipeline support

## 🧭 Architecture Overview

```
Client
↓
Azure App Service (Web API)
↓
Azure SQL Database (Azure SQL)
↓
Azure Key Vault (Secrets)
↓
Application Insights (Monitoring)
↓
Azure Storage Account (Blobs)
```

## 🚀 Features

### Infrastructure as Code

All Azure resources are created through Azure CLI scripts.

#### CI/CD

Deployment is automated through Azure DevOps pipelines.

#### Secure Configuration

Secrets stored in Azure Key Vault
Managed Identity authentication
No secrets committed to source control
HTTPS enforced

#### Local Development Environment

Docker-based SQL Server environment for local development.

### Environment Separation

Supports multiple environments:

- dev
- prod

## ⚙️ Prerequisites

Install:

- Azure CLI
- Azure DevOps extension
- Docker Desktop
- .NET 10 SDK
- Bash shell

## 🔐 Login & Azure DevOps Setup

- Login to Azure:

  ```bash
  $ az login
  ```

- Install Azure DevOps extension::
  ```
  $ az extension add -n azure-devops
  ```

## 🛠️ Usage

### Bootstrap Project

Initializes Azure DevOps configuration and project setup.

```bash
$ chmod +x cloud-cli
$ ~/cloud-cli/index.sh bootstrap --name <my-project> --env prod
```

Start local development environment

```bash
$ cd <my-project>

$ chmod +x start-dev.sh # Allow script usage
$ ./start-dev.sh # Create docker container
```

Create and apply initial Entity Framework migrations

```bash
$ cd <my-project>

$ dotnet ef migrations add InitialCreate # Add migration
$ ./start-dev.sh # Run again to migrate
```

Creates:

- New ASP.Net Project
- Installs NuGet packages
- Creates start-up script
- Creates docker-compose.yml
- Creates azure.pipelines.yml
- Naming conventions
- Initial variables
- Initial User Secrets

## Deploy Infrastructure

Deploy all Azure resources:

```bash
$ cd <your-project>

$ ~/cloud-cli/index.sh deploy --name <my-project> --env prod
```

Add service connection:

Go to: `https://dev.azure.com/<my-organization>/<my-project>/\_settings/` -> Pipelines -> Service connections -> Create service connection

**Select:**

- Service connection type: Azure Resource Manager
- Subscription: <my-subscription>
- Resource Group: <my-resouce-group>
- Service Connection Name: `<my-project>-connection`

Run the script again to complete the setup:

```bash
$ ~/cloud-cli/index.sh deploy --name <my-project> --env prod
```

Creates:

- Resource Group
- App Service
- SQL Database
- Storage Account
- Key Vault
- Application Insights
- Managed Identity permissions
- Azure DevOps project configuration
- Runs the pipeline

## Destroy Infrastructure and Project

Remove Azure resources to avoid unnecessary costs and removes Azure DevOps project

```bash
$ ~/cloud-cli/index.sh destroy --name <my-project> --env prod
```

## 🔐 Security

Implemented security features:

- HTTPS only
- Managed Identity
- Azure Key Vault secret references
- SQL firewall rules
  - App Service IP restrictions
- Environment variable isolation
- No hardcoded secrets

Only approved IP addresses are allowed to access the Azure App Service.
IP restrictions are configured through Azure CLI during deployment.

## 📊 Monitoring

Application Insights provides:

- Request tracking
- Exception logging
- Performance monitoring
- Live metrics
- Distributed tracing

Example Kusto query:

```
requests
| order by timestamp desc
```

## 🔄 Azure DevOps Pipeline

Pipeline handles:

1. Build
2. Publish
3. Deploy to Azure App Service

Example stages:

```txt
Build → Test → Publish → Deploy
```

### ⚠️ Manual Pipeline Approval

The Azure DevOps pipeline requires a one-time manual approval after setup. This is required at the following stages:

- Apply_Migration
- Deploy

In Azure DevOps:

```txt
Pipelines → <my-pipeline> → <run> → <pending-stage>
```

## 📁 Storage Account Usage

Azure Storage Account is used for:

- Static assets
- File uploads
- Log storage
- Backup-related resources

## 📚 Technologies

.NET 10
ASP.NET Core Web API
Entity Framework Core
Azure CLI
Azure App Service
Azure SQL
Azure Key Vault
Azure DevOps
Docker
Bash

## 📌 Notes

- Designed to be reusable across multiple projects
- Minimal manual Azure portal configuration required
- Optimized for both learning and production-like workflows

## 📜 License

For educational use.

## 👨‍💻 Author

Built as part of an Azure cloud deployment lab project.

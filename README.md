# Azure Cloud Solution – Infra & Bootstrap Scripts

This repository contains scripts for automatically setting up and managing a complete Azure cloud solution for a Web API application.

The setup includes infrastructure provisioning, deployment configuration, and integration with Azure DevOps, Key Vault, Application Insights, and SQL Database.

## Overview

The solution is split into two main scripts:

### `bootstrap.sh`

Initial setup script that prepares your environment.

Responsibilities:

- Azure CLI authentication
- Azure DevOps configuration
- Creating or configuring project structure
- Defining shared environment variables
- Preparing naming conventions and resource prefixes

### `infra.sh`

Main infrastructure provisioning script that creates all Azure resources.

Responsibilities:

- Resource Group setup
- App Service Plan & Web App
- SQL Server & Database
- Application Insights
- Storage Account
- Azure Key Vault
- Firewall rules & security configuration
- Managed Identity setup
- App settings configuration
- (Optional) deployment preparation

## Architecture Components

The scripts provision the following Azure services:

- Azure App Service (Web API hosting)
- App Service Plan
- Azure SQL Server + Database (Entity Framework support)
- Application Insights (logging & monitoring)
- Azure Storage Account (static files / blobs)
- Azure Key Vault (secure secrets storage)
- Azure DevOps integration (CI/CD pipeline support)

## Prerequisites

Before running the scripts, make sure you have:

- Azure CLI installed (az)
- Logged into Azure (az login)
- Azure DevOps extension installed:

  ```bash
  az extension add -n azure-devops
  ```

- Appropriate Azure subscription permissions
- Bash-compatible shell (Linux / macOS / WSL)

## Setup Flow

### 1. Run Bootstrap Script

This prepares your environment and global configuration:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Typical actions:

- Sets organization, project, environment variables
- Configures Azure DevOps defaults
- Defines naming conventions for resources

### 2. Deploy Infrastructure

After bootstrap is complete:

```bash
chmod +x infra.sh
./infra.sh
```

This will:

- Create all Azure resources
- Configure SQL Server + firewall rules
- Generate connection strings
- Store secrets in Key Vault
- Configure App Service settings
- Enable Application Insights
- Set up Managed Identity permissions

## Key Variables

These are commonly defined in bootstrap.sh:

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

## Security Setup

The infrastructure includes:

- HTTPS enforcement on App Service
- IP firewall restrictions for SQL Server
- Azure Key Vault for secrets management
- Managed Identity authentication between App Service and Key Vault

## Deployment (CI/CD)

The project supports Azure DevOps pipelines:

- Build stage compiles and publishes the .NET API
- Deploy stage deploys to Azure App Service
- Uses Service Connection for authentication

## Notes

- All infrastructure is fully scripted using Azure CLI
- No manual setup is required after bootstrap
- Designed for repeatable deployments across environments (dev/test/prod)

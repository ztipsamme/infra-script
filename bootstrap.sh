#!/bin/bash
set -e

read -p "Project name: " PROJECT

echo "Creating .NET project..."
dotnet new webapi -n $PROJECT
cd $PROJECT

echo "Adding packages..."
dotnet add package Microsoft.ApplicationInsights.AspNetCore
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design

echo "Setting up user secrets..."
if [ ! -f .env ]; then
  echo ".env file not found. Run infra.sh first."
  exit 1
fi

source .env
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "$DB_CONN_STRING"
dotnet user-secrets set "APPLICATIONINSIGHTS_CONNECTION_STRING" "$INSIGHTS_CONN_STRING"

echo "Initializing git..."
git init
git branch -M main

echo "Creating Azure DevOps project..."
az devops project create --name $PROJECT --visibility private

SSH_URL=$(az repos show --repository $PROJECT --project $PROJECT --query "sshUrl" -o tsv)

git remote add origin $SSH_URL
git add .
git commit -m "Initial commit"
git push -u origin main
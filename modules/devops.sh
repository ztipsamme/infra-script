#!/bin/bash
set -e

setup_devops(){
  echo "⚙️ Setting up Azure DevOps..."
  
  az devops configure --defaults organization=https://dev.azure.com/$ORG/ 

  echo "📁 Creating project..."
  if az devops project show --project "$PROJECT" &>/dev/null; then
    echo "📁 Project already exists, skipping..."
  else
    az devops project create --name "$PROJECT" --visibility private
  fi

  echo "⏳ Waiting for project..."
  until az devops project show --project $PROJECT &>/dev/null; do
    sleep 5
  done

  az devops configure --defaults project=$PROJECT

  echo "📦 Setting up repo..."
  if ! az repos show --repository $PROJECT --project $PROJECT &>/dev/null; then
    az repos create --name $PROJECT --project $PROJECT
  else
    echo "📁 Repo already exists, skipping..."
  fi

  echo "🔐 Setting Key Vault access..."
  SPN_OBJECT_ID=$(az devops service-endpoint list --project $PROJECT \
  --query "[?name=='${PROJECT}-connection'].data.spnObjectId" -o tsv)

  az role assignment create \
  --assignee $SPN_OBJECT_ID \
  --role "Key Vault Secrets User" \
  --scope $(az keyvault show -n $KEYVAULT_NAME -g $RESOURCE_GROUP --query id -o tsv)

  echo "✅ DevOps setup complete"
}
#!/bin/bash
set -e

echo "💣 DestroyingAzure infrastructure: $ENV"

az resource list \
  -g $RESOURCE_GROUP \
  -o table

az webapp delete \
  -g $RESOURCE_GROUP \
  -n $APP_NAME
az appservice plan delete \
  -g $RESOURCE_GROUP \
  -n $APP_PLAN \
  -y

az sql db delete \
  -g $RESOURCE_GROUP \
    -s $SQL_SERVER_NAME \
  -n $SQL_DB_NAME \
  -y
az sql server delete \
  -g $RESOURCE_GROUP \
  -n $SQL_SERVER_NAME \
  -y

az monitor app\
  -insights component delete \
  -g $RESOURCE_GROUP \
  -a $APP_INSIGHT_NAME

az storage account delete \
  -g $RESOURCE_GROUP \
  -n $STORAGE_NAME \
  -y

az keyvault delete \
  -g $RESOURCE_GROUP \
  -n $KEYVAULT_NAME

az resource list \
  -g $RESOURCE_GROUP \
  -o table

PROJECT_ID=$(az devops project show \
  --project $PROJECT \
  --query id \
  -o tsv)

az devops project delete \
  --id $PROJECT_ID \
  -y

az devops project list \
  --output table
  
echo "✅ Infra cleanup complete ($ENV)"
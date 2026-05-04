#!/bin/bash

# === VARIABLES ===

# === GLOBAL CONFIG ===
ORG="emmaspitz"
ENV="prod"
REGION="swedencentral"
RESOURCE_GROUP="RG-Emma-Spitz-a59389-DotNetCloudDeveloper-VT-Mars-Goteborg"

# === INPUT ===
# read -p "Project name: " PROJECT
# read -p "Admin username: " ADMIN_USER
# read -p "Admin password: " ADMIN_PASSWORD
PROJECT="labb2"
ADMIN_USER="adminUser"
ADMIN_PASSWORD="MyStrongPassword1234"

# === NAMING ===
PREFIX="${ORG}-${PROJECT}-${ENV}"

APP_NAME="${PREFIX}-app"
APP_PLAN="${PREFIX}-plan"

SQL_SERVER_NAME="${ORG}${PROJECT}${ENV}sql"
SQL_DB_NAME="${PROJECT}-${ENV}"

APP_INSIGHT_NAME="${PREFIX}-ai"

### Storage account (NO DASHES)
STORAGE_NAME="${ORG}${PROJECT}${ENV}sa"

KV_NAME="${PREFIX}-kv"
echo $KV_NAME

KV_DefaultConnection_NAME="DefaultConnection"
KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME="ApplicationInsightsConnection"

# === HELPERS ===
set -euo pipefail
log() {
  echo ""
  echo "=== $1 ==="
}

exists_rg () {
  az group show -n "$1" &>/dev/null
}

exists_app () {
  az webapp show -g "$1" -n "$2" &>/dev/null
}

exists_sql () {
  az sql server show -g "$1" -n "$2" &>/dev/null
}

exists_kv () {
  az keyvault show -g "$1" -n "$2" &>/dev/null
}

exists_ai () {
  az monitor app-insights component show -g "$1" --app "$2" &>/dev/null
}

exists_sa () {
  az storage account show -g "$1" -n "$2" &>/dev/null
}

# === KEY VAULT ===
setup_keyvault(){
  log "Setting up Key Vault..."

if ! exists_kv $RESOURCE_GROUP $KV_NAME; then
    az keyvault create \
      -n $KV_NAME \
      -g $RESOURCE_GROUP \
      -l $REGION
  fi

  USER_ID=$(az ad signed-in-user show --query id -o tsv)

  az role assignment create \
    --assignee $USER_ID \
    --role "Key Vault Administrator" \
    --scope $(az keyvault show -n $KV_NAME -g $RESOURCE_GROUP --query id -o tsv) \
    2>/dev/null || true
}

# === APP SERVICE ===
setup_appservice(){
  log "Setting up App Service..."

  if ! exists_app $RESOURCE_GROUP $APP_NAME; then
      az appservice plan create \
        -n $APP_PLAN \
        -g $RESOURCE_GROUP \
        --sku F1 \
        -l $REGION
  fi

  if ! exists_app $RESOURCE_GROUP $APP_NAME; then
      az webapp create \
        -n $APP_NAME \
        -g $RESOURCE_GROUP \
        -p $APP_PLAN
  fi

  PRINCIPAL_ID=$(az webapp identity assign -g $RESOURCE_GROUP -n $APP_NAME --query principalId -o tsv)

  az role assignment create \
    --assignee $PRINCIPAL_ID \
    --role "Key Vault Secrets User" \
    --scope $(az keyvault show -n $KV_NAME -g $RESOURCE_GROUP --query id -o tsv) \
    2>/dev/null || true

  az webapp update \
    -g $RESOURCE_GROUP \
    -n $APP_NAME --https-only true
}


# === SQL ===
setup_sql() {
  log "Setting up SQL..."

  # CREATE 
  if ! exists_sql $RESOURCE_GROUP $SQL_SERVER_NAME; then
      az sql server create \
        -l $REGION \
        -g $RESOURCE_GROUP \
        -n $SQL_SERVER_NAME \
        -u $ADMIN_USER \
        -p $ADMIN_PASSWORD
  fi

  if ! az sql db show -g $RESOURCE_GROUP -s $SQL_SERVER_NAME -n $SQL_DB_NAME &>/dev/null; then
    az sql db create \
      -g $RESOURCE_GROUP \
      -s $SQL_SERVER_NAME \
      -n $SQL_DB_NAME \
      --service-objective Basic
  fi

  DB_CONN_STRING=$(az sql db show-connection-string -s $SQL_SERVER_NAME -n $SQL_DB_NAME -c ado.net --output tsv)
  DB_CONN_STRING=${DB_CONN_STRING//<username>/$ADMIN_USER}
  DB_CONN_STRING=${DB_CONN_STRING//<password>/$ADMIN_PASSWORD}

  export DB_CONN_STRING

  az keyvault secret set \
    --vault-name $KV_NAME \
    --name $KV_DefaultConnection_NAME \
    --value "$DB_CONN_STRING"

  az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
    "ConnectionStrings__DefaultConnection=@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/$KV_DefaultConnection_NAME/)"

  MY_IP=$(curl ipinfo.io/ip)
  az sql server firewall-rule create \
    -g $RESOURCE_GROUP \
    -s $SQL_SERVER_NAME \
    -n AllowMyIP \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP \
    2>/dev/null || true
}

# === APPLICATION INSIGHTS ===
setup_appinsights(){
  log "Setting up Application Insights..."

  if ! exists_ai $RESOURCE_GROUP $APP_INSIGHT_NAME; then
      az monitor app-insights component create --app $APP_INSIGHT_NAME -l $REGION -g $RESOURCE_GROUP --application-type web
  fi

  INSIGHTS_CONN_STRING=$(az monitor app-insights component show --app $APP_INSIGHT_NAME -g $RESOURCE_GROUP --query connectionString -o tsv)

  export INSIGHTS_CONN_STRING

  az webapp config appsettings set -n $APP_NAME -g $RESOURCE_GROUP --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$INSIGHTS_CONN_STRING"

  az keyvault secret set \
    --vault-name $KV_NAME \
    --name $KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME \
    --value $INSIGHTS_CONN_STRING

  az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/$KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME/)"
}


# === STORAGE ACCOUNT ===
setup_storage(){
  log "Setting up Storage..."

  if ! exists_sa $RESOURCE_GROUP $STORAGE_NAME; then
    az storage account create \
      -n $STORAGE_NAME \
      -g $RESOURCE_GROUP \
      -l $REGION \
      --allow-blob-public-access false \
      --sku Standard_LRS
  fi

  STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_NAME --query "[0].value" -o tsv)

  read -p "Storage container name [images]: " STORAGE_CONTAINER_NAME
  STORAGE_CONTAINER_NAME=${STORAGE_CONTAINER_NAME:-images}

  az storage container create \
    --account-name $STORAGE_NAME \
    -n $STORAGE_CONTAINER_NAME \
    --account-key $STORAGE_KEY \
    --public-access off \
    2>/dev/null || true
}


main() {
  if ! exists_rg $RESOURCE_GROUP; then
    az group create -n $RESOURCE_GROUP -l $REGION
  fi

  setup_keyvault
  setup_appservice
  setup_sql
  setup_appinsights
  setup_storage
}

main

echo "DB_CONN_STRING: $DB_CONN_STRING"
echo "INSIGHTS_CONN_STRING: $INSIGHTS_CONN_STRING"

echo "Saving environment variables to .env..."
cat <<EOF > .env
DB_CONN_STRING="${DB_CONN_STRING}"
INSIGHTS_CONN_STRING="${INSIGHTS_CONN_STRING}"
EOF
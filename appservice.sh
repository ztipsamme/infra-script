setup_app_service(){
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
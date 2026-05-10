setup_managed_identity(){
  # Activate Managed Identity
  # az webapp identity assign \
  #   -g $RESOURCE_GROUP \
  #   -n $APP_NAME \
  #   --query principalId
  
  echo "🔐 Enabling Managed Identity..."

  PRINCIPAL_ID=$(az webapp identity assign \
    -g $RESOURCE_GROUP \
    -n $APP_NAME \
    --query principalId \
    -o tsv)
  
  echo "⏳ Waiting for identity to be ready..."

  for i in {1..10}; do
    TYPE=$(az webapp identity show \
      -g $RESOURCE_GROUP \
      -n $APP_NAME \
      --query type -o tsv || true)

    if [[ "$TYPE" == "SystemAssigned" ]]; then
      echo "✅ Identity ready"
      break
    fi

    echo "Waiting... ($i/10)"
    sleep 10
  done

  # Give App Service access to Key Vault
  az role assignment create \
    --assignee $PRINCIPAL_ID \
    --role "Key Vault Secrets User" \
    --scope $(az keyvault show -n $KV_NAME -g $RESOURCE_GROUP --query id -o tsv) \
    2>/dev/null || true
}
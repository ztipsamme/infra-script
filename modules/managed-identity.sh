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
    sleep 20
  done

  for i in {1..5}; do
    echo "🔑 Assigning Key Vault role (attempt $i)..."

    if az role assignment create \
      --assignee "$PRINCIPAL_ID" \
      --role "Key Vault Secrets User" \
      --scope "$(az keyvault show -n "$KEYVAULT_NAME" -g "$RESOURCE_GROUP" --query id -o tsv)" \
      >/dev/null 2>&1; then

      echo "✅ Role assigned"
      break
    else
      echo "⏳ retrying..."
      sleep 10
    fi
  done
}
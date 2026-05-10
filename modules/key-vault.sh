setup_keyvault(){
  log "Setting up Key Vault..."

  if ! exists_kv $RESOURCE_GROUP $KV_NAME; then
    # Create Key Vault
    az keyvault create \
      -n $KV_NAME \
      -g $RESOURCE_GROUP \
      -l $REGION
  fi

  USER_ID=$(az ad signed-in-user show --query id -o tsv)

  # Sets User ti Key Vault Administrator
  az role assignment create \
    --assignee $USER_ID \
    --role "Key Vault Administrator" \
    --scope $(az keyvault show -n $KV_NAME -g $RESOURCE_GROUP --query id -o tsv) \
    2>/dev/null || true
}
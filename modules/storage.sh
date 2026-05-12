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
  STORAGE_CONTAINER_NAME=images

  az storage container create \
    --account-name $STORAGE_NAME \
    -n $STORAGE_CONTAINER_NAME \
    --account-key $STORAGE_KEY \
    --public-access off \
    2>/dev/null || true

  az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    -n profile-image.jpeg \
    --file "$SCRIPT_DIR/assets/profile-image.jpeg" \
    --account-key $STORAGE_KEY \
    --overwrite # temporary
}
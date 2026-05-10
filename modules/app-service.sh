setup_app_service(){
  log "Setting up App Service..."

  if ! exists_app $RESOURCE_GROUP $APP_NAME; then
    # Cerate App Service Plan 
    az appservice plan create \
      -n $APP_PLAN \
      -g $RESOURCE_GROUP \
      --sku F1 \
      -l $REGION
  fi

  if ! exists_app $RESOURCE_GROUP $APP_NAME; then
    # Create App Service Web App
    az webapp create \
      -n $APP_NAME \
      -g $RESOURCE_GROUP \
      -p $APP_PLAN
  fi

  az webapp update \
    -g $RESOURCE_GROUP \
    -n $APP_NAME --https-only true
}
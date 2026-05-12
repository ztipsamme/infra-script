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

  EXISTS=$(az webapp config access-restriction show \
    -g $RESOURCE_GROUP \
    -n $APP_NAME \
    --query "ipSecurityRestrictions[?name=='AllowHomeIP'] | length(@)" \
    -o tsv)

  if [ "$EXISTS" -eq 0 ]; then
    echo "Rule does not exist. Creating..."

    az webapp config access-restriction add \
      -g $RESOURCE_GROUP \
      -n $APP_NAME \
      --rule-name AllowHomeIP \
      --action Allow \
      --ip-address $MY_IP \
      --priority 100
  else
    echo "Rule already exists. Skipping..."
  fi
}
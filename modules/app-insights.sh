setup_app_insights(){
  log "Setting up Application Insights..."

  # Activate logging
  az webapp log config \
    -n $APP_NAME \
    -g $RESOURCE_GROUP \
    --application-logging filesystem \
    --level information \
    --detailed-error-messages true \
    --failed-request-tracing true

  if ! exists_ai $RESOURCE_GROUP $APP_INSIGHT_NAME; then
    # Create Application insights
    az monitor app-insights component create \
    --app $APP_INSIGHT_NAME \
    -l $REGION \
    -g $RESOURCE_GROUP \
    --application-type web
  fi

  INSIGHTS_CONN_STRING=$(az monitor app-insights component show \
    --app $APP_INSIGHT_NAME \
    -g $RESOURCE_GROUP \
    --query connectionString \
    -o tsv)

  # Connect App Service to Application Insights
  az webapp config appsettings set \
    -n $APP_NAME \
    -g $RESOURCE_GROUP \
    --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$INSIGHTS_CONN_STRING"

  # Add Application Insights Connection String to Key Vault
  az keyvault secret set \
    --vault-name $KV_NAME \
    --name $KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME \
    --value $INSIGHTS_CONN_STRING

  az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings APPLICATIONINSIGHTS_CONNECTION_STRING="@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/$KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME/)"
}
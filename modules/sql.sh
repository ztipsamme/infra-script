setup_sql() {
  log "Setting up SQL..."

  if ! exists_sql $RESOURCE_GROUP $SQL_SERVER_NAME; then
      # Create SQL Server
      az sql server create \
        -l $REGION \
        -g $RESOURCE_GROUP \
        -n $SQL_SERVER_NAME \
        -u $ADMIN_USER \
        -p $ADMIN_PASSWORD
  fi

  if ! az sql db show -g $RESOURCE_GROUP -s $SQL_SERVER_NAME -n $SQL_DB_NAME &>/dev/null; then
    # Create SQL Database
    az sql db create \
      -g $RESOURCE_GROUP \
      -s $SQL_SERVER_NAME \
      -n $SQL_DB_NAME \
      --service-objective Basic
  fi

  DB_CONN_STRING=$(az sql db show-connection-string -s $SQL_SERVER_NAME -n $SQL_DB_NAME -c ado.net --output tsv)
  DB_CONN_STRING=${DB_CONN_STRING//<username>/$ADMIN_USER}
  DB_CONN_STRING=${DB_CONN_STRING//<password>/$ADMIN_PASSWORD}

  # Add Database ConnectionString to Key Vault
  az keyvault secret set \
    --vault-name $KEYVAULT_NAME \
    --name $KEYVAULT_DefaultConnection_NAME \
    --value "$DB_CONN_STRING"

  az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings ConnectionStrings__DefaultConnection="@Microsoft.KeyVault(SecretUri=https://$KEYVAULT_NAME.vault.azure.net/secrets/$KEYVAULT_DefaultConnection_NAME/)"

  # Set Firewall rule to allow current IP-adress
  az sql server firewall-rule create \
    -g $RESOURCE_GROUP \
    -s $SQL_SERVER_NAME \
    -n AllowMyIP \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP \
    2>/dev/null || true

  # Set Firewall rule to allow Azure Resources
  az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
}

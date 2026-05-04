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

setup_backups(){
    echo "Setup backups..."

    EXPIRY=$(date -u -v+30d '+%Y-%m-%dT%H:%MZ')  # macOS

    SAS_TOKEN=$(az storage container generate-sas \
        --account-name $STORAGE_NAME \
        --name backups \
        --permissions rwdl \
        --expiry $EXPIRY \
        --auth-mode key \
        --output tsv)

    az webapp config backup create \
        --resource-group $RESOURCE_GROUP \
        --webapp-name $APP_NAME \
        --container-url "https://$STORAGE_NAME.blob.core.windows.net/backups?$SAS_TOKEN"
    
    az webapp config backup update \
        --container-url "https://$STORAGE_NAME.blob.core.windows.net/backups?$SAS_TOKEN" \
        --resource-group $RESOURCE_GROUP \
        --webapp-name $APP_NAME \
        --frequency 1d \
        --retention 7 \
        --retain-one true
}
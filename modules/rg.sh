create_resource_group(){
    if ! exists_rg $RESOURCE_GROUP; then
        # Create Resource Group
        az group create -n $RESOURCE_GROUP -l $REGION
    fi
}
create_resource_group(){
    if ! exists_rg $RESOURCE_GROUP; then
        az group create -n $RESOURCE_GROUP -l $REGION
    fi
}
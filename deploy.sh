#!/bin/bash
set -e

echo "🚀 Deploying Azure infrastructure: $ENV"

source "$SCRIPT_DIR/utils.sh"

source "$SCRIPT_DIR/modules/rg.sh"
source "$SCRIPT_DIR/modules/key-vault.sh"
source "$SCRIPT_DIR/modules/app-service.sh"
source "$SCRIPT_DIR/modules/managed-identity.sh"
source "$SCRIPT_DIR/modules/sql.sh"
source "$SCRIPT_DIR/modules/app-insights.sh"
source "$SCRIPT_DIR/modules/storage.sh"
source "$SCRIPT_DIR/modules/backups.sh"
source "$SCRIPT_DIR/modules/devops.sh"
source "$SCRIPT_DIR/modules/devops.sh"
source "$SCRIPT_DIR/modules/git.sh"
source "$SCRIPT_DIR/modules/pipeline.sh"

create_resource_group
setup_keyvault
setup_app_service
setup_managed_identity
setup_sql
setup_app_insights
setup_storage
setup_backups

setup_devops
push_to_repo
create_pipeline

echo "✅ Infra deployment complete ($ENV)"


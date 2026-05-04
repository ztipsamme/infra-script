#!/bin/bash
set -e

source ./config.sh
source ./utils.sh

source ./rg.sh
source ./keyvault.sh
source ./sql.sh
source ./appservice.sh
source ./insights.sh
source ./storage.sh

main() {
  create_resource_group
  setup_keyvault
  setup_app_service
  setup_sql
  setup_app_insights
  setup_storage
}

main

echo "DB_CONN_STRING: $DB_CONN_STRING"
echo "INSIGHTS_CONN_STRING: $INSIGHTS_CONN_STRING"

echo "Saving environment variables to .env..."
cat <<EOF > .env
DB_CONN_STRING="${DB_CONN_STRING}"
INSIGHTS_CONN_STRING="${INSIGHTS_CONN_STRING}"
EOF
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_help() {
  echo ""
  echo "Usage:"
  echo "  infra deploy --env <env>"
  echo "  infra destroy --env <env>"
  echo ""
}

load_env() {
  ENV_FILE="$SCRIPT_DIR/config/$1.sh"

  if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Environment '$1' not found"
    exit 1
  fi

  source "$ENV_FILE"
}

deploy() {
  echo "🚀 Deploying environment: $ENV"

  source "$SCRIPT_DIR/config.sh"
  source "$SCRIPT_DIR/utils.sh"

  source "$SCRIPT_DIR/modules/rg.sh"
  source "$SCRIPT_DIR/modules/keyvault.sh"
  source "$SCRIPT_DIR/modules/sql.sh"
  source "$SCRIPT_DIR/modules/appservice.sh"
  source "$SCRIPT_DIR/modules/insights.sh"
  source "$SCRIPT_DIR/modules/storage.sh"

  create_resource_group
  setup_keyvault
  setup_app_service
  setup_sql
  setup_app_insights
  setup_storage

  echo "✅ Deploy complete ($ENV)"
}

deploy

# destroy() {
#   echo "💣 Destroying environment: $ENV"

#   source "$SCRIPT_DIR/config.sh"
#   source "$SCRIPT_DIR/cleanup.sh"

#   cleanup

#   echo "✅ Cleanup complete ($ENV)"
# }

echo "DB_CONN_STRING: $DB_CONN_STRING"
echo "INSIGHTS_CONN_STRING: $INSIGHTS_CONN_STRING"

echo "Saving environment variables to .env..."
cat <<EOF > .env
DB_CONN_STRING="${DB_CONN_STRING}"
INSIGHTS_CONN_STRING="${INSIGHTS_CONN_STRING}"
EOF
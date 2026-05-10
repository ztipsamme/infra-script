#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_help() {
  echo ""
  echo "Usage:"
  echo "  infra deploy --env <env>"
  echo "  in --env <env>"
  echo "  infra bootstrap --env <env>"
  echo ""
  echo "Environments:"
  echo "  dev | prod "
  echo ""
}

load_env() {
  ENV_FILE="$SCRIPT_DIR/config.sh"

  if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Environment '$1' not found"
    exit 1
  fi

  source "$ENV_FILE"
}

deploy() {
  echo "🚀 Deploying environment: $ENV"

  source "$SCRIPT_DIR/utils.sh"
  source "$SCRIPT_DIR/modules/rg.sh"
  source "$SCRIPT_DIR/modules/key-vault.sh"
  source "$SCRIPT_DIR/modules/app-service.sh"
  source "$SCRIPT_DIR/modules/managed-identity.sh"
  source "$SCRIPT_DIR/modules/sql.sh"
  source "$SCRIPT_DIR/modules/app-insights.sh"
  source "$SCRIPT_DIR/modules/storage.sh"

  create_resource_group
  setup_keyvault
  setup_app_service
  setup_managed_identity
  setup_sql
  setup_app_insights
  setup_storage

  echo "✅ Deploy complete ($ENV)"
}

destroy() {
  echo "💣 Destroying environment: $ENV"

  source "$SCRIPT_DIR/cleanup.sh"

  cleanup

  echo "✅ Cleanup complete ($ENV)"
}

bootstrap() {
  echo "🧱 Creating ASP.NET Web APP: $ENV"

  source "$SCRIPT_DIR/bootstrap.sh"

  setup_project

  echo "✅ Project setup complete ($ENV)"
}

COMMAND=$1
shift

ENV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      print_help
      exit 1
      ;;
  esac
done

if [[ -z "$COMMAND" ]]; then
  print_help
  exit 1
fi

if [[ -z "$ENV" ]]; then
  echo "❌ Missing --env"
  print_help
  exit 1
fi

load_env "$ENV"

case "$COMMAND" in
  deploy)
    deploy
    ;;
  destroy)
    destroy
    ;;
  bootstrap)
    bootstrap
    ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    print_help
    exit 1
    ;;
esac
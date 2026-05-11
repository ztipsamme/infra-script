#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMAND=$1
shift

PROJECT=""
ENV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      PROJECT="$2"
      shift 2
      ;;
    --env)
      ENV="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown flag: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$PROJECT" || -z "$ENV" ]]; then
  echo "❌ Missing required flags"
  echo "Usage: ./index.sh deploy --name <app> --env <dev|prod>"
  exit 1
fi

export PROJECT ENV

source "$SCRIPT_DIR/config.sh"

case "$COMMAND" in
  bootstrap)
    source "$SCRIPT_DIR/bootstrap.sh"
    ;;
  deploy)
    source "$SCRIPT_DIR/deploy.sh"  
    ;;
  destroy)
    source "$SCRIPT_DIR/destroy.sh"
    ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    echo "Usage: bootstrap | deploy | destroy"
    exit 1
    ;;
esac
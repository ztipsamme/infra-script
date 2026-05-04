set -euo pipefail
log() {
  echo ""
  echo "=== $1 ==="
}

exists_rg () {
  az group show -n "$1" &>/dev/null
}

exists_kv () {
  az keyvault show -g "$1" -n "$2" &>/dev/null
}

exists_app () {
  az webapp show -g "$1" -n "$2" &>/dev/null
}

exists_sql () {
  az sql server show -g "$1" -n "$2" &>/dev/null
}

exists_ai () {
  az monitor app-insights component show -g "$1" --app "$2" &>/dev/null
}

exists_sa () {
  az storage account show -g "$1" -n "$2" &>/dev/null
}
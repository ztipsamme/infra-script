echo "⭐️ Creating variables"

# === GLOBAL CONFIG ===
ORG="emmaspitz"
REGION="swedencentral"
RESOURCE_GROUP="RG-Emma-Spitz-a59389-DotNetCloudDeveloper-VT-Mars-Goteborg"
ADMIN_USER="adminUser"
ADMIN_PASSWORD="MyStrongPassword1234"

# === NAMING ===
PREFIX="${ORG}-${PROJECT}-${ENV}"

export APP_NAME="${PREFIX}-app"
APP_PLAN="${PREFIX}-plan"

SQL_SERVER_NAME="${ORG}${PROJECT}${ENV}sql"
SQL_DB_NAME="${PROJECT}-${ENV}"

APP_INSIGHT_NAME="${PREFIX}-ai"

### Storage account (NO DASHES)
STORAGE_NAME="${ORG}${PROJECT}${ENV}sa"

KEYVAULT_NAME="${PREFIX}-kv"

KEYVAULT_DefaultConnection_NAME="DefaultConnection"
KEYVAULT_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME="ApplicationInsightsConnection"

MY_IP=$(curl ipinfo.io/ip)

echo "✅ Created variables"

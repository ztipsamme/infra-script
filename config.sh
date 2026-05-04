# === GLOBAL CONFIG ===
ORG="emmaspitz"
ENV="prod"
REGION="swedencentral"
RESOURCE_GROUP="RG-Emma-Spitz-a59389-DotNetCloudDeveloper-VT-Mars-Goteborg"

# === INPUT ===
read -p "Project name: " PROJECT
# read -p "Admin username: " ADMIN_USER
# read -p "Admin password: " ADMIN_PASSWORD
ADMIN_USER="adminUser"
ADMIN_PASSWORD="MyStrongPassword1234"

# === NAMING ===
PREFIX="${ORG}-${PROJECT}-${ENV}"

APP_NAME="${PREFIX}-app"
APP_PLAN="${PREFIX}-plan"

SQL_SERVER_NAME="${ORG}${PROJECT}${ENV}sql"
SQL_DB_NAME="${PROJECT}-${ENV}"

APP_INSIGHT_NAME="${PREFIX}-ai"

### Storage account (NO DASHES)
STORAGE_NAME="${ORG}${PROJECT}${ENV}sa"

KV_NAME="${PREFIX}-kv"

KV_DefaultConnection_NAME="DefaultConnection"
KV_APPLICATIONINSIGHTS_CONNECTION_STRING_NAME="ApplicationInsightsConnection"

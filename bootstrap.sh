#!/bin/bash
set -e

create_dotnet_project(){
  echo "🧱 Creating .NET project..."

  dotnet new webapi -n "$PROJECT"
  cd "$PROJECT"
  envsubst < "$SCRIPT_DIR/templates/program.template.cs" > Program.cs


  echo "📦 Adding packages..."
  dotnet add package Microsoft.ApplicationInsights.AspNetCore

  dotnet add package Microsoft.EntityFrameworkCore
  dotnet add package Microsoft.EntityFrameworkCore.Tools
  dotnet add package Microsoft.EntityFrameworkCore.SqlServer
  dotnet add package Microsoft.EntityFrameworkCore.Design
  dotnet new gitignore

  echo "📁 Project structure ready"
}

setup_local_dev(){
  echo "🐳 Setting up local dev environment..."

  export LOCAL_DOCKER_CONTAINER_NAME="${PROJECT}"
  export LOCAL_DB_PASSWORD="Your_password123!"

  DB_CONN_STRING="Server=localhost,1433;Database=$PROJECT;User Id=sa;Password=$LOCAL_DB_PASSWORD;TrustServerCertificate=True"

  echo "🔐 Setting up user-secrets..."
  dotnet user-secrets init
  dotnet user-secrets set "ConnectionStrings:DefaultConnection" "$DB_CONN_STRING"

  echo "📦 Creating local docker setup..."
  cp "$SCRIPT_DIR/templates/docker-compose.template.yml" docker-compose.yml
  envsubst < "$SCRIPT_DIR/templates/start-dev.template.sh" > start-dev.sh

  echo "📄 Creating .env files..."
  cat > .env <<EOF
DB_CONN_STRING=${DB_CONN_STRING}
LOCAL_DOCKER_CONTAINER_NAME=${LOCAL_DOCKER_CONTAINER_NAME}
LOCAL_DB_PASSWORD=${LOCAL_DB_PASSWORD}
EOF

  envsubst < "$SCRIPT_DIR/templates/.env.example.template" > .env.example

  echo "📄 Creating pipeline files... "

  export AZURE_SUBSCRIPTION="$PROJECT-connection"
  export KEYVAULT_NAME="$KEYVAULT_NAME"

  envsubst '$APP_NAME $AZURE_SUBSCRIPTION $KEYVAULT_NAME' \
    < "$SCRIPT_DIR/templates/azure-pipelines.template.yml" \
    > azure-pipelines.yml
  echo "✅ Local dev setup complete"
}

setup_project(){
  create_dotnet_project
  setup_local_dev
  code .
}


echo "🚀 Starting app bootstrap..."

setup_project

echo "✅ App created successfully"

#!/bin/bash
set -e
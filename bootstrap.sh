#!/bin/bash
create_dotnet_project(){
  echo "Creating .NET project..."
  dotnet new webapi -n $PROJECT
  cd $PROJECT

  envsubst < "$SCRIPT_DIR/templates/program.template.cs" > Program.cs

  export AZURE_SUBSCRIPTION="$PROJECT-connection"

  envsubst '$APP_NAME $AZURE_SUBSCRIPTION' \
    < "$SCRIPT_DIR/templates/azure-pipelines.template.yml" \
    > azure-pipelines.yml

  echo "📦 Adding packages..."
  dotnet add package Microsoft.ApplicationInsights.AspNetCore
  dotnet add package Microsoft.EntityFrameworkCore
  dotnet add package Microsoft.EntityFrameworkCore.Tools
  dotnet add package Microsoft.EntityFrameworkCore.SqlServer
  dotnet add package Microsoft.EntityFrameworkCore.Design
  dotnet new gitignore

  echo "⭐️ Setup User Secrets and .env file in local repo"
  DB_CONN_STRING=$(az sql db show-connection-string -s $SQL_SERVER_NAME -n $SQL_DB_NAME -c ado.net --output tsv)
  DB_CONN_STRING=${DB_CONN_STRING//<username>/$ADMIN_USER}
  DB_CONN_STRING=${DB_CONN_STRING//<password>/$ADMIN_PASSWORD}

  INSIGHTS_CONN_STRING=$(az monitor app-insights component show --app $APP_INSIGHT_NAME -g $RESOURCE_GROUP --query connectionString -o tsv)

  envsubst < "$SCRIPT_DIR/templates/.env.example.template" > .env.example

cat > .env <<EOF
DB_CONN_STRING="${DB_CONN_STRING}"
INSIGHTS_CONN_STRING="${INSIGHTS_CONN_STRING}"
EOF

  dotnet user-secrets init
  dotnet user-secrets set "ConnectionStrings:DefaultConnection" "$DB_CONN_STRING"
  dotnet user-secrets set "APPLICATIONINSIGHTS_CONNECTION_STRING" "$INSIGHTS_CONN_STRING"

  echo "⭐️ Create first migration"
  dotnet ef migrations add InitialCreate
  dotnet ef database update
}

setup_devops(){
  echo "⚙️ Setting up Azure DevOps..."
  az devops configure --defaults organization=https://dev.azure.com/$ORG/ 
  az devops project create --name $PROJECT --visibility private

  echo "⏳ Waiting for project..."
  until az devops project show --project $PROJECT &>/dev/null; do
    sleep 5
  done

  az devops configure --defaults project=$PROJECT

  if ! az repos show --repository $PROJECT --project $PROJECT &>/dev/null; then
    echo "📁 Creating repo..."
    az repos create --name $PROJECT --project $PROJECT
  else
    echo "📁 Repo already exists, skipping..."
  fi
}

push_to_repo(){
  SSH_URL=$(az repos show --repository $PROJECT --project $PROJECT --query "sshUrl" -o tsv)

  echo "🐙 Initializing git..."
  git init
  git branch -M main
  git remote add origin $SSH_URL
  git add .
  git commit -m "Initial commit"
  git push -u origin main
}

create_pipeline(){
  echo "🚀 Creating pipeline..."
  az pipelines create --name $ENV --project $PROJECT --repository $PROJECT --repository-type tfsgit --branch main --yml-path azure-pipelines.yml
}

setup_project(){
  create_dotnet_project
  setup_devops
  push_to_repo
  create_pipeline
  
  code .
}
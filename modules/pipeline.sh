#!/bin/bash
set -e

create_pipeline(){
  echo "🚀 Creating Azure Pipeline..."

  REPO_NAME="$PROJECT"

  az pipelines create \
    --name "$PROJECT" \
    --project "$PROJECT" \
    --repository "$REPO_NAME" \
    --repository-type tfsgit \
    --branch main \
    --yml-path azure-pipelines.yml

  echo "✅ Pipeline created"
}
#!/bin/bash

cd "$(dirname "$0")"

export $(cat .env | xargs)

echo "🐳 Starting database..."
docker compose up -d

echo "⏳ Loading env..."
set -a
source .env
set +a

echo "⏳ Waiting for database..."
sleep 10

echo "🔧 Starting backend..."
dotnet run
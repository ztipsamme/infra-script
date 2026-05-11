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
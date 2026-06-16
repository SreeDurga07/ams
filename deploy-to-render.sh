#!/bin/bash
# Render Deployment Helper Script for AMS
# This script helps set up and deploy the AMS to Render

set -e

echo "================================"
echo "AMS Render Deployment Helper"
echo "================================"
echo ""

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Get GitHub credentials
echo "📝 GitHub Configuration"
read -p "Enter your GitHub username: " github_user
read -p "Enter your GitHub repository name (default: ams): " repo_name
repo_name=${repo_name:-ams}

github_url="https://github.com/${github_user}/${repo_name}.git"

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo ""
    echo "🔧 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial AMS deployment to Render"
    git branch -M main
else
    echo "✅ Git repository already initialized"
fi

# Add remote if not exists
if ! git remote get-url origin &> /dev/null; then
    echo "🔗 Adding GitHub remote..."
    git remote add origin "$github_url"
else
    echo "✅ GitHub remote already configured"
fi

echo ""
echo "================================"
echo "✅ Deployment files ready!"
echo "================================"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "2. Go to https://dashboard.render.com"
echo ""
echo "3. Click '+ New' → Select 'Blueprint'"
echo ""
echo "4. Connect GitHub and select this repository"
echo ""
echo "5. Render will read render.yaml and deploy:"
echo "   - MySQL database service"
echo "   - Tomcat web service"
echo "   - Automatic environment variable linking"
echo ""
echo "6. Once deployed, initialize the database:"
echo "   mysql -h <render_host> -u <user> -p < ams_schema.sql"
echo ""
echo "7. Access your app at: https://ams-app.onrender.com"
echo ""

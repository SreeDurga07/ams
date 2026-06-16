@echo off
REM Render Deployment Helper Script for AMS (Windows)
REM This script helps set up and deploy the AMS to Render

echo.
echo ================================
echo AMS Render Deployment Helper
echo ================================
echo.

REM Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ^❌ Git is not installed. Please install Git first.
    exit /b 1
)

REM Get GitHub credentials
echo ^📝 GitHub Configuration
set /p github_user="Enter your GitHub username: "
set /p repo_name="Enter your GitHub repository name (default: ams): "
if "%repo_name%"=="" set repo_name=ams

set github_url=https://github.com/%github_user%/%repo_name%.git

REM Initialize Git repository if not already initialized
if not exist ".git" (
    echo.
    echo 🔧 Initializing Git repository...
    git init
    git add .
    git commit -m "Initial AMS deployment to Render"
    git branch -M main
) else (
    echo ^✅ Git repository already initialized
)

REM Add remote if not exists
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo 🔗 Adding GitHub remote...
    git remote add origin %github_url%
) else (
    echo ^✅ GitHub remote already configured
)

echo.
echo ================================
echo ^✅ Deployment files ready!
echo ================================
echo.
echo 📋 Next steps:
echo.
echo 1. Push to GitHub:
echo    git push -u origin main
echo.
echo 2. Go to https://dashboard.render.com
echo.
echo 3. Click '^+ New' -^> Select '^Blueprint'
echo.
echo 4. Connect GitHub and select this repository
echo.
echo 5. Render will read render.yaml and deploy:
echo    - MySQL database service
echo    - Tomcat web service
echo    - Automatic environment variable linking
echo.
echo 6. Once deployed, initialize the database:
echo    mysql -h ^<render_host^> -u ^<user^> -p ^< ams_schema.sql
echo.
echo 7. Access your app at: https://ams-app.onrender.com
echo.

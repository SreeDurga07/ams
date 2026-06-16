# Quick Start: Deploy AMS to Render

## 📦 Files Created for Deployment

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds Docker image with Tomcat + Java |
| `render.yaml` | Blueprint config for Render services |
| `db.properties.docker` | Database config with env variables |
| `.dockerignore` | Excludes unnecessary files from Docker |
| `.gitignore` | Excludes files from Git |
| `RENDER_DEPLOYMENT.md` | Detailed deployment guide |
| `deploy-to-render.sh` | Setup helper (Linux/Mac) |
| `deploy-to-render.bat` | Setup helper (Windows) |

---

## ⚡ Quick Deploy (5 minutes)

### 1. Organize Your Project

Ensure this structure in your project root:
```
.
├── Dockerfile
├── render.yaml
├── db.properties.docker
├── .dockerignore
├── .gitignore
├── AMS_Website/          ← Your app folder
│   ├── *.jsp
│   ├── css/
│   ├── js/
│   ├── includes/
│   └── WEB-INF/
├── ams_schema.sql        ← Database schema
└── RENDER_DEPLOYMENT.md
```

### 2. Push to GitHub

**Windows:**
```powershell
# Run helper script (optional)
.\deploy-to-render.bat

# Or do it manually:
git init
git add .
git commit -m "Deploy AMS to Render"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ams.git
git push -u origin main
```

**Mac/Linux:**
```bash
./deploy-to-render.sh
# OR manually:
git init
git add .
git commit -m "Deploy AMS to Render"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ams.git
git push -u origin main
```

### 3. Deploy via Render

1. Go to https://dashboard.render.com (sign up if needed)
2. Click **+ New** → **Blueprint**
3. Select **Connect GitHub** and authorize
4. Choose your `ams` repository
5. Click **Deploy**

✅ Render reads `render.yaml` and deploys automatically!

### 4. Initialize Database (After Deploy)

Once the app is running:

1. Go to Render Dashboard → MySQL service
2. Copy connection details
3. Run in terminal or MySQL client:
   ```bash
   mysql -h <host> -u <user> -p <database> < ams_schema.sql
   ```

### 5. Access Your App

- **URL:** `https://ams-app.onrender.com`
- **Login:** 
  - Username: `admin`
  - Password: `admin123` (or as set in schema)

---

## 🔧 What's Configured

**Dockerfile:**
- Uses Tomcat 10 + Java 17 (Jakarta EE compatible)
- Deploys AMS to Tomcat ROOT directory
- Exposes port 8080

**render.yaml:**
- **MySQL Service:** Free tier with 5GB storage
- **Tomcat Service:** Free tier with auto-scaling
- **Environment Variables:** Automatically linked between services

**Database Config:**
- Reads from environment variables
- Fallback to defaults
- Works with MySQL or Oracle

---

## 🚀 Advanced (Optional)

### Custom Domain
1. Dashboard → Service Settings → Custom Domains
2. Add your domain (e.g., `ams.company.com`)
3. Update DNS records per Render instructions

### Keep Services Active (Free Tier)
Free services sleep after 15 min inactivity. To prevent:
- Upgrade to paid plan
- OR use a simple cron job to ping your app

### View Logs
Dashboard → Logs tab (shows deployment, runtime errors)

### Troubleshooting
See [RENDER_DEPLOYMENT.md](RENDER_DEPLOYMENT.md) for detailed troubleshooting

---

## 💡 Tips

- **Database not initialized?** Run schema SQL after first deploy
- **App won't start?** Check Logs tab for connection errors
- **Changes not showing?** Push to GitHub, Render redeploys automatically
- **Free tier slow?** Upgrade to Standard plan for better performance

---

## 📞 Support

- 📖 Render Docs: https://render.com/docs
- 🐛 Check Logs: Dashboard → Logs
- 🆘 Render Support: https://render.com/support

---

**Ready to deploy? Follow the 5-step Quick Deploy above!** ✨

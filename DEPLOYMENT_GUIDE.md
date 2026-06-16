# AMS - Render Deployment Complete Guide

## ✅ Prerequisites Completed

- ✅ Code pushed to GitHub: https://github.com/SreeDurga07/ams
- ✅ Deployment files created:
  - `Dockerfile` (Tomcat 10 + Java 17)
  - `render.yaml` (Blueprint configuration)
  - `db.properties.docker` (Database config)
  - Deployment scripts

---

## 🚀 Step 1: Deploy to Render

### Option A: Using Render Dashboard (Recommended)

1. **Open Render Dashboard**
   ```
   https://dashboard.render.com
   ```

2. **Sign Up (if needed)**
   - Use GitHub account for easy login

3. **Create New Blueprint**
   - Click **+ New**
   - Select **Blueprint**

4. **Connect GitHub**
   - Click **Connect GitHub** (authorize if prompted)
   - Select repository: **SreeDurga07/ams**

5. **Review Configuration**
   - Render reads `render.yaml` automatically
   - Shows:
     - MySQL service (ams-db)
     - Tomcat service (ams-app)
   - Click **Deploy**

6. **Wait for Deployment**
   - First deploy takes ~3-5 minutes
   - Monitor progress in dashboard

### Option B: Using Render CLI

```bash
# Install Render CLI (if needed)
npm install -g render-cli

# Login to Render
render login

# Deploy from project root
render deploy
```

---

## 📊 Deployment Status

After clicking Deploy, Render will:

1. **Build Phase** (1-2 min)
   - Pulls code from GitHub
   - Builds Docker image
   - Creates MySQL database

2. **Deployment Phase** (2-3 min)
   - Starts MySQL service
   - Starts Tomcat service
   - Assigns public URL

3. **Running Phase**
   - Services become available
   - App accessible at: `https://ams-app.onrender.com`

---

## 🗄️ Step 2: Initialize Database

After deployment, you need to run the SQL schema. **Choose one method:**

### Method A: Using Render Web Console (Easiest)

1. Go to **Render Dashboard** → **ams-db** service
2. Click **Connect**
3. Copy the connection command:
   ```bash
   mysql -h <host> -u <user> -p<password> <database>
   ```
4. Paste in terminal and connect

5. In MySQL prompt, run:
   ```sql
   -- Copy entire contents of ams_schema.sql
   -- Paste and execute
   ```

### Method B: Using mysql Client Directly

```bash
# Get database credentials from Render dashboard
# Services → ams-db → Info tab

mysql -h <RENDER_HOST> \
      -u <RENDER_USER> \
      -p<RENDER_PASSWORD> \
      <RENDER_DATABASE> < ams_schema.sql
```

**Example:**
```bash
mysql -h dpg-xxxxx.render.com \
      -u ams_user \
      -pMyPassword123 \
      ams_db < ams_schema.sql
```

### Method C: Using GUI Tool (MySQL Workbench)

1. Download MySQL Workbench: https://dev.mysql.com/downloads/workbench/
2. Create new connection:
   - **Hostname:** `dpg-xxxxx.render.com`
   - **Port:** `3306`
   - **Username:** `ams_user`
   - **Password:** (from Render dashboard)
   - **Database:** `ams_db`
3. Test Connection
4. Open SQL editor and run `ams_schema.sql`

---

## 🔐 Environment Variables

Render automatically sets these from `render.yaml`:

| Variable | Value | Source |
|----------|-------|--------|
| `DB_DRIVER` | `com.mysql.cj.jdbc.Driver` | render.yaml |
| `DB_URL` | `jdbc:mysql://ams-db:3306/ams_db` | Auto-linked |
| `DB_USER` | MySQL username | Auto-linked |
| `DB_PASSWORD` | MySQL password | Auto-linked |
| `PORT` | `8080` | Tomcat |

**No manual configuration needed!** Render links them automatically.

---

## 🌐 Access Your Application

### Live URL
```
https://ams-app.onrender.com
```

### Default Login Credentials
(After database initialization)
```
Username: admin
Password: admin123
```

### Test the App
1. Open: `https://ams-app.onrender.com`
2. You should see the AMS login page
3. Log in with admin credentials

---

## ❌ Troubleshooting

### Problem: Application won't start

**Check Logs:**
```
Dashboard → ams-app → Logs tab
```

**Common causes:**
- Database not initialized → Run schema SQL (Step 2)
- Database connection error → Verify DB_URL, DB_USER, DB_PASSWORD
- Tomcat startup error → Check deploy logs

### Problem: "Connection refused" error

**Solution:**
1. Verify MySQL service is running
2. Check database credentials in Render dashboard
3. Ensure schema was initialized
4. Restart Tomcat service from dashboard

### Problem: 500 Internal Server Error

**Check:**
1. Is database initialized? Run: `mysql ... < ams_schema.sql`
2. Look at Logs → Check DBConnection errors
3. Verify all environment variables are set

### Problem: Application seems slow

**Free tier has limits:**
- Free MySQL: 5GB storage, sleeps after 15 min
- Free Tomcat: Sleeps after 15 min inactivity

**Solutions:**
- First request will be slow (wakeup time ~30s)
- Upgrade to paid plan for 24/7 availability
- Use external monitoring to keep services awake

---

## 📝 Command Reference

### View Application Logs
```bash
# From dashboard: ams-app → Logs
# Or using CLI:
render logs --service ams-app
```

### View Database Logs
```bash
# From dashboard: ams-db → Logs
render logs --service ams-db
```

### Restart Services
```bash
# From dashboard: Click "Restart" button
# Or using CLI:
render restart-service --service ams-app
render restart-service --service ams-db
```

### View Environment Variables
```
Dashboard → ams-app → Environment tab
```

### SSH into Container (if needed)
```bash
render shell --service ams-app
```

---

## 🔄 Update & Redeployment

To update your application:

```bash
# Make changes locally
git add .
git commit -m "Update message"

# Push to GitHub
git push origin main

# Render automatically redeploys!
# Monitor at: Dashboard → Deployments tab
```

---

## 📊 Monitoring Dashboard

**Key Metrics to Check:**

1. **CPU Usage** - Should be low (<20%)
2. **Memory** - Should be <500MB for free tier
3. **Network** - Requests/responses
4. **Disk** - Database storage usage

**Monitor at:** Dashboard → Service → Metrics tab

---

## 💰 Pricing & Upgrades

### Free Tier (Current)
- MySQL: 5GB storage, auto-sleep after 15 min
- Tomcat: Auto-sleep after 15 min
- $0/month

### Upgrade Options
1. **Standard** ($7-12/month)
   - No auto-sleep
   - Better performance
   - 5GB → 100GB storage

2. **Professional** ($12+/month)
   - Reserved resources
   - Priority support
   - Unlimited storage

**Upgrade:** Dashboard → Service → Settings → Upgrade

---

## ✨ Features Overview

Once deployed and database initialized, access:

| Feature | URL |
|---------|-----|
| Dashboard | `/dashboard.jsp` |
| Assets | `/assets.jsp` |
| Employees | `/employees.jsp` |
| Vendors | `/vendors.jsp` |
| Maintenance | `/maintenance.jsp` |
| Reports | `/reports.jsp` |
| Logout | `/logout.jsp` |

---

## 📞 Support

### Render Support
- Docs: https://render.com/docs
- Status: https://status.render.com
- Support: https://render.com/support

### AMS Application
- GitHub: https://github.com/SreeDurga07/ams
- Issues: https://github.com/SreeDurga07/ams/issues

### Common Commands

```bash
# Check git status
git status

# View recent commits
git log --oneline -5

# Check database connection
mysql -h <host> -u <user> -p<password> <database> -e "SELECT 1;"

# View Render services
render services

# Tail logs in real-time
render logs --service ams-app --tail
```

---

## 🎯 Quick Checklist

- [ ] Repository pushed to GitHub (SreeDurga07/ams)
- [ ] Render dashboard accessed (render.com)
- [ ] Blueprint deployed from GitHub
- [ ] MySQL and Tomcat services created
- [ ] Database schema initialized (ams_schema.sql)
- [ ] Application accessible at live URL
- [ ] Login successful with admin credentials
- [ ] Can view dashboard, assets, employees, etc.

---

**Deployment Complete!** 🎉

Your AMS application is now live on Render. Access it at:
```
https://ams-app.onrender.com
```

# 🚀 AMS Deployment - START COMMANDS & REQUIREMENTS

## 📋 Complete Checklist - What's Required

### ✅ Already Done
- [x] Code pushed to GitHub (SreeDurga07/ams)
- [x] Dockerfile created (Tomcat 10 + Java 17)
- [x] render.yaml created (Blueprint config)
- [x] Environment variables configured
- [x] db.properties.docker configured
- [x] .gitignore and .dockerignore created
- [x] Deployment scripts created

### ⚠️ To Do (You Now)
- [ ] Go to Render dashboard (https://dashboard.render.com)
- [ ] Create Blueprint deployment
- [ ] Initialize database with SQL schema
- [ ] Test application login

---

## 🎯 Step-by-Step START Commands

### **STEP 1: Go to Render Dashboard**

```
https://dashboard.render.com
```

Sign in with GitHub account.

---

### **STEP 2: Create New Blueprint**

1. Click **+ New** button (top right)
2. Select **Blueprint**
3. Click **Connect GitHub**
4. Authorize Render to access your GitHub
5. Select repository: **SreeDurga07/ams**
6. Select **main** branch
7. Click **Connect**

---

### **STEP 3: Review Deployment Configuration**

Render will show you:

```
Services to Deploy:
├── ams-app (Web - Tomcat 10 + Java 17)
└── ams-db (MySQL 8)

Environment Variables:
├── DB_DRIVER=com.mysql.cj.jdbc.Driver
├── DB_URL=jdbc:mysql://ams-db:3306/ams_db
├── DB_USER=(auto-linked)
├── DB_PASSWORD=(auto-linked)
└── PORT=8080
```

**All auto-configured!** Just click **Deploy**

---

### **STEP 4: Deploy!**

Click the **Deploy** button and wait.

**Deployment Timeline:**
- Minute 0-1: GitHub repo pulled
- Minute 1-2: Docker image built
- Minute 2-3: Services start
- Minute 3-4: MySQL initialized
- Minute 4-5: Tomcat started
- **Application accessible!**

---

### **STEP 5: Initialize Database**

Once deployed, run SQL schema:

**Option A: Quick Command (Terminal)**

Get credentials from Render dashboard first:
1. Dashboard → **ams-db** service
2. Click **Info** tab
3. Copy the connection string

Then run:

```bash
mysql -h dpg-xxxxx.render.com -u render -p ams_db < ams_schema.sql
```

**Option B: Using Render Web Console**

1. Dashboard → **ams-db** service
2. Click **Connect** button
3. Copy MySQL command
4. Paste and run in terminal
5. Inside MySQL: Paste contents of `ams_schema.sql`

---

### **STEP 6: Access Application**

**Live URL:**
```
https://ams-app.onrender.com
```

**Login:**
```
Username: admin
Password: admin123
```

---

## 📦 Requirements Summary

### Runtime Requirements (Automatic)
- **Java:** 17 (in Dockerfile)
- **Tomcat:** 10 (in Dockerfile)
- **MySQL:** 8 (from render.yaml)
- **Database:** ams_db (created automatically)

### Ports
- **Application:** Port 8080 (exposed as 443/https)
- **MySQL:** Port 3306 (internal, not exposed)

### Storage
- **Database:** 5GB (free tier)
- **Application:** Containerized (no storage limit)

### Environment
All from `render.yaml`:
```yaml
DB_DRIVER: com.mysql.cj.jdbc.Driver
DB_URL: jdbc:mysql://ams-db:3306/ams_db
DB_USER: (auto-linked from MySQL service)
DB_PASSWORD: (auto-linked from MySQL service)
PORT: 8080
```

---

## 🔧 Technical Details

### Docker Configuration
```dockerfile
FROM tomcat:10-jdk17-eclipse-temurin
# Copies AMS app to Tomcat ROOT
# Exposes port 8080
# Starts Tomcat
```

### Database Configuration
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://ams-db:3306/ams_db
db.user=${DB_USER}
db.password=${DB_PASSWORD}
```

### Blueprint (render.yaml)
- MySQL service: Free tier, 5GB storage
- Tomcat service: Free tier, auto-sleep after 15 min
- Auto-linking: Services communicate internally

---

## 🎯 URLs & Access Points

| Item | URL |
|------|-----|
| **Application** | https://ams-app.onrender.com |
| **Dashboard** | https://ams-app.onrender.com/dashboard.jsp |
| **Assets** | https://ams-app.onrender.com/assets.jsp |
| **Employees** | https://ams-app.onrender.com/employees.jsp |
| **Vendors** | https://ams-app.onrender.com/vendors.jsp |
| **Reports** | https://ams-app.onrender.com/reports.jsp |
| **Render Dashboard** | https://dashboard.render.com |

---

## 🚨 Common Issues & Fixes

### "Application won't load"
→ Database not initialized yet
→ **FIX:** Run `mysql ... < ams_schema.sql`

### "Connection refused error"
→ MySQL service not running
→ **FIX:** Check Render dashboard → ams-db status

### "500 Internal Server Error"
→ Database connection failed
→ **FIX:** Verify environment variables in dashboard

### "App very slow on first load"
→ Free tier sleeps after 15 min
→ **FIX:** Wait 30-60 seconds for wake-up

---

## 📊 What Gets Deployed

### From GitHub Repository:
```
AMS_Website/
├── *.jsp (all JSP pages)
├── css/style.css
├── js/script.js
├── includes/
│   ├── header.jsp
│   ├── footer.jsp
│   └── sidebar.jsp
└── WEB-INF/
    ├── web.xml
    └── classes/
        ├── db.properties.docker (renamed to db.properties)
        └── com/ams/util/DBConnection.java

ams_schema.sql (database schema - run manually)

Configuration Files:
├── Dockerfile (build instructions)
├── render.yaml (deployment blueprint)
├── .dockerignore
└── .gitignore
```

---

## ✨ Features Available After Deployment

1. **Login System**
   - Role-based (Admin/User)
   - Session management

2. **Asset Management**
   - Create/Edit/Delete assets
   - QR code generation
   - Category management

3. **Employee Management**
   - Employee records
   - Asset allocation/return
   - History tracking

4. **Vendor Management**
   - Vendor directory
   - Maintenance records

5. **Reports**
   - Available assets
   - Assigned assets
   - Depreciation reports
   - Audit logs

6. **Dashboard**
   - Live asset counts
   - Category breakdown
   - Recent activity

---

## 💡 Pro Tips

1. **Speed Up First Load**
   - Free tier services sleep after 15 min
   - First request wakes them (~30-60 seconds)
   - Upgrade to paid for always-on

2. **Monitor Application**
   - Dashboard → Logs tab (real-time logs)
   - Dashboard → Metrics tab (CPU/Memory)

3. **Update Application**
   - Make changes locally
   - `git push origin main`
   - Render auto-redeploys within 1-2 minutes

4. **Database Backup**
   - Use Render dashboard to download backups
   - Or use `mysqldump` to export

---

## 📞 Getting Help

### If Deployment Fails

1. Check **Logs** in dashboard
2. Common errors:
   - "Docker build failed" → Check Dockerfile syntax
   - "Service won't start" → Check render.yaml
   - "Connection timeout" → Check if GitHub repo is accessible

### If Application Won't Connect to Database

1. Check database is initialized: `mysql ... -e "SELECT * FROM users;"`
2. Verify environment variables in dashboard
3. Restart services from dashboard

### If You Get 500 Error

1. Check Render logs for error details
2. Verify `ams_schema.sql` was fully executed
3. Check that all JSP files are accessible

---

## 📋 Final Quick Reference

```bash
# GitHub Repository
https://github.com/SreeDurga07/ams

# Render Dashboard
https://dashboard.render.com

# Application URL (after deploy)
https://ams-app.onrender.com

# Login Credentials
Username: admin
Password: admin123 (or set in SQL schema)

# Database Initialization Command
mysql -h <host> -u <user> -p <password> ams_db < ams_schema.sql
```

---

## ✅ Deployment Checklist

```
Phase 1: GitHub Setup
  ☑ Code pushed to SreeDurga07/ams
  ☑ All required files included
  ☑ Dockerfile present
  ☑ render.yaml present

Phase 2: Render Deployment
  ☑ Logged into https://dashboard.render.com
  ☑ Created new Blueprint
  ☑ Connected GitHub (SreeDurga07/ams)
  ☑ Clicked Deploy
  ☑ Services building...
  ☑ Services deployed successfully

Phase 3: Database Setup
  ☑ Got MySQL credentials from dashboard
  ☑ Connected to MySQL
  ☑ Ran ams_schema.sql
  ☑ Verified tables created

Phase 4: Application Verification
  ☑ Accessed https://ams-app.onrender.com
  ☑ Login page loads
  ☑ Logged in with admin/admin123
  ☑ Dashboard accessible
  ☑ All features working

DEPLOYMENT COMPLETE! 🎉
```

---

**Ready?** Start with STEP 1 above! 🚀

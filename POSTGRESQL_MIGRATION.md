# PostgreSQL Migration Guide

## Why PostgreSQL?

Render's Blueprint feature **only supports PostgreSQL**, not MySQL. The app has been reconfigured to use PostgreSQL.

---

## What Changed

| Component | Before | After |
|-----------|--------|-------|
| Database | MySQL | PostgreSQL |
| JDBC Driver | `com.mysql.cj.jdbc.Driver` | `org.postgresql.Driver` |
| Connection URL | `jdbc:mysql://...` | `jdbc:postgresql://...` |
| DB Schema | `ams_schema.sql` (MySQL) | `ams_schema_postgresql.sql` | 

---

## Files Updated

- ✅ `render.yaml` - Changed `type: mysql` → `type: pgsql`
- ✅ `db.properties.docker` - PostgreSQL driver and URL
- ✅ `Dockerfile` - Added PostgreSQL JDBC driver
- ✅ `ams_schema_postgresql.sql` - New schema (converted from MySQL)

---

## Deployment Steps (Same as Before!)

1. Go to: **https://dashboard.render.com**
2. Click **+ New** → **Blueprint**
3. Connect GitHub → Select **SreeDurga07/ams**
4. Click **Deploy** ✅

Render will now:
- Create PostgreSQL database (`ams-db`)
- Deploy Tomcat app (`ams-app`)
- Auto-link environment variables

---

## Database Initialization

After deployment, initialize the database:

### From Render Dashboard:

1. Go to **ams-db** service
2. Click **Connect**
3. Use connection details to run:

```bash
psql -h <host> -U <user> -d ams_db < ams_schema_postgresql.sql
```

Or copy-paste the SQL from `ams_schema_postgresql.sql` into Render's web console.

---

## Default Login Credentials

```
Username: admin
Password: admin123
```

**⚠️ Change in production!**

---

## Schema Differences (MySQL → PostgreSQL)

| Feature | MySQL | PostgreSQL |
|---------|-------|-----------|
| Auto-increment | `AUTO_INCREMENT` | `SERIAL` |
| Update timestamp | `ON UPDATE CURRENT_TIMESTAMP` | Trigger + Function |
| ENUM | Native `ENUM` | `VARCHAR` + `CHECK` |
| Timestamps | `DATETIME` | `TIMESTAMP` |

All converted in `ams_schema_postgresql.sql` ✅

---

## Application Code - No Changes Needed

The Java code in `DBConnection.java` loads driver from `db.properties`:

```properties
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://...
db.user=...
db.password=...
```

**All database-specific code reads from properties file!** ✅

---

## If You Need MySQL Later

You can use external MySQL providers:
- AWS RDS MySQL
- DigitalOcean Managed Databases
- Google Cloud SQL
- Azure Database for MySQL

Then just update `db.properties` with MySQL connection details.

---

## Quick Checklist

- [ ] Read `render.yaml` - uses PostgreSQL ✅
- [ ] Check `db.properties.docker` - PostgreSQL config ✅
- [ ] Use `ams_schema_postgresql.sql` for initialization ✅
- [ ] Deploy via Blueprint (as before)
- [ ] Login works after schema initialization ✅

---

**Everything is ready for Render deployment with PostgreSQL!** 🚀

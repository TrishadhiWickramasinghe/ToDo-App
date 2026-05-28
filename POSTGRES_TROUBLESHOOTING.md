# PostgreSQL Connection Troubleshooting Guide

## Error You're Seeing
```
SQLSTATE[08006] [7] connection to server at "127.0.0.1", port 5432 failed: 
FATAL: password authentication failed for user "postgre"
```

This means: **PostgreSQL rejected the password for the database user**

---

## Quick Fixes

### 1. Check if PostgreSQL is Running

**Windows Command Prompt:**
```bash
sc query postgresql-x64-14
```

**Windows PowerShell:**
```powershell
Get-Service postgresql-x64-14 | Select-Object Status
```

**Should show**: `STATE : 4 RUNNING`

**If not running, start it:**
```bash
net start postgresql-x64-14
```

---

### 2. Verify Database Connection Credentials

Check `.env` file:
```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=ToDo_App
DB_USERNAME=postgres
DB_PASSWORD=root2002
```

**All values must be exactly as above**

---

### 3. Check PostgreSQL User & Password

**Connect to PostgreSQL:**
```bash
# Open Command Prompt
psql -U postgres -h 127.0.0.1
```

**If you see password prompt:**
- Type: `root2002`
- If connection succeeds, password is correct ✅

**If connection fails:**
- Password is wrong ❌
- Need to reset it

---

### 4. Reset PostgreSQL Password

**Option A: Using pgAdmin GUI (Easiest)**
1. Open pgAdmin (installed with PostgreSQL)
2. Connect to local server
3. Right-click "Servers" → Properties
4. Set password for `postgres` user
5. Set it to: `root2002`

**Option B: Using Command Line**

Stop PostgreSQL first:
```bash
net stop postgresql-x64-14
```

Find PostgreSQL bin directory (usually):
```
C:\Program Files\PostgreSQL\16\bin
```

Or if using XAMPP:
```
C:\xampp\postgresql\bin
```

Navigate there and reset password:
```bash
cd "C:\Program Files\PostgreSQL\16\bin"
psql -U postgres -h 127.0.0.1 -c "ALTER ROLE postgres WITH PASSWORD 'root2002';"
```

Restart PostgreSQL:
```bash
net start postgresql-x64-14
```

---

### 5. Create the Database

```bash
# Connect to PostgreSQL
psql -U postgres -h 127.0.0.1

# Inside psql prompt (after entering password), run:
CREATE DATABASE "ToDo_App";

# Verify it was created:
\l

# Exit:
\q
```

---

### 6. Run Laravel Migrations

```bash
cd backend-todoapp
php artisan migrate
```

Should output:
```
Migrating: 2014_10_12_000000_create_users_table
Migrated:  2014_10_12_000000_create_users_table
...
```

---

## Complete Step-by-Step Solution

### Step 1: Stop PostgreSQL
```bash
net stop postgresql-x64-14
```

### Step 2: Start PostgreSQL  
```bash
net start postgresql-x64-14
```

### Step 3: Connect and Verify
```bash
psql -U postgres -h 127.0.0.1
```

At password prompt, type: `root2002`

### Step 4: Create Database (if not exists)
```sql
CREATE DATABASE "ToDo_App";
\q
```

### Step 5: Run Migrations
```bash
cd backend-todoapp
php artisan migrate
```

---

## If Still Getting Error

### Check PostgreSQL Log
```
C:\Program Files\PostgreSQL\16\data\log\
```

Or:
```
C:\xampp\postgresql\data\postgresql.log
```

### Verify .env is correct
```bash
cd backend-todoapp
type .env | findstr "DB_"
```

Should show:
```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=ToDo_App
DB_USERNAME=postgres
DB_PASSWORD=root2002
```

### Clear Laravel Cache
```bash
php artisan cache:clear
php artisan config:clear
```

### Try migrations again
```bash
php artisan migrate --force
```

---

## Alternative: Use SQLite Instead (Temporary)

If PostgreSQL is too difficult, you can use SQLite temporarily:

**Update .env:**
```
DB_CONNECTION=sqlite
# Comment out all other DB_ settings
```

**Create database:**
```bash
cd backend-todoapp
touch database/database.sqlite
php artisan migrate
```

---

## Common Issues & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `FATAL: password authentication failed` | Wrong password | Reset password to `root2002` |
| `connection to server failed` | PostgreSQL not running | `net start postgresql-x64-14` |
| `database "ToDo_App" does not exist` | Database not created | Run: `CREATE DATABASE "ToDo_App";` |
| `Port 5432 is already in use` | Another service using port | Check what's using port 5432 |

---

## Verify Everything is Working

After completing all steps:

```bash
# Test connection
psql -U postgres -h 127.0.0.1 -d ToDo_App -c "SELECT 1;"
```

Should output: `1`

```bash
# Test Laravel connection
cd backend-todoapp
php artisan tinker
>>> DB::connection()->getPdo()
>>> DB::table('users')->count()
>>> exit
```

Should work without errors ✅

---

## Need More Help?

Check:
1. PostgreSQL service is running
2. Password is exactly: `root2002`
3. Database exists: `ToDo_App`
4. .env has correct credentials
5. Run: `php artisan migrate`

If still failing, provide:
- Output of: `php artisan tinker` → `DB::connection()->getPdo()`
- Output of: `psql --version`
- PostgreSQL error logs

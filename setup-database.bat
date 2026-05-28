@echo off
REM PostgreSQL Setup Script for Windows

echo.
echo ====================================================
echo    PostgreSQL Setup & Database Creation
echo ====================================================
echo.

REM Check if PostgreSQL service is running
echo Checking PostgreSQL service status...
sc query postgresql-x64-14 > nul 2>&1

if errorlevel 1 (
    echo PostgreSQL service not found. Attempting to start...
    net start postgresql-x64-14
) else (
    echo PostgreSQL service is installed.
    for /f "tokens=3" %%A in ('sc query postgresql-x64-14 ^| find "STATE"') do (
        if "%%A"=="RUNNING" (
            echo PostgreSQL is already running.
        ) else (
            echo Starting PostgreSQL service...
            net start postgresql-x64-14
        )
    )
)

echo.
echo ====================================================
echo    Creating Database
echo ====================================================
echo.

REM Create database using psql
REM This requires PostgreSQL to be in PATH or you need the full path
psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE \"ToDo_App\";" 2>nul

if errorlevel 1 (
    echo Database creation failed. Trying alternative method...
    echo Please ensure PostgreSQL password is: root2002
    echo.
    echo Run this command manually in Command Prompt:
    echo psql -U postgres -h 127.0.0.1
    echo Then type: CREATE DATABASE "ToDo_App";
) else (
    echo Database created successfully!
)

echo.
echo ====================================================
echo    Running Laravel Migrations
echo ====================================================
echo.

cd backend-todoapp
php artisan migrate --force

echo.
echo ====================================================
echo    Setup Complete!
echo ====================================================
echo.
pause

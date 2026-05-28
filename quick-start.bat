@echo off
REM TodoApp Authentication System - Quick Start for Windows

cls
echo.
echo ====================================================
echo    TodoApp Authentication System - Quick Start
echo ====================================================
echo.

echo [Step 1] Starting Backend Server (Laravel)
echo Command: cd backend-todoapp ^&^& php artisan serve
echo.
echo Please run this command in a NEW Command Prompt/PowerShell window
echo.

pause

cls
echo.
echo ====================================================
echo    TodoApp Frontend - Quick Start
echo ====================================================
echo.

echo [Step 2] Check Frontend Dependencies
if not exist "todo-app\node_modules" (
    echo Installing dependencies...
    cd todo-app
    call npm install
    cd ..
)

echo.
echo [Step 3] Starting Frontend Server (Next.js)
echo Command: cd todo-app ^&^& npm run dev
echo.

cd todo-app
call npm run dev

pause

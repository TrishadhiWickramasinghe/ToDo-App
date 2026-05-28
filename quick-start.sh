#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   TodoApp Authentication System - Quick Start Script${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "${YELLOW}Windows detected. Using PowerShell commands...${NC}"
    echo ""
    echo -e "${BLUE}1. Starting Backend (Laravel) Server...${NC}"
    echo -e "   ${GREEN}Command: cd backend-todoapp && php artisan serve${NC}"
    echo ""
    echo -e "${BLUE}2. In a NEW Terminal, start Frontend (Next.js) Server...${NC}"
    echo -e "   ${GREEN}Command: cd todo-app && npm run dev${NC}"
    echo ""
    echo -e "${BLUE}3. Open Browser...${NC}"
    echo -e "   ${GREEN}URL: http://localhost:3000${NC}"
    echo ""
    exit 0
fi

# For Unix-like systems (macOS, Linux)
echo -e "${BLUE}Step 1: Starting Backend Server...${NC}"
echo ""

# Check if backend directory exists
if [ ! -d "backend-todoapp" ]; then
    echo -e "${YELLOW}⚠ backend-todoapp directory not found!${NC}"
    exit 1
fi

# Navigate to backend and start server
cd backend-todoapp

# Check if artisan exists
if [ ! -f "artisan" ]; then
    echo -e "${YELLOW}⚠ Laravel artisan not found. Make sure composer dependencies are installed.${NC}"
    exit 1
fi

# Start Laravel in background
echo -e "${GREEN}✓ Starting Laravel development server...${NC}"
php artisan serve &
BACKEND_PID=$!

echo -e "${GREEN}✓ Backend running at http://127.0.0.1:8000${NC}"
echo ""

# Give backend time to start
sleep 3

# Return to root directory
cd ..

# Navigate to frontend
if [ ! -d "todo-app" ]; then
    echo -e "${YELLOW}⚠ todo-app directory not found!${NC}"
    kill $BACKEND_PID
    exit 1
fi

cd todo-app

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}Step 2: Installing Frontend Dependencies...${NC}"
    npm install
    echo ""
fi

# Start Next.js in background
echo -e "${BLUE}Step 3: Starting Frontend Server...${NC}"
echo -e "${GREEN}✓ Starting Next.js development server...${NC}"
npm run dev &
FRONTEND_PID=$!

echo -e "${GREEN}✓ Frontend running at http://localhost:3000${NC}"
echo ""

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Both servers are running!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "  1. Open http://localhost:3000 in your browser"
echo -e "  2. You should be redirected to /login"
echo -e "  3. Click 'Create a free account' to register"
echo -e "  4. Fill in the registration form"
echo -e "  5. Click 'Create account' button"
echo ""
echo -e "${YELLOW}To stop servers:${NC}"
echo -e "  Press Ctrl+C to stop Next.js"
echo -e "  Press Ctrl+C again to stop Laravel"
echo ""

# Wait for both processes
wait

echo -e "${BLUE}Servers stopped.${NC}"

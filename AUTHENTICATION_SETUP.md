# Authentication System Setup & Testing Guide

## System Overview

### Backend (Laravel 11)
- **Location**: `backend-todoapp/`
- **Authentication**: Laravel Sanctum (token-based API authentication)
- **Database**: PostgreSQL
- **Server**: http://127.0.0.1:8000

### Frontend (Next.js with TypeScript)
- **Location**: `todo-app/`
- **Framework**: Next.js 16.2.6 with App Router
- **State Management**: React Context (AuthContext)
- **HTTP Client**: Axios with interceptors
- **UI**: Tailwind CSS

---

## Backend Setup Checklist

### 1. Verify Laravel Installation
```bash
cd backend-todoapp
php artisan --version
```
Expected: Laravel Framework 11.x.x

### 2. Check Sanctum Installation
```bash
php artisan tinker
>>> \Laravel\Sanctum\Sanctum::class
>>> exit
```

### 3. Verify Database Connection
```bash
php artisan tinker
>>> DB::connection()->getPdo()
>>> DB::table('users')->count()
>>> exit
```

### 4. Key Backend Files Created/Updated

- ✅ `app/Models/User.php` - HasApiTokens trait added
- ✅ `app/Http/Controllers/AuthController.php` - register, login, logout, me methods
- ✅ `app/Http/Requests/RegisterRequest.php` - Validation & error handling
- ✅ `app/Http/Requests/LoginRequest.php` - Validation & error handling
- ✅ `routes/api.php` - Auth routes configured

### 5. Database Migration
```bash
php artisan migrate
```

### 6. Test Backend Server
```bash
php artisan serve
```
Visit: http://127.0.0.1:8000 - should see Laravel welcome page

---

## Frontend Setup Checklist

### 1. Install Dependencies
```bash
cd todo-app
npm install
```

### 2. Build Check
```bash
npm run build
```

### 3. Key Frontend Files

- ✅ `services/axiosInstance.ts` - Axios configuration with auth token interceptor
- ✅ `services/authService.ts` - API calls for login, register, logout
- ✅ `context/AuthContext.tsx` - Auth state management
- ✅ `components/auth/LoginForm.tsx` - Login UI with validation
- ✅ `components/auth/RegisterForm.tsx` - Register UI with validation
- ✅ `hooks/useRouteProtection.ts` - Protected route wrapper
- ✅ `.env.local` - API configuration
- ✅ `app/layout.tsx` - AuthProvider setup

### 4. Environment Configuration
`.env.local` contents:
```
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api
```

---

## API Endpoints Reference

### Public Routes

#### POST `/api/register`
**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "token": "1|abcdefghijklmnopqrstuvwxyz...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Validation Error (422):**
```json
{
  "success": false,
  "message": "Validation errors",
  "errors": {
    "email": ["Email is already registered"],
    "password": ["Password must be at least 8 characters"]
  }
}
```

#### POST `/api/login`
**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "1|abcdefghijklmnopqrstuvwxyz...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Invalid Credentials (401):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### Protected Routes (Requires `Authorization: Bearer {token}` header)

#### POST `/api/logout`
**Headers:**
```
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

#### GET `/api/me`
**Headers:**
```
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**Unauthorized (401):**
```json
{
  "success": false,
  "message": "Unauthenticated"
}
```

---

## Testing the Full Authentication Flow

### Step 1: Start Backend Server
```bash
cd backend-todoapp
php artisan serve
```
Terminal output:
```
Starting Laravel development server: http://127.0.0.1:8000
```

### Step 2: Start Frontend Development Server
```bash
cd todo-app
npm run dev
```
Terminal output:
```
> todo-app@0.1.0 dev
> next dev

  ▲ Next.js 16.2.6
  - Local:        http://localhost:3000
```

### Step 3: Manual API Testing with cURL

**Test Registration:**
```bash
curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

**Test Login:**
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Test Protected Route (replace TOKEN with actual token):**
```bash
curl -X GET http://127.0.0.1:8000/api/me \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json"
```

### Step 4: Test in Browser

1. Open http://localhost:3000
2. Should redirect to login page (/login)
3. Click "Create a free account" link
4. Fill registration form:
   - Name: Test User
   - Email: test@example.com
   - Password: password123
   - Confirm Password: password123
5. Click "Create account" button
6. Should see success toast: "Account created! Welcome aboard 🚀"
7. Should redirect to /dashboard
8. Should see authenticated user data

### Step 5: Test Logout
1. On dashboard, look for logout button (in Navbar component)
2. Click logout
3. Should redirect to /login
4. localStorage should be cleared

---

## Frontend Auth Flow

### 1. Registration Flow
```
User fills RegisterForm
  ↓
Form validation (client-side)
  ↓
POST /api/register with data
  ↓
Backend validation
  ↓
Create user & generate token
  ↓
Save token & user to localStorage
  ↓
Update AuthContext
  ↓
Redirect to /dashboard
```

### 2. Login Flow
```
User fills LoginForm
  ↓
Form validation (client-side)
  ↓
POST /api/login with credentials
  ↓
Backend validates credentials
  ↓
Generate token on success
  ↓
Save token & user to localStorage
  ↓
Update AuthContext
  ↓
Redirect to /dashboard
```

### 3. Protected Routes Flow
```
Access /dashboard
  ↓
Check AuthContext.isAuthenticated
  ↓
If false → redirect to /login
  ↓
If true → render dashboard
  ↓
useRouteProtection hook handles redirects
```

### 4. Persistent Auth Flow
```
Browser refresh
  ↓
AuthProvider checks localStorage on mount
  ↓
If token exists → restore to context
  ↓
User stays logged in
  ↓
If token expired → API returns 401
  ↓
Interceptor clears localStorage
  ↓
Redirect to /login
```

---

## Troubleshooting

### Issue: Cannot connect to backend
**Solution:**
1. Verify backend server running: `php artisan serve`
2. Check `.env.local`: `NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api`
3. Verify PostgreSQL is running
4. Check CORS in Laravel (should allow localhost:3000)

### Issue: 401 Unauthenticated errors
**Solution:**
1. Verify token is saved in localStorage
2. Check Sanctum middleware in `routes/api.php`
3. Verify `Authorization: Bearer {token}` header is sent
4. Check token format in axios interceptor

### Issue: Registration fails with validation errors
**Solution:**
1. Check backend validation rules in `RegisterRequest.php`
2. Email must be unique (check DB for duplicates)
3. Password must be minimum 8 characters
4. Passwords must match

### Issue: Frontend shows blank page
**Solution:**
1. Check browser console for errors
2. Verify `AuthProvider` wraps all children in `layout.tsx`
3. Check `useAuth()` is only used in client components (`'use client'`)
4. Verify `.env.local` is created

---

## Next Steps After Authentication

Once authentication is fully tested:

1. **Create Todo CRUD endpoints** in Laravel
2. **Add Todo types/interfaces** in frontend
3. **Implement Todo list page** (/dashboard)
4. **Add create/edit/delete UI** components
5. **Connect Todo APIs** with context management
6. **Add pagination & filtering**
7. **Deployment** to production

---

## Files Modified/Created Summary

### Backend
- ✅ `app/Http/Controllers/AuthController.php` - Created
- ✅ `app/Http/Requests/RegisterRequest.php` - Already created with validation
- ✅ `app/Http/Requests/LoginRequest.php` - Already created with validation
- ✅ `app/Models/User.php` - Updated with Sanctum
- ✅ `routes/api.php` - Auth routes configured

### Frontend
- ✅ `services/axiosInstance.ts` - Axios setup with interceptors
- ✅ `services/authService.ts` - Auth API calls
- ✅ `context/AuthContext.tsx` - Auth state management
- ✅ `components/auth/LoginForm.tsx` - Login UI
- ✅ `components/auth/RegisterForm.tsx` - Register UI
- ✅ `hooks/useRouteProtection.ts` - Route protection
- ✅ `.env.local` - API configuration
- ✅ `app/layout.tsx` - AuthProvider setup

---

## Key Configuration Values

| Variable | Value | Purpose |
|----------|-------|---------|
| Backend URL | http://127.0.0.1:8000 | Laravel development server |
| API Base URL | http://127.0.0.1:8000/api | API endpoints |
| Frontend URL | http://localhost:3000 | Next.js development server |
| Database | ToDo_App (PostgreSQL) | User data storage |
| Token Storage | localStorage | Browser-based auth persistence |
| Token Header | Authorization: Bearer {token} | API authentication |


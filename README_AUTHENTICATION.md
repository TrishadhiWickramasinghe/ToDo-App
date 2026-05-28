# TodoApp - Complete Authentication System

A modern, production-ready authentication system built with **Laravel 11 + Sanctum** backend and **Next.js 16** frontend with **React Context** state management.

## 🎯 Features

### ✅ Implemented
- **User Registration** with validation and error handling
- **User Login** with email/password authentication
- **Token-based API Authentication** (Laravel Sanctum)
- **Protected Routes** - Dashboard requires authentication
- **Persistent Authentication** - Token stored in localStorage
- **Auto-logout** - Handles 401 responses from API
- **Beautiful Dark UI** - Modern Tailwind CSS design
- **Form Validation** - Client-side and server-side validation
- **Error Handling** - Toast notifications and inline error messages
- **Responsive Design** - Mobile-friendly interface

## 🏗️ Architecture

### Backend Stack
- **Framework**: Laravel 11
- **Authentication**: Laravel Sanctum (token-based API auth)
- **Database**: PostgreSQL
- **HTTP Server**: Built-in PHP development server

### Frontend Stack
- **Framework**: Next.js 16 with App Router
- **Language**: TypeScript
- **State Management**: React Context API
- **HTTP Client**: Axios with interceptors
- **UI Framework**: Tailwind CSS
- **Notifications**: React Hot Toast

## 📁 Project Structure

```
TodoApp/
├── backend-todoapp/              # Laravel API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   └── AuthController.php          ← Authentication logic
│   │   │   └── Requests/
│   │   │       ├── RegisterRequest.php         ← Validation rules
│   │   │       └── LoginRequest.php            ← Validation rules
│   │   └── Models/
│   │       └── User.php                        ← User model with Sanctum
│   ├── routes/
│   │   └── api.php                             ← API endpoints
│   ├── .env                                    ← Configuration
│   └── database/
│       └── migrations/                         ← User table
│
├── todo-app/                     # Next.js Frontend
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx                    ← Login page
│   │   │   ├── register/
│   │   │   │   └── page.tsx                    ← Register page
│   │   │   └── layout.tsx                      ← Auth route group
│   │   ├── (dashboard)/
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx                    ← Protected dashboard
│   │   │   └── layout.tsx                      ← Dashboard layout
│   │   ├── layout.tsx                          ← Root layout with providers
│   │   ├── page.tsx                            ← Home (redirects to login/dashboard)
│   │   └── globals.css                         ← Global styles
│   │
│   ├── components/
│   │   ├── auth/
│   │   │   ├── LoginForm.tsx                   ← Login form component
│   │   │   └── RegisterForm.tsx                ← Register form component
│   │   └── common/
│   │       └── Loader.tsx                      ← Loading spinner
│   │
│   ├── context/
│   │   └── AuthContext.tsx                     ← Auth state management
│   │
│   ├── services/
│   │   ├── axiosInstance.ts                    ← Axios configuration
│   │   └── authService.ts                      ← Auth API calls
│   │
│   ├── hooks/
│   │   └── useRouteProtection.ts               ← Route protection logic
│   │
│   ├── utils/
│   │   └── validation.ts                       ← Form validation
│   │
│   ├── .env.local                              ← Environment variables
│   └── package.json                            ← Dependencies
│
└── AUTHENTICATION_SETUP.md                     ← Detailed setup guide
```

## 🚀 Quick Start

### Prerequisites
- PHP 8.2+ (with `php-pgsql` extension)
- Node.js 18+
- PostgreSQL 12+ (running and configured)
- Composer 2.0+

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend-todoapp
   ```

2. **Start Laravel development server:**
   ```bash
   php artisan serve
   ```
   
   Expected output:
   ```
   Starting Laravel development server: http://127.0.0.1:8000
   ```

### Frontend Setup

1. **In a NEW terminal, navigate to frontend directory:**
   ```bash
   cd todo-app
   ```

2. **Install dependencies (if not already done):**
   ```bash
   npm install
   ```

3. **Start Next.js development server:**
   ```bash
   npm run dev
   ```
   
   Expected output:
   ```
   ▲ Next.js 16.2.6
   - Local:        http://localhost:3000
   ```

4. **Open browser and visit:**
   ```
   http://localhost:3000
   ```

## 🔐 Authentication Flow

### Registration Flow
```
1. User enters name, email, password
2. Form validation (client-side)
3. POST /api/register
4. Backend creates user and generates token
5. Token & user data saved to localStorage
6. Redirect to dashboard
```

### Login Flow
```
1. User enters email and password
2. Form validation (client-side)
3. POST /api/login
4. Backend validates credentials
5. Token & user data saved to localStorage
6. Redirect to dashboard
```

### Protected Routes
```
1. Access /dashboard
2. useProtectedRoute checks localStorage for token
3. If not authenticated → redirect to /login
4. If authenticated → render dashboard
```

## 📡 API Endpoints

### Public Endpoints (No Authentication Required)

#### `POST /api/register`
Register a new user.

**Request:**
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

#### `POST /api/login`
Authenticate user and get token.

**Request:**
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

### Protected Endpoints (Require Authentication)

#### `POST /api/logout`
Revoke current access token.

**Request Headers:**
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

#### `GET /api/me`
Get current authenticated user.

**Request Headers:**
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

## 🧪 Testing

### Manual API Testing with cURL

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

**Test Protected Route:**
```bash
curl -X GET http://127.0.0.1:8000/api/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

### Browser Testing

1. Go to http://localhost:3000
2. Should redirect to /login (not authenticated)
3. Click "Create a free account"
4. Fill in registration form with:
   - Name: Any name
   - Email: Unique email
   - Password: 8+ characters
5. Click "Create account"
6. Should see success toast and redirect to dashboard
7. Look for logout button in navbar

## 🔧 Configuration

### Backend (.env)
```bash
APP_DEBUG=true
APP_URL=http://127.0.0.1:8000

# Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=ToDo_App
DB_USERNAME=postgre
DB_PASSWORD=root2002
```

### Frontend (.env.local)
```bash
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api
```

## 🛠️ Troubleshooting

### Issue: Cannot connect to backend API
**Solution:**
- Verify Laravel server is running: `php artisan serve`
- Check `.env.local`: `NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api`
- Verify PostgreSQL is running

### Issue: 401 Unauthenticated errors
**Solution:**
- Check browser localStorage has `authToken`
- Verify token format starts with a number and pipe: `1|...`
- Check Sanctum middleware is configured

### Issue: Registration fails with validation error
**Solution:**
- Email must be unique (try different email)
- Password must be 8+ characters
- Passwords must match exactly
- Name is required

### Issue: Cannot start frontend
**Solution:**
```bash
cd todo-app
npm install
npm run dev
```

### Issue: Cannot start backend
**Solution:**
```bash
cd backend-todoapp
php artisan migrate
php artisan serve
```

## 📚 Documentation Files

- **AUTHENTICATION_SETUP.md** - Comprehensive setup and testing guide
- **API_DOCUMENTATION.md** - Detailed API endpoint documentation (when created)
- **FRONTEND_STRUCTURE.md** - Frontend component architecture (when created)

## 🚦 Status

| Component | Status | Notes |
|-----------|--------|-------|
| Backend Setup | ✅ Complete | Laravel 11 with Sanctum |
| User Authentication | ✅ Complete | Register, Login, Logout |
| API Routes | ✅ Complete | All endpoints configured |
| Frontend Auth Context | ✅ Complete | Token management & persistence |
| Login Form | ✅ Complete | With validation & error handling |
| Register Form | ✅ Complete | With validation & error handling |
| Protected Routes | ✅ Complete | Auto-redirect based on auth state |
| Dashboard Page | ✅ Complete | Protected and requires auth |
| Error Handling | ✅ Complete | Toast notifications & validation messages |
| Database | ✅ Configured | PostgreSQL connected |

## 🎓 Next Steps

1. **Test the authentication system** thoroughly
2. **Create Todo CRUD APIs** in backend
3. **Build Todo list UI** in frontend
4. **Implement todo features**
5. **Add email verification** (optional)
6. **Add password reset** (optional)
7. **Deploy to production**

## 📝 Key Features Explained

### Token-Based Authentication
- Uses JWT-like tokens generated by Sanctum
- Token stored in browser's `localStorage`
- Token automatically added to API requests via axios interceptor
- 401 responses trigger automatic logout and redirect

### Form Validation
- Client-side validation with immediate feedback
- Server-side validation with detailed error messages
- Field-level error display
- Beautiful error styling with animations

### Protected Routes
- Dashboard requires valid token
- Unauthenticated users redirected to login
- Authenticated users redirected away from login/register
- Route protection handled by custom hooks

### State Persistence
- Token persists in localStorage
- Survives browser refresh
- Automatic cleanup on logout
- Automatic cleanup on 401 error

## 🤝 Contributing

This is a learning project. Feel free to modify and improve the code!

## 📄 License

This project is open source and available under the MIT license.

---

**Built with ❤️ using Laravel 11 + Next.js 16**

For detailed setup instructions and troubleshooting, see [AUTHENTICATION_SETUP.md](./AUTHENTICATION_SETUP.md)

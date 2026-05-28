# Backend API - Frontend Integration Guide

## Quick Summary

Your Laravel backend is **COMPLETE** and **PRODUCTION READY**. All CRUD operations are fully functional with Sanctum authentication.

## Environment Setup

### Database Configuration (Already Set)
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=ToDo_App
DB_USERNAME=postgres
DB_PASSWORD=root2002
```

### API Base URL
```
http://localhost:8000/api
```

## Authentication Flow

### 1. Register User
```bash
POST /register
```

### 2. Login User (Get Token)
```bash
POST /login
Response includes: "token": "..."
```

### 3. Use Token in All Requests
```
Authorization: Bearer YOUR_TOKEN_HERE
```

## API Endpoints Ready for Frontend Integration

### ✅ Create Todo (PRIMARY FEATURE)
```
POST /api/todos
Auth: Required
Status: 201 Created

Request:
{
  "title": "string (3-255 chars)",
  "description": "string optional (max 1000 chars)"
}

Response:
{
  "success": true,
  "message": "Todo created successfully",
  "data": {
    "id": 1,
    "title": "...",
    "description": "...",
    "status": "pending",
    "user_id": 5,
    "created_at": "2026-05-28T11:06:05Z",
    "updated_at": "2026-05-28T11:06:05Z"
  }
}
```

### ✅ Get All Todos
```
GET /api/todos
Auth: Required
Status: 200 OK

Response:
{
  "success": true,
  "data": [
    { id, user_id, title, description, status, created_at, updated_at },
    ...
  ]
}
```

### ✅ Get Single Todo
```
GET /api/todos/{id}
Auth: Required
Status: 200 OK
```

### ✅ Update Todo
```
PUT /api/todos/{id}
Auth: Required
Status: 200 OK

Fields you can update:
- title
- description
- status (pending|completed)
```

### ✅ Delete Todo
```
DELETE /api/todos/{id}
Auth: Required
Status: 200 OK
```

## Validation Rules

### Title
- Required
- String
- Minimum: 3 characters
- Maximum: 255 characters

### Description
- Optional
- String
- Maximum: 1000 characters

## Error Responses

### 401 Unauthorized (No Token)
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden (Accessing Other User's Todo)
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "title": ["Title must be at least 3 characters"]
  }
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Failed to create todo",
  "error": "..."
}
```

## Status Codes

- `200 OK` - Successful GET/PUT/DELETE
- `201 Created` - Successful POST
- `401 Unauthorized` - Missing/invalid token
- `403 Forbidden` - Accessing other user's data
- `422 Unprocessable Entity` - Validation error
- `500 Internal Server Error` - Server error

## Frontend Implementation Tips

### 1. Store Token After Login
```javascript
const response = await fetch('http://localhost:8000/api/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});

const data = await response.json();
localStorage.setItem('token', data.data.token); // Save token
```

### 2. Use Token in All Requests
```javascript
const token = localStorage.getItem('token');

const response = await fetch('http://localhost:8000/api/todos', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({ title, description })
});
```

### 3. Handle Validation Errors
```javascript
if (!response.ok) {
  const error = await response.json();
  if (response.status === 422) {
    console.log('Validation errors:', error.errors);
    // Show error messages to user
  }
}
```

### 4. Create Todo Example (React)
```javascript
async function createTodo(title, description) {
  const token = localStorage.getItem('token');
  
  try {
    const response = await fetch('http://localhost:8000/api/todos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ title, description })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message);
    }

    const data = await response.json();
    console.log('Todo created:', data.data);
    return data.data;
  } catch (error) {
    console.error('Error creating todo:', error);
  }
}
```

## Database Schema

### todos Table
```
Column          | Type      | Constraint
----------------|-----------|-------------------
id              | bigint    | PRIMARY KEY
user_id         | bigint    | FOREIGN KEY (users.id)
title           | varchar   | NOT NULL
description     | text      | NULLABLE
status          | enum      | DEFAULT 'pending'
created_at      | timestamp | 
updated_at      | timestamp |
```

## Testing with Postman

1. Set Environment Variable:
   - Name: `token`
   - Value: `9|ee7H45lm2q5HkJq0dK2mqPmfhMcwMHdhhN4hLWfufef38d4a`

2. Create Request:
   - Method: POST
   - URL: `http://localhost:8000/api/todos`
   - Headers:
     - `Authorization: Bearer {{token}}`
     - `Content-Type: application/json`
   - Body:
     ```json
     {
       "title": "Your Title",
       "description": "Your Description"
     }
     ```

## Current Test Data

**User Account for Testing:**
- Email: test@example.com
- Password: password
- User ID: 5
- Valid Token: `9|ee7H45lm2q5HkJq0dK2mqPmfhMcwMHdhhN4hLWfufef38d4a`

## Files Modified/Created

✅ `app/Models/User.php` - Added hasMany relationship
✅ `app/Models/Todo.php` - Complete with relationships
✅ `app/Http/Controllers/TodoController.php` - All CRUD methods
✅ `app/Http/Requests/CreateTodoRequest.php` - Updated validation
✅ `app/Http/Requests/UpdateTodoRequest.php` - Update validation
✅ `database/migrations/2026_05_28_000000_create_todos_table.php` - Todos table
✅ `routes/api.php` - API routes configured

## Next Steps

1. **Update Frontend Form Submission:**
   - Replace mock data submission with real API call to `POST /api/todos`
   - Add Authorization header with stored token

2. **Fetch Real Todos:**
   - Replace mock data loading with real API call to `GET /api/todos`
   - Display real data from database

3. **Implement Edit/Delete:**
   - Wire edit button to `PUT /api/todos/{id}`
   - Wire delete button to `DELETE /api/todos/{id}`

4. **Handle Real Responses:**
   - Update UI based on `success` and `message` fields
   - Show validation errors from `errors` object
   - Display status/completion percentage from real data

## Production Checklist

- ✅ Database migrations created and tested
- ✅ Models defined with relationships
- ✅ Validation rules implemented (3-255 title, 1000 description)
- ✅ Authentication middleware (Sanctum) configured
- ✅ Error handling with try-catch blocks
- ✅ JSON response format standardized
- ✅ API routes protected
- ✅ User data isolation enforced
- ✅ Cascade delete on user deletion
- ✅ API endpoints tested and verified

## Performance Considerations

- Single user's todos: Indexed by `user_id`
- Todos ordered by `created_at` DESC for latest first
- Eager loading ready: `Todo::with('user')->get()`
- Pagination ready for large datasets

## Security

- ✅ Only authenticated users can create/modify todos
- ✅ Users can only access their own todos
- ✅ Password hashing with bcrypt
- ✅ CSRF protection enabled
- ✅ SQL injection prevention (Eloquent ORM)
- ✅ Input validation on all endpoints

---

**Status: PRODUCTION READY** ✅

All backend functionality is complete and tested. Ready for full frontend integration!

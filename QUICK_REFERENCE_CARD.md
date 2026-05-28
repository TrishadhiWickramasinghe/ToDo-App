# Backend Development - Quick Reference Card

## API Endpoints

### Authentication
```
POST /api/register    - Create account
POST /api/login       - Get auth token
GET  /api/me          - Get current user
```

### Todos CRUD
```
POST   /api/todos           - Create todo ⭐ PRIMARY
GET    /api/todos           - List all todos
GET    /api/todos/{id}      - Get single todo
PUT    /api/todos/{id}      - Update todo
DELETE /api/todos/{id}      - Delete todo
```

---

## Request/Response Examples

### CREATE TODO ⭐
```bash
POST http://localhost:8000/api/todos
Authorization: Bearer {token}
Content-Type: application/json

{"title": "Learn Laravel", "description": "Build APIs"}

# Response (201)
{
  "success": true,
  "message": "Todo created successfully",
  "data": { "id": 1, "title": "...", "status": "pending" }
}
```

### VALIDATION ERROR
```bash
# Request (invalid - too short title)
{"title": "AB"}

# Response (422)
{
  "message": "The given data was invalid.",
  "errors": {"title": ["Title must be at least 3 characters"]}
}
```

### GET TODOS
```bash
GET http://localhost:8000/api/todos
Authorization: Bearer {token}

# Response (200)
{
  "success": true,
  "data": [
    { "id": 1, "title": "...", "status": "pending" },
    { "id": 2, "title": "...", "status": "completed" }
  ]
}
```

### UPDATE TODO
```bash
PUT http://localhost:8000/api/todos/1
Authorization: Bearer {token}

{"status": "completed"}
# Or
{"title": "Updated title"}
# Or
{"description": "Updated description"}
```

### DELETE TODO
```bash
DELETE http://localhost:8000/api/todos/1
Authorization: Bearer {token}

# Response (200)
{"success": true, "message": "Todo deleted successfully"}
```

---

## Database Info

| Setting | Value |
|---------|-------|
| Type | PostgreSQL |
| Host | 127.0.0.1 |
| Port | 5432 |
| Database | ToDo_App |
| Username | postgres |
| Password | root2002 |

---

## Validation Rules

| Field | Rules |
|-------|-------|
| title | required, 3-255 characters |
| description | optional, max 1000 characters |
| status | pending or completed |

---

## HTTP Status Codes

| Code | Meaning | Scenario |
|------|---------|----------|
| 200 | OK | GET, PUT, DELETE success |
| 201 | Created | POST success |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Access other user's todo |
| 422 | Validation Error | Invalid input |
| 500 | Server Error | Exception occurred |

---

## Authentication

```
1. Login to get token
2. Store token in localStorage
3. Add to all requests:
   Authorization: Bearer {YOUR_TOKEN}
```

**Test Token:**
```
9|ee7H45lm2q5HkJq0dK2mqPmfhMcwMHdhhN4hLWfufef38d4a
```

---

## Artisan Commands

```bash
# Start server
php artisan serve

# Run migrations
php artisan migrate

# Fresh migration (WARNING: deletes data)
php artisan migrate:fresh

# Rollback migrations
php artisan migrate:rollback

# Clear cache
php artisan cache:clear
php artisan config:clear

# List routes
php artisan route:list
```

---

## File Locations

```
Models:
  app/Models/User.php
  app/Models/Todo.php

Controllers:
  app/Http/Controllers/TodoController.php

Requests:
  app/Http/Requests/CreateTodoRequest.php
  app/Http/Requests/UpdateTodoRequest.php

Migrations:
  database/migrations/2026_05_28_000000_create_todos_table.php

Routes:
  routes/api.php

Config:
  .env
```

---

## CURL Commands

```bash
# Create Todo
curl -X POST http://localhost:8000/api/todos \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Task","description":"Details"}'

# Get All Todos
curl -X GET http://localhost:8000/api/todos \
  -H "Authorization: Bearer TOKEN"

# Get Single Todo
curl -X GET http://localhost:8000/api/todos/1 \
  -H "Authorization: Bearer TOKEN"

# Update Todo
curl -X PUT http://localhost:8000/api/todos/1 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"completed"}'

# Delete Todo
curl -X DELETE http://localhost:8000/api/todos/1 \
  -H "Authorization: Bearer TOKEN"
```

---

## Debugging

### Check Logs
```bash
tail -f storage/logs/laravel.log
```

### SQL Queries
```php
// In config/database.php, enable query logging
// Or use: DB::enableQueryLog(); ... dd(DB::getQueryLog());
```

### API Testing
```bash
# Test authentication
curl -X GET http://localhost:8000/api/todos

# Should return: {"message":"Unauthenticated."}
```

---

## Frontend Integration

### Store Token
```javascript
localStorage.setItem('authToken', response.data.token);
```

### Send Requests
```javascript
const token = localStorage.getItem('authToken');
const headers = {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
};
```

### Handle Errors
```javascript
if (response.status === 422) {
  // Validation error - check response.errors
}
if (response.status === 401) {
  // Not authenticated - redirect to login
}
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Unauthenticated" | Token missing or expired. Login again. |
| "Unauthorized" | Trying to access other user's data. |
| "Title must be at least 3 characters" | Title too short. Min 3 chars. |
| "Description must not exceed 1000 characters" | Description too long. Max 1000 chars. |
| Connection refused (127.0.0.1:5432) | PostgreSQL not running. Start database. |
| 500 Server Error | Check `storage/logs/laravel.log` |

---

## Production Checklist

- [ ] .env file configured
- [ ] Database created and migrated
- [ ] Authentication working
- [ ] All endpoints tested
- [ ] Error handling verified
- [ ] CORS configured (if frontend on different domain)
- [ ] Rate limiting configured (optional)
- [ ] Logging configured
- [ ] Backups configured
- [ ] SSL certificate installed

---

## Resources

- Laravel Docs: https://laravel.com/docs
- Sanctum Docs: https://laravel.com/docs/sanctum
- PostgreSQL: https://www.postgresql.org/
- Postman: https://www.postman.com/

---

## Key Constants

```
API_BASE_URL = "http://localhost:8000/api"
TOKEN_STORAGE_KEY = "authToken"
RESPONSE_TIMEOUT = 30000ms
```

---

**Last Updated:** May 28, 2026  
**Status:** ✅ Ready for Production

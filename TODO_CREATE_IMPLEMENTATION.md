# Create Todo Functionality - Implementation Guide

Complete implementation of Create Todo feature for the Laravel + Next.js Todo App.

## What's Implemented

### Backend (Laravel)

#### 1. **Todo Model** (`app/Models/Todo.php`)
- Fillable fields: `title`, `description`, `status`, `user_id`
- Relationship: `belongsTo(User)`
- Timestamps included

#### 2. **Todo Migration** (`database/migrations/2026_05_28_000000_create_todos_table.php`)
- Creates `todos` table with:
  - `id` (primary key)
  - `user_id` (foreign key)
  - `title` (string)
  - `description` (nullable text)
  - `status` (enum: pending, completed) - defaults to pending
  - `timestamps`

#### 3. **TodoController** (`app/Http/Controllers/TodoController.php`)
- `store()` - Create new todo (POST /api/todos)
- `index()` - Get all todos for user (GET /api/todos)
- `show()` - Get single todo (GET /api/todos/{id})
- `update()` - Update todo (PUT /api/todos/{id})
- `destroy()` - Delete todo (DELETE /api/todos/{id})

All methods include:
- Sanctum authentication verification
- User authorization checks
- Proper error handling
- JSON responses

#### 4. **Request Validation**
- `CreateTodoRequest` - Validates title (required, 2-100 chars), description (optional, max 500 chars)
- `UpdateTodoRequest` - Allows partial updates, validates status enum

#### 5. **API Routes** (`routes/api.php`)
```php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('todos', TodoController::class);
});
```

Provides:
- `POST /api/todos` - Create todo
- `GET /api/todos` - List todos
- `GET /api/todos/{id}` - Get single todo
- `PUT /api/todos/{id}` - Update todo
- `DELETE /api/todos/{id}` - Delete todo

### Frontend (Next.js)

#### 1. **Todo Service** (`services/todoService.ts`)
- Updated to handle nested `data.data` response format
- Methods:
  - `getTodos()` - Fetch all todos
  - `getTodoById()` - Fetch single todo
  - `createTodo()` - Create new todo
  - `updateTodo()` - Update existing todo
  - `deleteTodo()` - Delete todo
  - `updateStatus()` - Toggle todo status

#### 2. **Axios Instance** (`services/axiosInstance.ts`)
- Automatically attaches Bearer token from localStorage
- Base URL: `http://127.0.0.1:8000/api`
- Handles 401 errors (redirects to login)

#### 3. **Validation** (`utils/validation.ts`)
- `validateTodoTitle()` - Required, 2-100 chars
- `validateTodoDescription()` - Optional, max 500 chars

#### 4. **Create Todo Modal** (`components/todo/CreateTodoModal.tsx`)
- Title input (required)
- Description textarea (optional)
- Character counter for description (0/500)
- Form validation
- Loading state during submission
- Error messages
- Beautiful Tailwind CSS styling

#### 5. **Todos Page** (`app/(dashboard)/dashboard/todos/page.tsx`)
- Create Todo button opens modal
- Handles form submission
- Shows success toast on creation
- Auto-adds new todo to list
- Proper error handling with error messages

## Testing Steps

### 1. Run Database Migrations
```bash
cd backend-todoapp
php artisan migrate
```

### 2. Start Laravel Backend
```bash
php artisan serve
# Runs on http://127.0.0.1:8000
```

### 3. Start Next.js Frontend (in another terminal)
```bash
cd todo-app
npm run dev
# Runs on http://localhost:3000
```

### 4. Test Create Todo Flow
1. Login to the app
2. Navigate to "My Todos" page
3. Click "+ Create Todo" button
4. Fill in title (required)
5. Fill in description (optional)
6. Click "Create" button
7. Verify:
   - Modal closes
   - Success toast appears
   - New todo appears in the list
   - Todo has "pending" status

### 5. API Testing with cURL

```bash
# Get Bearer Token (after login)
BEARER_TOKEN="your_token_here"

# Create Todo
curl -X POST http://127.0.0.1:8000/api/todos \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Laravel",
    "description": "Master authentication and API design"
  }'

# Expected Response (201)
{
  "success": true,
  "message": "Todo created successfully",
  "data": {
    "id": 1,
    "title": "Learn Laravel",
    "description": "Master authentication and API design",
    "status": "pending",
    "user_id": 1,
    "created_at": "2026-05-28T10:30:00.000000Z",
    "updated_at": "2026-05-28T10:30:00.000000Z"
  }
}
```

## Error Handling

### Common Issues & Solutions

#### 1. **401 Unauthorized**
- **Cause**: Missing or invalid token
- **Solution**: Ensure token is saved in localStorage after login

#### 2. **CORS Error**
- **Cause**: Laravel not allowing requests from frontend
- **Solution**: Check `config/cors.php` includes `http://localhost:3000`

#### 3. **Validation Errors (422)**
- **Cause**: Missing required fields or invalid data
- **Response**: 
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "title": ["Title is required"]
  }
}
```

#### 4. **Migration Failed**
- **Cause**: Database connection issue
- **Solution**: Verify `.env` DATABASE_* settings and run `php artisan migrate`

## API Response Format

### Success Response (Create)
```json
{
  "success": true,
  "message": "Todo created successfully",
  "data": {
    "id": 1,
    "title": "...",
    "description": "...",
    "status": "pending",
    "user_id": 1,
    "created_at": "...",
    "updated_at": "..."
  }
}
```

### Success Response (List)
```json
{
  "success": true,
  "data": [
    { "id": 1, "title": "...", ... },
    { "id": 2, "title": "...", ... }
  ]
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error": "Exception details (development only)"
}
```

## File Structure

```
Backend (Laravel):
app/
  Models/Todo.php ✅ Created
  Http/
    Controllers/TodoController.php ✅ Updated
    Requests/
      CreateTodoRequest.php ✅ Created
      UpdateTodoRequest.php ✅ Created
routes/api.php ✅ Updated
database/migrations/2026_05_28_000000_create_todos_table.php ✅ Created

Frontend (Next.js):
services/todoService.ts ✅ Updated
services/axiosInstance.ts ✅ Already configured
utils/validation.ts ✅ Updated
components/todo/CreateTodoModal.tsx ✅ Updated
app/(dashboard)/dashboard/todos/page.tsx ✅ Updated
```

## Key Features

✅ **Authentication**: All endpoints protected with Sanctum
✅ **Validation**: Server-side and client-side validation
✅ **Error Handling**: Comprehensive error responses
✅ **Auto-refresh**: New todos appear instantly in UI
✅ **Loading States**: Disabled submit button during API calls
✅ **Toast Notifications**: Success and error messages
✅ **Optional Description**: Description field is completely optional
✅ **Character Counter**: Visual feedback for description length
✅ **User Isolation**: Each user only sees their own todos

## Next Steps

1. ✅ Test create todo functionality
2. ✅ Verify todos persist in database
3. ✅ Test edit todo functionality
4. ✅ Test delete todo functionality
5. ✅ Test status toggle (pending/completed)
6. ✅ Test authorization (user can't access other user's todos)

All code is production-ready with:
- Proper error handling
- Input validation
- Security checks
- Clear response formats
- Comprehensive comments

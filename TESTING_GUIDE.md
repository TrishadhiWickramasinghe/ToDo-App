# Create Todo Feature - Testing & Troubleshooting

## Pre-Flight Checklist

- [ ] Laravel backend is running on http://127.0.0.1:8000
- [ ] Next.js frontend is running on http://localhost:3000
- [ ] Database migrations have been run
- [ ] You are logged in to the app
- [ ] Authentication token is in localStorage

---

## Testing Checklist

### 1. Create Todo with Full Details
**Steps:**
1. Navigate to "My Todos" page
2. Click "+ Create Todo" button
3. Fill in:
   - Title: "Learn Laravel API"
   - Description: "Master REST API design and best practices"
4. Click "Create" button

**Expected Results:**
- ✅ Modal should close
- ✅ Success toast: "Todo created successfully! ✨"
- ✅ New todo appears at top of list
- ✅ Status shows "⏳ Pending"
- ✅ Date shows today

**Backend Check:**
```bash
# Query database
sqlite3 database.sqlite "SELECT * FROM todos ORDER BY id DESC LIMIT 1;"
```

---

### 2. Create Todo with Title Only
**Steps:**
1. Click "+ Create Todo"
2. Fill in title only: "Workout"
3. Leave description empty
4. Click "Create"

**Expected Results:**
- ✅ Modal closes
- ✅ Todo created successfully
- ✅ Description shows as empty/blank
- ✅ No errors

---

### 3. Validation Tests

#### Test 3a: Empty Title
**Steps:**
1. Click "+ Create Todo"
2. Leave title empty
3. Click "Create"

**Expected Results:**
- ❌ Modal stays open
- ❌ Error message: "Title is required"
- ❌ Button remains enabled

#### Test 3b: Title Too Short
**Steps:**
1. Title: "A"
2. Click "Create"

**Expected Results:**
- ❌ Error: "Title must be at least 2 characters"

#### Test 3c: Title Too Long
**Steps:**
1. Title: (101+ characters)
2. Click "Create"

**Expected Results:**
- ❌ Error: "Title must be less than 100 characters"

#### Test 3d: Description Too Long
**Steps:**
1. Title: "Valid Title"
2. Description: (501+ characters)
3. Click "Create"

**Expected Results:**
- ❌ Error: "Description must be less than 500 characters"
- ℹ️ Character counter shows: "501/500"

---

### 4. Loading State Test
**Steps:**
1. Click "+ Create Todo"
2. Fill in form
3. Click "Create" button
4. Quickly observe the button

**Expected Results:**
- ✅ Button becomes disabled during submission
- ✅ Loading spinner appears (if configured)
- ✅ Button re-enables after completion

---

### 5. Error Handling Test

#### Test 5a: Network Error
**Steps:**
1. Stop Laravel backend
2. Try to create a todo
3. Observe error handling

**Expected Results:**
- ❌ Toast shows error message
- ❌ Modal remains open
- ❌ Form data preserved

#### Test 5b: Validation Error from Backend
**Steps:**
1. Modify axios to send invalid data:
```typescript
// In browser console
const token = localStorage.getItem('authToken');
fetch('http://127.0.0.1:8000/api/todos', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ title: '' })
}).then(r => r.json()).then(console.log);
```

**Expected Results:**
- Response includes validation errors
- Frontend shows error toast

---

## API Testing with cURL

### Get Authentication Token
```bash
# Register new user
curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'

# Response will include: "token": "abc123..."
# Save this token for other requests
```

### Create Todo via API
```bash
TOKEN="paste_your_token_here"

curl -X POST http://127.0.0.1:8000/api/todos \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Docker",
    "description": "Master containerization and deployment"
  }'
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "Todo created successfully",
  "data": {
    "id": 1,
    "title": "Learn Docker",
    "description": "Master containerization and deployment",
    "status": "pending",
    "user_id": 1,
    "created_at": "2026-05-28T...",
    "updated_at": "2026-05-28T..."
  }
}
```

### Get All Todos
```bash
curl -X GET http://127.0.0.1:8000/api/todos \
  -H "Authorization: Bearer $TOKEN"
```

### Update Todo
```bash
curl -X PUT http://127.0.0.1:8000/api/todos/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed"
  }'
```

### Delete Todo
```bash
curl -X DELETE http://127.0.0.1:8000/api/todos/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Troubleshooting

### Issue: "401 Unauthorized" Error

**Symptoms:**
- Can't create todos
- Error: "Unauthenticated"
- Console shows 401 errors

**Solutions:**
1. Verify token exists:
   ```javascript
   console.log(localStorage.getItem('authToken'))
   ```

2. Check token format in axios:
   ```javascript
   // In browser console
   fetch('http://127.0.0.1:8000/api/me', {
     headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
   }).then(r => r.json()).then(console.log);
   ```

3. Re-login to refresh token

---

### Issue: "CORS Error"

**Symptoms:**
- Error: "Access to XMLHttpRequest blocked by CORS"
- Request appears as "FAILED" in Network tab

**Solutions:**
1. Check `config/cors.php` includes frontend URL:
   ```php
   'allowed_origins' => ['http://localhost:3000', 'http://127.0.0.1:3000'],
   ```

2. Ensure Laravel is running with `php artisan serve`

3. Clear browser cache (Ctrl+Shift+Delete)

---

### Issue: "Validation Error" (422)

**Symptoms:**
- Error: "422 Unprocessable Entity"
- Form shows validation errors

**Solutions:**
1. Check request payload:
   ```javascript
   // In browser console, Network tab
   // Look at Request body
   ```

2. Verify field names match:
   - `title` (not `todo_title`)
   - `description` (not `desc`)

3. Check validation rules in `CreateTodoRequest.php`

---

### Issue: Todos Not Appearing in UI

**Symptoms:**
- API returns success
- No toast notification
- Todo list doesn't update

**Solutions:**
1. Check browser console for errors
2. Verify `handleCreateTodo` is called:
   ```javascript
   // Add to CreateTodoModal
   console.log('Creating todo:', title, description);
   ```

3. Check response format:
   ```javascript
   // Should be response.data.data
   console.log(response.data);
   ```

4. Verify TodoContext is working:
   ```javascript
   // In browser console
   const { useTodo } = require('@/context/TodoContext');
   // Should not throw error
   ```

---

### Issue: Migration Error

**Symptoms:**
- Error when running `php artisan migrate`
- "SQLSTATE[HY000]" or similar

**Solutions:**
1. Check database connection:
   ```bash
   # In backend-todoapp
   cat .env | grep DB_
   ```

2. Verify database exists:
   ```bash
   # MySQL
   mysql -u root -p -e "SHOW DATABASES;"
   
   # SQLite
   ls -la database/database.sqlite
   ```

3. Run migration with fresh (drops all tables):
   ```bash
   php artisan migrate:fresh
   ```

4. Check for conflicting migration file names

---

### Issue: "Too many requests" Error

**Symptoms:**
- Error after multiple requests
- Rate limiting triggered

**Solutions:**
1. Wait a few seconds
2. Check for infinite loops in code
3. Verify axios interceptors aren't causing double requests:
   ```bash
   # In Network tab, look for duplicate requests
   ```

---

## Performance Testing

### Load Test: Create 100 Todos
```bash
TOKEN="your_token"

for i in {1..100}; do
  curl -X POST http://127.0.0.1:8000/api/todos \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"Todo #$i\",
      \"description\": \"Test todo $i\"
    }" \
  & # Run in background
done

wait # Wait for all to complete
```

**Expected Results:**
- ✅ All requests succeed
- ✅ Response time < 1s per request
- ✅ No database errors

---

## Debug Mode

### Enable Axios Logging
Add to `services/axiosInstance.ts`:
```typescript
axiosInstance.interceptors.request.use(
  (config) => {
    console.log('🚀 Request:', config.method?.toUpperCase(), config.url, config.data);
    return config;
  }
);

axiosInstance.interceptors.response.use(
  (response) => {
    console.log('✅ Response:', response.status, response.data);
    return response;
  },
  (error) => {
    console.error('❌ Error:', error.response?.status, error.response?.data);
    return Promise.reject(error);
  }
);
```

### Enable Backend Logging
Add to `app/Http/Controllers/TodoController.php`:
```php
\Log::info('Creating todo', ['user' => $user->id, 'title' => $request->title]);
```

Check logs:
```bash
tail -f storage/logs/laravel.log
```

---

## Success Indicators

When everything is working correctly, you should see:

✅ **Frontend:**
- Create button works
- Modal opens/closes smoothly
- Form validation shows instantly
- Success toast appears
- New todo in list immediately
- Character counter works
- Loading state while submitting

✅ **Backend:**
- POST request returns 201
- Response includes `success: true`
- Todo stored in database
- User ID matches authenticated user
- Status defaults to "pending"
- Timestamps are set correctly

✅ **Database:**
- Todo row created
- Foreign key constraint works
- Timestamps populated
- Status is "pending"

---

## Next: Integration Testing

After Create Todo works, test these features:

1. **Read Todos** - List todos for current user
2. **Update Todos** - Edit title/description
3. **Toggle Status** - Mark as completed
4. **Delete Todos** - Remove from database
5. **Authorization** - User can't access other user's todos
6. **Pagination** - Handle 100+ todos efficiently

---

## Support

If you encounter issues not covered here:

1. Check browser console (F12)
2. Check Laravel logs: `storage/logs/laravel.log`
3. Verify all files are created in correct locations
4. Run `php artisan tinker` to debug models
5. Check Network tab in DevTools for API responses

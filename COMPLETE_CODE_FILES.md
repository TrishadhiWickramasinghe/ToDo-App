# Complete Create Todo Code Files

## BACKEND - Laravel

### File 1: Todo Model
**Location**: `app/Models/Todo.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Attributes\Fillable;

#[Fillable(['title', 'description', 'status', 'user_id'])]
class Todo extends Model
{
    use \Illuminate\Database\Eloquent\Factories\HasFactory;

    protected $table = 'todos';

    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

---

### File 2: Todo Migration
**Location**: `database/migrations/2026_05_28_000000_create_todos_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('todos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('status', ['pending', 'completed'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('todos');
    }
};
```

---

### File 3: Create Todo Request Validation
**Location**: `app/Http/Requests/CreateTodoRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateTodoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|min:2|max:100',
            'description' => 'nullable|string|max:500',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Title is required',
            'title.min' => 'Title must be at least 2 characters',
            'title.max' => 'Title must not exceed 100 characters',
            'description.max' => 'Description must not exceed 500 characters',
        ];
    }
}
```

---

### File 4: Update Todo Request Validation
**Location**: `app/Http/Requests/UpdateTodoRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTodoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'sometimes|required|string|min:2|max:100',
            'description' => 'nullable|string|max:500',
            'status' => 'sometimes|required|in:pending,completed',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Title is required',
            'title.min' => 'Title must be at least 2 characters',
            'title.max' => 'Title must not exceed 100 characters',
            'description.max' => 'Description must not exceed 500 characters',
            'status.in' => 'Status must be either pending or completed',
        ];
    }
}
```

---

### File 5: Todo Controller
**Location**: `app/Http/Controllers/TodoController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use App\Http\Requests\CreateTodoRequest;
use App\Http\Requests\UpdateTodoRequest;
use Illuminate\Http\JsonResponse;

class TodoController extends Controller
{
    /**
     * POST /api/todos - Create new todo
     */
    public function store(CreateTodoRequest $request): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated',
                ], 401);
            }

            $todo = Todo::create([
                'user_id' => $user->id,
                'title' => $request->validated('title'),
                'description' => $request->validated('description'),
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Todo created successfully',
                'data' => [
                    'id' => $todo->id,
                    'title' => $todo->title,
                    'description' => $todo->description,
                    'status' => $todo->status,
                    'user_id' => $todo->user_id,
                    'created_at' => $todo->created_at,
                    'updated_at' => $todo->updated_at,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create todo',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * GET /api/todos - Get all todos for user
     */
    public function index(): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated',
                ], 401);
            }

            $todos = Todo::where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $todos,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch todos',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * GET /api/todos/{id} - Get single todo
     */
    public function show(Todo $todo): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user || $todo->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'data' => $todo,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch todo',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * PUT /api/todos/{id} - Update todo
     */
    public function update(UpdateTodoRequest $request, Todo $todo): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user || $todo->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            if ($request->has('title')) {
                $todo->title = $request->validated('title');
            }
            if ($request->has('description')) {
                $todo->description = $request->validated('description');
            }
            if ($request->has('status')) {
                $todo->status = $request->validated('status');
            }

            $todo->save();

            return response()->json([
                'success' => true,
                'message' => 'Todo updated successfully',
                'data' => $todo,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update todo',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * DELETE /api/todos/{id} - Delete todo
     */
    public function destroy(Todo $todo): JsonResponse
    {
        try {
            $user = auth('sanctum')->user();

            if (!$user || $todo->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            $todo->delete();

            return response()->json([
                'success' => true,
                'message' => 'Todo deleted successfully',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete todo',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
```

---

### File 6: API Routes
**Location**: `routes/api.php`

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TodoController;

// Public Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected Routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth Routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/profile', [AuthController::class, 'me']);

    // Todo Routes
    Route::apiResource('todos', TodoController::class);
});
```

---

## FRONTEND - Next.js

### File 7: Todo Service
**Location**: `services/todoService.ts`

```typescript
import axiosInstance from './axiosInstance';

export interface Todo {
  id: number;
  title: string;
  description: string;
  status: 'pending' | 'completed';
  created_at: string;
  updated_at: string;
}

export interface CreateTodoRequest {
  title: string;
  description: string;
}

export interface UpdateTodoRequest {
  title?: string;
  description?: string;
  status?: 'pending' | 'completed';
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
}

export const todoService = {
  getTodos: async (status?: string): Promise<Todo[]> => {
    try {
      const params = status ? { status } : {};
      const response = await axiosInstance.get('/todos', { params });
      const data = response.data.data || response.data;
      return Array.isArray(data) ? data : [];
    } catch (error) {
      throw error;
    }
  },

  getTodoById: async (id: number): Promise<Todo> => {
    const response = await axiosInstance.get(`/todos/${id}`);
    const data = response.data.data || response.data;
    return data;
  },

  createTodo: async (data: CreateTodoRequest): Promise<Todo> => {
    try {
      const response = await axiosInstance.post('/todos', data);
      const todoData = response.data.data || response.data;
      return todoData;
    } catch (error) {
      throw error;
    }
  },

  updateTodo: async (id: number, data: UpdateTodoRequest): Promise<Todo> => {
    const response = await axiosInstance.put(`/todos/${id}`, data);
    const todoData = response.data.data || response.data;
    return todoData;
  },

  deleteTodo: async (id: number): Promise<void> => {
    await axiosInstance.delete(`/todos/${id}`);
  },

  updateStatus: async (id: number, status: 'pending' | 'completed'): Promise<Todo> => {
    const response = await axiosInstance.put(`/todos/${id}`, { status });
    const todoData = response.data.data || response.data;
    return todoData;
  },
};
```

---

### File 8: Validation Functions
**Location**: `utils/validation.ts` (Updated)

```typescript
export const validateTodoTitle = (title: string): string | null => {
  if (!title) return 'Title is required';
  if (title.length < 2) return 'Title must be at least 2 characters';
  if (title.length > 100) return 'Title must be less than 100 characters';
  return null;
};

export const validateTodoDescription = (description: string): string | null => {
  if (description.length > 500) return 'Description must be less than 500 characters';
  return null;
};
```

---

### File 9: Create Todo Modal Component
**Location**: `components/todo/CreateTodoModal.tsx` (Updated)

```typescript
'use client';

import React, { useState } from 'react';
import { Modal } from '@/components/common/Modal';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';
import { validateTodoTitle, validateTodoDescription } from '@/utils/validation';

interface CreateTodoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (title: string, description: string) => Promise<void>;
  isLoading?: boolean;
}

export function CreateTodoModal({
  isOpen,
  onClose,
  onSubmit,
  isLoading = false,
}: CreateTodoModalProps) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [errors, setErrors] = useState<{ title?: string; description?: string }>({});

  const validateForm = () => {
    const newErrors: typeof errors = {};
    const titleError = validateTodoTitle(title);
    const descError = validateTodoDescription(description);

    if (titleError) newErrors.title = titleError;
    if (descError) newErrors.description = descError;

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    try {
      await onSubmit(title, description);
      setTitle('');
      setDescription('');
      setErrors({});
      onClose();
    } catch (error) {
      console.error('Error creating todo:', error);
      setErrors({ title: 'Failed to create todo. Please try again.' });
    }
  };

  const handleClose = () => {
    setTitle('');
    setDescription('');
    setErrors({});
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      title="Create New Todo"
      onClose={handleClose}
      onConfirm={handleSubmit}
      confirmText="Create"
      isConfirming={isLoading}
    >
      <div className="space-y-4">
        <Input
          label="Title *"
          placeholder="Enter todo title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          error={errors.title}
          disabled={isLoading}
        />
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Description (Optional)
          </label>
          <textarea
            placeholder="Enter todo description (optional)"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            disabled={isLoading}
            rows={3}
            maxLength={500}
            className={`w-full px-4 py-2.5 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-blue-600 focus:ring-1 focus:ring-blue-600 transition-colors ${
              errors.description ? 'border-red-500 focus:border-red-500 focus:ring-red-500' : ''
            }`}
          />
          <div className="flex items-center justify-between mt-1">
            {errors.description && (
              <p className="text-sm text-red-600">{errors.description}</p>
            )}
            <p className="text-xs text-gray-500 ml-auto">{description.length}/500</p>
          </div>
        </div>
      </div>
    </Modal>
  );
}
```

---

### File 10: Todos Page Handler
**Location**: `app/(dashboard)/dashboard/todos/page.tsx` (Updated handleCreateTodo function)

```typescript
const handleCreateTodo = async (title: string, description: string) => {
  try {
    setIsCreating(true);
    const newTodo = await todoService.createTodo({ title, description });
    // Add the new todo to the beginning of the list
    setTodos([newTodo, ...todos]);
    toast.success('Todo created successfully! ✨');
    setShowCreateModal(false);
  } catch (error: any) {
    console.error('Error creating todo:', error);
    const errorMessage = error.response?.data?.message || 'Failed to create todo';
    toast.error(errorMessage);
  } finally {
    setIsCreating(false);
  }
};
```

---

## Quick Start

### 1. Backend Setup
```bash
cd backend-todoapp

# Run migrations
php artisan migrate

# Start server
php artisan serve
```

### 2. Frontend Setup
```bash
cd todo-app

# Install/update packages
npm install

# Start dev server
npm run dev
```

### 3. Test the Feature
1. Open http://localhost:3000
2. Login with your account
3. Go to "My Todos"
4. Click "+ Create Todo"
5. Fill in title and description
6. Click "Create"
7. Watch the todo appear instantly!

---

## API Endpoints Summary

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | /api/todos | ✅ | Create todo |
| GET | /api/todos | ✅ | Get all todos |
| GET | /api/todos/{id} | ✅ | Get single todo |
| PUT | /api/todos/{id} | ✅ | Update todo |
| DELETE | /api/todos/{id} | ✅ | Delete todo |

All endpoints return JSON with `success`, `message`, and `data` fields.

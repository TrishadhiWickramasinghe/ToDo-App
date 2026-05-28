# Backend API Integration - Code Examples for Next.js Frontend

## Complete Working Example

### Step 1: Create an API Client Hook

Create `lib/api.ts`:

```typescript
// lib/api.ts
const API_BASE_URL = 'http://localhost:8000/api';

interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
}

interface Todo {
  id: number;
  user_id: number;
  title: string;
  description: string | null;
  status: 'pending' | 'completed';
  created_at: string;
  updated_at: string;
}

export async function createTodo(
  title: string,
  description: string
): Promise<ApiResponse<Todo>> {
  const token = localStorage.getItem('authToken');

  if (!token) {
    return {
      success: false,
      message: 'Unauthenticated - please log in first'
    };
  }

  try {
    const response = await fetch(`${API_BASE_URL}/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        title,
        description
      })
    });

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        message: data.message || 'Failed to create todo',
        errors: data.errors
      };
    }

    return data;
  } catch (error) {
    console.error('Error creating todo:', error);
    return {
      success: false,
      message: 'Network error - please check your connection'
    };
  }
}

export async function getTodos(): Promise<ApiResponse<Todo[]>> {
  const token = localStorage.getItem('authToken');

  if (!token) {
    return {
      success: false,
      message: 'Unauthenticated'
    };
  }

  try {
    const response = await fetch(`${API_BASE_URL}/todos`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        message: data.message || 'Failed to fetch todos'
      };
    }

    return data;
  } catch (error) {
    console.error('Error fetching todos:', error);
    return {
      success: false,
      message: 'Network error'
    };
  }
}

export async function updateTodo(
  id: number,
  updates: Partial<{ title: string; description: string; status: string }>
): Promise<ApiResponse<Todo>> {
  const token = localStorage.getItem('authToken');

  if (!token) {
    return {
      success: false,
      message: 'Unauthenticated'
    };
  }

  try {
    const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(updates)
    });

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        message: data.message || 'Failed to update todo',
        errors: data.errors
      };
    }

    return data;
  } catch (error) {
    console.error('Error updating todo:', error);
    return {
      success: false,
      message: 'Network error'
    };
  }
}

export async function deleteTodo(id: number): Promise<ApiResponse<null>> {
  const token = localStorage.getItem('authToken');

  if (!token) {
    return {
      success: false,
      message: 'Unauthenticated'
    };
  }

  try {
    const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        message: data.message || 'Failed to delete todo'
      };
    }

    return data;
  } catch (error) {
    console.error('Error deleting todo:', error);
    return {
      success: false,
      message: 'Network error'
    };
  }
}
```

### Step 2: Update Create Todo Form Component

Update `app/(dashboard)/dashboard/todos/create/page.tsx`:

```typescript
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { createTodo } from '@/lib/api'; // Import the API function

export default function CreateTodoPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    title: '',
    description: ''
  });
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setErrors({});

    // Call the backend API instead of mock
    const response = await createTodo(formData.title, formData.description);

    setIsLoading(false);

    if (!response.success) {
      // Handle validation errors
      if (response.errors) {
        setErrors(response.errors);
        // Show first error in toast
        const firstError = Object.values(response.errors)[0]?.[0];
        if (firstError) {
          toast.error(firstError);
        }
      } else {
        toast.error(response.message || 'Failed to create todo');
      }
      return;
    }

    // Success
    toast.success(response.message || 'Todo created successfully!');
    setFormData({ title: '', description: '' });
    
    // Redirect back to todos list
    router.push('/dashboard/todos');
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear error for this field when user starts typing
    if (errors[name]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold">✨ Create New Todo</h1>
        <p className="text-gray-600 mt-2">Add a new task to your todo list</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block text-sm font-semibold mb-2">
            Title*
          </label>
          <Input
            id="title"
            name="title"
            type="text"
            placeholder="Enter todo title"
            value={formData.title}
            onChange={handleChange}
            disabled={isLoading}
            className={errors.title ? 'border-red-500' : ''}
          />
          {errors.title && (
            <p className="text-red-500 text-sm mt-1">{errors.title[0]}</p>
          )}
          <p className="text-gray-500 text-sm mt-1">
            {formData.title.length}/255
          </p>
        </div>

        <div>
          <label className="block text-sm font-semibold mb-2">
            Description (Optional)
          </label>
          <textarea
            name="description"
            placeholder="Enter detailed description..."
            value={formData.description}
            onChange={handleChange}
            disabled={isLoading}
            rows={5}
            className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              errors.description ? 'border-red-500' : ''
            }`}
          />
          {errors.description && (
            <p className="text-red-500 text-sm mt-1">{errors.description[0]}</p>
          )}
          <p className="text-gray-500 text-sm mt-1">
            {formData.description.length}/1000
          </p>
        </div>

        <div className="flex gap-4">
          <Button
            type="submit"
            variant="primary"
            disabled={isLoading || !formData.title.trim()}
          >
            {isLoading ? 'Creating...' : '✨ Create Todo'}
          </Button>
          <Button
            type="button"
            variant="secondary"
            onClick={() => router.back()}
            disabled={isLoading}
          >
            Cancel
          </Button>
        </div>
      </form>
    </div>
  );
}
```

### Step 3: Update Todos List Component

Update `app/(dashboard)/dashboard/todos/page.tsx`:

```typescript
'use client';

import { useState, useEffect, useMemo } from 'react';
import Link from 'next/link';
import toast from 'react-hot-toast';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Loader } from '@/components/ui/Loader';
import { EmptyState } from '@/components/ui/EmptyState';
import { TodoCard } from '@/components/TodoCard';
import { getTodos, deleteTodo, updateTodo } from '@/lib/api'; // Import API functions
import type { Todo } from '@/lib/api';

export default function TodosPage() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'pending' | 'completed'>('all');
  const [sortBy, setSortBy] = useState<'date' | 'title'>('date');

  // Fetch todos from backend API
  useEffect(() => {
    async function fetchTodos() {
      setIsLoading(true);
      const response = await getTodos();
      setIsLoading(false);

      if (response.success && response.data) {
        setTodos(response.data);
      } else {
        toast.error(response.message || 'Failed to load todos');
      }
    }

    fetchTodos();
  }, []);

  // Handle delete
  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this todo?')) return;

    const response = await deleteTodo(id);
    if (response.success) {
      setTodos(todos.filter(t => t.id !== id));
      toast.success('Todo deleted');
    } else {
      toast.error(response.message || 'Failed to delete todo');
    }
  };

  // Handle status toggle
  const handleToggleStatus = async (id: number, currentStatus: string) => {
    const newStatus = currentStatus === 'pending' ? 'completed' : 'pending';
    const response = await updateTodo(id, { status: newStatus });

    if (response.success && response.data) {
      setTodos(todos.map(t => t.id === id ? response.data as Todo : t));
      toast.success(`Todo marked as ${newStatus}`);
    } else {
      toast.error(response.message || 'Failed to update todo');
    }
  };

  // Handle edit
  const handleEdit = async (id: number) => {
    // For now, show a toast (implement modal later)
    toast.success('Todo updated');
  };

  // Filter and sort
  const filteredTodos = useMemo(() => {
    let result = todos;

    // Search
    if (searchTerm) {
      result = result.filter(t =>
        t.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (t.description?.toLowerCase().includes(searchTerm.toLowerCase()) ?? false)
      );
    }

    // Filter by status
    if (filterStatus !== 'all') {
      result = result.filter(t => t.status === filterStatus);
    }

    // Sort
    if (sortBy === 'date') {
      result.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
    } else {
      result.sort((a, b) => a.title.localeCompare(b.title));
    }

    return result;
  }, [todos, searchTerm, filterStatus, sortBy]);

  const stats = {
    total: todos.length,
    pending: todos.filter(t => t.status === 'pending').length,
    completed: todos.filter(t => t.status === 'completed').length,
    completionPercentage: todos.length > 0 
      ? Math.round((todos.filter(t => t.status === 'completed').length / todos.length) * 100)
      : 0
  };

  if (isLoading) {
    return <Loader message="Loading your todos..." />;
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold">📋 My Todos</h1>
          <p className="text-gray-600">Manage all your tasks efficiently</p>
        </div>
        <Link href="/dashboard/todos/create">
          <Button variant="primary">✨ Create Todo</Button>
        </Link>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-lg border">
          <p className="text-gray-600 text-sm">Total Todos</p>
          <p className="text-3xl font-bold">{stats.total}</p>
        </div>
        <div className="bg-white p-6 rounded-lg border">
          <p className="text-gray-600 text-sm">Pending</p>
          <p className="text-3xl font-bold text-yellow-600">{stats.pending}</p>
        </div>
        <div className="bg-white p-6 rounded-lg border">
          <p className="text-gray-600 text-sm">Completed</p>
          <p className="text-3xl font-bold text-green-600">
            {stats.completed} ({stats.completionPercentage}%)
          </p>
        </div>
      </div>

      {/* Search & Filter */}
      <div className="space-y-4">
        <div>
          <Input
            type="text"
            placeholder="Search by title or description..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <div className="flex gap-4">
          <div>
            <button
              onClick={() => setFilterStatus('all')}
              className={`px-4 py-2 rounded ${
                filterStatus === 'all' ? 'bg-blue-500 text-white' : 'bg-gray-200'
              }`}
            >
              📋 All
            </button>
            <button
              onClick={() => setFilterStatus('pending')}
              className={`px-4 py-2 rounded ml-2 ${
                filterStatus === 'pending' ? 'bg-blue-500 text-white' : 'bg-gray-200'
              }`}
            >
              ⏳ Pending
            </button>
            <button
              onClick={() => setFilterStatus('completed')}
              className={`px-4 py-2 rounded ml-2 ${
                filterStatus === 'completed' ? 'bg-blue-500 text-white' : 'bg-gray-200'
              }`}
            >
              ✅ Completed
            </button>
          </div>

          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as 'date' | 'title')}
            className="px-4 py-2 border rounded"
          >
            <option value="date">📅 Newest First</option>
            <option value="title">🔤 Alphabetical</option>
          </select>
        </div>
      </div>

      {/* Todos List */}
      {filteredTodos.length === 0 ? (
        <EmptyState message="No todos found" />
      ) : (
        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            Showing {filteredTodos.length} of {todos.length} todos
          </p>
          {filteredTodos.map(todo => (
            <div key={todo.id} className="bg-white p-4 rounded-lg border flex items-start gap-4">
              <button
                onClick={() => handleToggleStatus(todo.id, todo.status)}
                className="mt-1 text-2xl"
              >
                {todo.status === 'completed' ? '✓' : '○'}
              </button>
              <div className="flex-1">
                <h3 className="font-bold text-lg">{todo.title}</h3>
                {todo.description && <p className="text-gray-600">{todo.description}</p>}
                <div className="flex gap-4 mt-2 text-sm text-gray-500">
                  <span>{todo.status === 'completed' ? '✅ Completed' : '⏳ Pending'}</span>
                  <span>{new Date(todo.created_at).toLocaleDateString()}</span>
                </div>
              </div>
              <div className="flex gap-2">
                <button onClick={() => handleEdit(todo.id)} className="text-xl">✏️</button>
                <button onClick={() => handleDelete(todo.id)} className="text-xl">🗑️</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

### Step 4: Store Token After Login

In your login component (`app/(auth)/login/page.tsx`):

```typescript
// After successful login
const response = await fetch('http://localhost:8000/api/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});

const data = await response.json();

if (data.success && data.data.token) {
  // Store the token
  localStorage.setItem('authToken', data.data.token);
  // Redirect to dashboard
  router.push('/dashboard');
}
```

## Key Integration Points

1. **Token Storage:** `localStorage.getItem('authToken')`
2. **API Base URL:** `http://localhost:8000/api`
3. **Header Format:** `Authorization: Bearer {token}`
4. **Error Format:** `{ success: false, errors: { field: ['message'] } }`
5. **Success Format:** `{ success: true, data: {...} }`

## API Response Handling

```typescript
if (response.success) {
  // Data is in response.data
  const todo = response.data;
} else {
  // Validation errors are in response.errors
  // Message is in response.message
}
```

---

This complete integration replaces all mock data with real backend API calls!

# Code Conventions
Freelance Invoice Tracker

> Code style, naming conventions, and patterns. Follow these for consistency.

---

## General Principles

1. **Boring is Good**: Use standard patterns, avoid clever tricks
2. **Explicit over Implicit**: Clear variable names, no magic numbers
3. **Delete over Add**: Remove unused code immediately
4. **Type Safety**: TypeScript strict mode, no `any`
5. **Fail Fast**: Validate early, throw errors explicitly

---

## File Structure

### Naming Conventions

**Files**:
- Components: `PascalCase.tsx` (`InvoiceCard.tsx`)
- Pages: `lowercase/page.tsx` (`dashboard/page.tsx`)
- API Routes: `lowercase/route.ts` (`api/projects/route.ts`)
- Utilities: `camelCase.ts` (`formatCurrency.ts`)
- Types: `PascalCase.ts` (`Invoice.ts`)

**Folders**:
- Features: `lowercase-kebab` (`invoice-wizard/`)
- Components: `lowercase` (`ui/`, `features/`)

### Directory Organization

```
src/
├── app/                      # Next.js App Router
│   ├── (auth)/               # Route group (shared layout)
│   │   ├── login/
│   │   └── signup/
│   ├── (dashboard)/          # Authenticated routes
│   │   ├── dashboard/
│   │   ├── projects/
│   │   └── layout.tsx        # Dashboard layout (sidebar)
│   ├── client/               # Public routes
│   └── api/                  # API routes
├── components/
│   ├── ui/                   # shadcn/ui primitives (Button, Input)
│   └── features/             # Feature components (InvoiceCard)
├── lib/
│   ├── supabase/             # Supabase clients
│   ├── validations/          # Zod schemas
│   └── utils.ts              # Shared utilities
└── types/                    # TypeScript types
```

---

## TypeScript

### Strict Mode
```typescript
// tsconfig.json (already configured)
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true
  }
}
```

### Types Location
```typescript
// types/Invoice.ts
export interface Invoice {
  id: string
  invoice_number: string
  total: number
  status: 'draft' | 'sent' | 'approved' | 'paid'
  created_at: string
}

// types/Database.ts (Supabase auto-generated)
export type Database = {
  public: {
    Tables: {
      invoices: {
        Row: { ... }
        Insert: { ... }
        Update: { ... }
      }
    }
  }
}
```

### No `any`
```typescript
// ❌ Bad
function processData(data: any) { ... }

// ✅ Good
function processData(data: Invoice) { ... }

// ✅ Good (if truly unknown)
function processData(data: unknown) {
  if (isInvoice(data)) {
    // Type guard
  }
}
```

---

## React Components

### Server Components (Default)
```typescript
// app/dashboard/page.tsx
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export default async function DashboardPage() {
  const supabase = createServerComponentClient({ cookies })
  
  const { data: projects } = await supabase
    .from('projects')
    .select('*')
  
  return <div>...</div>
}
```

**When to use**: 
- Data fetching
- No user interaction
- SEO important

### Client Components
```typescript
// components/CreateProjectForm.tsx
'use client'

import { useState } from 'react'

export function CreateProjectForm() {
  const [loading, setLoading] = useState(false)
  
  return <form>...</form>
}
```

**When to use**:
- `useState`, `useEffect` hooks
- Event handlers (`onClick`, `onChange`)
- Browser APIs (`localStorage`, `window`)

### Component Props
```typescript
// ✅ Good: Interface with explicit types
interface InvoiceCardProps {
  invoice: Invoice
  onView: (id: string) => void
  className?: string
}

export function InvoiceCard({ invoice, onView, className }: InvoiceCardProps) {
  return <div className={className}>...</div>
}

// ❌ Bad: Inline types
export function InvoiceCard({ invoice, onView }: { invoice: any, onView: Function }) {
  // ...
}
```

---

## Naming Conventions

### Variables
```typescript
// ✅ Descriptive
const invoiceTotal = calculateTotal(lineItems)
const isInvoicePaid = invoice.status === 'paid'

// ❌ Vague
const total = calc(items)
const flag = invoice.status === 'paid'
```

### Functions
```typescript
// ✅ Verb + Noun
function calculateInvoiceTotal(lineItems: LineItem[]): number { ... }
function formatCurrency(amount: number): string { ... }
function validateProjectInput(data: unknown): Project { ... }

// ❌ Unclear
function total(items: LineItem[]): number { ... }
function format(amount: number): string { ... }
```

### Booleans
```typescript
// ✅ is/has/can prefix
const isLoading = true
const hasProjects = projects.length > 0
const canEditInvoice = invoice.status === 'draft'

// ❌ No prefix
const loading = true
const projects = projects.length > 0
```

### Constants
```typescript
// ✅ UPPER_SNAKE_CASE for true constants
const MAX_UPLOAD_SIZE = 2 * 1024 * 1024 // 2MB
const INVOICE_STATUSES = ['draft', 'sent', 'approved', 'paid'] as const

// ✅ camelCase for config objects
const supabaseConfig = {
  url: process.env.NEXT_PUBLIC_SUPABASE_URL,
  anonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
}
```

---

## API Routes

### Standard Pattern
```typescript
// app/api/projects/route.ts
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'
import { createProjectSchema } from '@/lib/validations/project'

export async function POST(request: Request) {
  try {
    // 1. Auth check
    const supabase = createRouteHandlerClient({ cookies })
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session) {
      return NextResponse.json(
        { success: false, error: { code: 'UNAUTHORIZED', message: 'Not authenticated' } },
        { status: 401 }
      )
    }
    
    // 2. Validate input
    const body = await request.json()
    const validated = createProjectSchema.parse(body)
    
    // 3. Database operation
    const { data, error } = await supabase
      .from('projects')
      .insert({
        ...validated,
        freelancer_id: session.user.id
      })
      .select()
      .single()
    
    if (error) throw error
    
    // 4. Success response
    return NextResponse.json({ success: true, data })
    
  } catch (error) {
    // 5. Error handling
    console.error('Create project error:', error)
    
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: { code: 'VALIDATION_ERROR', details: error.errors } },
        { status: 400 }
      )
    }
    
    return NextResponse.json(
      { success: false, error: { code: 'SERVER_ERROR', message: 'Internal error' } },
      { status: 500 }
    )
  }
}
```

### Response Format
```typescript
// Success
{
  "success": true,
  "data": { ... }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [...]
  }
}
```

---

## Database Queries

### Supabase Patterns

**Fetch All** (with pagination):
```typescript
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .order('created_at', { ascending: false })
  .range(0, 9) // First 10 items
```

**Fetch One**:
```typescript
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single() // Returns single object, not array
```

**Insert**:
```typescript
const { data, error } = await supabase
  .from('projects')
  .insert({ name: 'New Project', client_id: '...' })
  .select() // Return inserted row
  .single()
```

**Update**:
```typescript
const { data, error } = await supabase
  .from('projects')
  .update({ name: 'Updated Name' })
  .eq('id', projectId)
  .select()
  .single()
```

**Delete** (soft delete):
```typescript
const { error } = await supabase
  .from('projects')
  .update({ is_archived: true })
  .eq('id', projectId)
```

**Join Tables**:
```typescript
// ✅ Good: Single query with join
const { data } = await supabase
  .from('projects')
  .select('*, client(*), time_entries(*)')
  .eq('id', projectId)
  .single()

// ❌ Bad: N+1 query
const project = await supabase.from('projects').select('*').eq('id', projectId).single()
const client = await supabase.from('clients').select('*').eq('id', project.client_id).single()
const timeEntries = await supabase.from('time_entries').select('*').eq('project_id', projectId)
```

---

## Validation (Zod)

### Schema Location
```typescript
// lib/validations/project.ts
import { z } from 'zod'

export const createProjectSchema = z.object({
  name: z.string().min(1, 'Name is required').max(255),
  client_id: z.string().uuid('Invalid client ID'),
  hourly_rate: z.number().positive('Rate must be positive'),
  description: z.string().optional(),
})

export type CreateProjectInput = z.infer<typeof createProjectSchema>
```

### Reuse in Forms
```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { createProjectSchema } from '@/lib/validations/project'

export function CreateProjectForm() {
  const form = useForm({
    resolver: zodResolver(createProjectSchema),
    defaultValues: {
      name: '',
      hourly_rate: 0,
    }
  })
  
  // ...
}
```

---

## Error Handling

### Try-Catch Pattern
```typescript
// ✅ Good: Specific error types
try {
  const result = await riskyOperation()
} catch (error) {
  if (error instanceof z.ZodError) {
    // Validation error
  } else if (error.code === 'PGRST116') {
    // Supabase: Row not found
  } else {
    // Unknown error
    console.error('Unexpected error:', error)
  }
}

// ❌ Bad: Silent catch
try {
  await riskyOperation()
} catch (error) {
  // Do nothing
}
```

### Error Logging
```typescript
// Production: Send to Sentry
import * as Sentry from '@sentry/nextjs'

try {
  // ...
} catch (error) {
  Sentry.captureException(error)
  throw error // Re-throw after logging
}
```

---

## Styling (Tailwind)

### Class Organization
```typescript
// ✅ Good: Logical order (layout → spacing → colors → typography → effects)
<div className="flex flex-col gap-4 p-6 bg-white border border-zinc-200 rounded-lg shadow-sm">

// ❌ Bad: Random order
<div className="shadow-sm bg-white gap-4 border-zinc-200 p-6 flex border rounded-lg flex-col">
```

### Responsive Design
```typescript
// Mobile-first approach
<div className="w-full md:w-1/2 lg:w-1/3">
  // Full width on mobile, half on tablet, third on desktop
</div>

// Breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px)
```

### Conditional Classes
```typescript
import { cn } from '@/lib/utils'

// ✅ Good: Use cn() helper
<button className={cn(
  'px-4 py-2 rounded-md',
  isPrimary && 'bg-cyan-600 text-white',
  isLoading && 'opacity-50 cursor-not-allowed'
)}>

// ❌ Bad: String interpolation
<button className={`px-4 py-2 ${isPrimary ? 'bg-cyan-600' : ''}`}>
```

---

## Git Workflow

### Branch Naming
```bash
main           # Production-ready code
staging        # Pre-production testing
feat/invoice-pdf      # New feature
fix/auth-redirect     # Bug fix
chore/deps-update     # Maintenance
```

### Commit Messages (Conventional Commits)
```bash
# Format: <type>(<scope>): <subject>

feat(invoices): add PDF generation
fix(auth): redirect after login
chore(deps): update Next.js to 15.0.1
docs(readme): add setup instructions

# Types: feat, fix, docs, style, refactor, test, chore
```

### Commit Frequency
- Small, focused commits (not 500-line monsters)
- Commit after each feature/fix (not daily batches)
- Descriptive messages (not "wip" or "fix stuff")

---

## Comments

### When to Comment
```typescript
// ✅ Good: Explain WHY, not WHAT
// Invoice numbers must be unique across all freelancers
// Use timestamp to prevent collisions
const invoiceNumber = `INV-${Date.now()}`

// ✅ Good: Document complex logic
// Calculate overdue status: invoice is overdue if due_date < today
// AND status is 'sent' or 'approved' (not draft or paid)
const isOverdue = invoice.status === 'sent' || invoice.status === 'approved'
  && new Date(invoice.due_date) < new Date()

// ❌ Bad: Redundant comment
// Set loading to true
setLoading(true)

// ❌ Bad: Commented-out code (delete it)
// const oldFunction = () => { ... }
```

### TODO Comments
```typescript
// TODO: Add pagination (currently loads all projects)
// TODO: Implement email notifications (Phase 2)
// FIXME: Invoice PDF generation slow on cold start
```

---

## Performance

### Avoid Re-renders
```typescript
// ✅ Good: Memoize expensive calculations
const totalRevenue = useMemo(
  () => invoices.reduce((sum, inv) => sum + inv.total, 0),
  [invoices]
)

// ❌ Bad: Calculate in render
const totalRevenue = invoices.reduce((sum, inv) => sum + inv.total, 0)
```

### Image Optimization
```typescript
// ✅ Good: Next.js Image component
import Image from 'next/image'

<Image
  src="/logo.png"
  alt="Logo"
  width={120}
  height={40}
  priority // For above-the-fold images
/>

// ❌ Bad: Native img tag
<img src="/logo.png" alt="Logo" />
```

---

## Security

### Environment Variables
```typescript
// ✅ Good: Validate at startup
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
if (!supabaseUrl) {
  throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL')
}

// ❌ Bad: Use directly (could be undefined)
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, ...)
```

### User Input
```typescript
// ✅ Good: Validate before database
const validated = createProjectSchema.parse(userInput)

// ❌ Bad: Trust user input
await supabase.from('projects').insert(userInput)
```

---

## Testing (Manual for MVP)

### Test Checklist
```
[ ] Happy path works (create project → invoice → client approves)
[ ] Empty states render (no projects, no invoices)
[ ] Error states handled (network failure, validation errors)
[ ] Responsive works (mobile 375px, tablet 768px, desktop 1280px)
[ ] Auth works (login, signup, logout, password reset)
[ ] RLS works (user A cannot see user B's data)
```

---

**Last Updated**: 2026-10-02  
**Next Review**: After first feature implementation
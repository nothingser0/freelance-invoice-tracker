# AI Agent Development Guide
Freelance Invoice Tracker

> This file guides AI coding agents (Cursor, Windsurf, Claude Code) through the development process. Read this FIRST before making changes.

---

## Project Overview

**What**: Project management + invoicing tool for freelancers. Track time, log expenses, generate professional PDF invoices, client portal for approval.

**Target Users**: 
- Freelancers (1-person businesses managing 3-10 clients)
- Clients (receive invoices via link, no account needed)

**Core Flow**: Log time/expense → Create invoice → Send to client portal → Client approves → Mark paid

---

## Tech Stack (LOCKED)

**Frontend**: Next.js 15 App Router + React 18 + TypeScript + Tailwind CSS
**Backend**: Next.js API Routes (serverless functions)
**Database**: Supabase PostgreSQL (500MB free tier)
**Auth**: Supabase Auth (JWT + Row-Level Security)
**Storage**: Supabase Storage (receipts, logos)
**PDF**: React-PDF (`@react-pdf/renderer`)
**Deploy**: Vercel Hobby (free tier, $0/month)
**Monitoring**: Sentry (error tracking)

**Why this stack**: 
- Zero cost ($0/month)
- Fast MVP delivery (2-3 weeks)
- Expertise match (JS/TS)
- Direct copy from design prototype (95% reuse)

---

## Project Structure

```
freelance-invoice-tracker/
├── src/
│   ├── app/                      # Next.js 15 App Router
│   │   ├── (auth)/               # Auth routes (login, signup)
│   │   ├── (dashboard)/          # Authenticated routes
│   │   │   ├── dashboard/
│   │   │   ├── projects/
│   │   │   ├── invoices/
│   │   │   ├── clients/
│   │   │   └── settings/
│   │   ├── client/               # Public client portal
│   │   │   └── invoice/[token]/
│   │   ├── api/                  # API routes
│   │   │   ├── projects/
│   │   │   ├── invoices/
│   │   │   ├── pdf/
│   │   │   └── client/
│   │   └── layout.tsx            # Root layout
│   ├── components/               # Shared components
│   │   ├── ui/                   # shadcn/ui primitives
│   │   └── features/             # Feature-specific components
│   ├── lib/                      # Utilities
│   │   ├── supabase/             # Supabase clients
│   │   ├── validations/          # Zod schemas
│   │   └── utils.ts              # Helpers
│   └── types/                    # TypeScript types
├── docs/                         # Design & architecture docs
│   └── specs/                    # PRD, FSD, DESIGN_SPEC
├── DESIGN.md                     # Design tokens (AI reference)
├── ARCHITECTURE.md               # System architecture
├── CONTEXT.md                    # Project context
├── CONVENTIONS.md                # Code conventions
├── TODO.md                       # Task breakdown
└── .env.local                    # Environment variables
```

---

## Critical Files to Read

**Before coding ANY feature, read these in order:**

1. **CONTEXT.md** - Why this project exists, user problems, business goals
2. **ARCHITECTURE.md** - Database schema, API contracts, auth flow
3. **DESIGN.md** - UI design tokens (colors, typography, components)
4. **CONVENTIONS.md** - Code style, naming, patterns
5. **TODO.md** - Task breakdown, current sprint

**During coding:**
- `docs/specs/PRD.md` - Feature requirements, acceptance criteria
- `docs/specs/FSD.md` - Technical implementation details
- `docs/specs/DESIGN_SPEC.md` - Screen-by-screen UI specs

---

## Development Workflow

### 1. Setup (First Time)

```bash
# Install dependencies
npm install

# Install Supabase CLI
npm install -g supabase

# Install additional dependencies
npm install @supabase/ssr @supabase/auth-helpers-nextjs
npm install react-hook-form zod @hookform/resolvers
npm install @react-pdf/renderer
npm install lucide-react
npm install date-fns

# Setup environment variables
cp .env.example .env.local
# Edit .env.local with Supabase credentials
```

### 2. Database Setup

```bash
# Link to Supabase project
supabase link --project-ref <your-project-ref>

# Push schema from FSD.md (manual for now)
# Copy SQL from docs/specs/FSD.md section 3
# Run in Supabase SQL Editor
```

### 3. Development Server

```bash
npm run dev
# Open http://localhost:3000
```

### 4. Code → Test → Commit

```bash
# Make changes
# Test manually (run dev server, click through UI)

# Type check
npm run type-check

# Lint
npm run lint

# Commit (conventional commits)
git add .
git commit -m "feat(invoices): add PDF generation"
```

---

## Coding Guidelines

### File Naming
- Components: PascalCase (`InvoiceCard.tsx`)
- Pages: lowercase (`dashboard/page.tsx`)
- Utilities: camelCase (`formatCurrency.ts`)
- Types: PascalCase (`Invoice.ts`)

### Component Structure
```typescript
// components/InvoiceCard.tsx
import { formatCurrency } from '@/lib/utils'
import { Invoice } from '@/types/Invoice'

interface InvoiceCardProps {
  invoice: Invoice
  onViewClick: (id: string) => void
}

export function InvoiceCard({ invoice, onViewClick }: InvoiceCardProps) {
  return (
    <div className="bg-white border border-zinc-200 rounded-lg p-6">
      <h3 className="text-lg font-semibold text-zinc-900">
        {invoice.invoice_number}
      </h3>
      <p className="text-zinc-600">{formatCurrency(invoice.total)}</p>
      <button onClick={() => onViewClick(invoice.id)}>View</button>
    </div>
  )
}
```

### API Route Pattern
```typescript
// app/api/projects/route.ts
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'
import { createProjectSchema } from '@/lib/validations/project'

export async function POST(request: Request) {
  try {
    const supabase = createRouteHandlerClient({ cookies })
    
    // Check auth
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    
    // Validate input
    const body = await request.json()
    const validated = createProjectSchema.parse(body)
    
    // Insert to database (RLS auto-filters by user)
    const { data, error } = await supabase
      .from('projects')
      .insert({
        ...validated,
        freelancer_id: session.user.id
      })
      .select()
      .single()
    
    if (error) throw error
    
    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('Create project error:', error)
    return NextResponse.json(
      { error: 'Failed to create project' },
      { status: 500 }
    )
  }
}
```

### Supabase Client (Server Component)
```typescript
// app/dashboard/page.tsx (Server Component)
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const supabase = createServerComponentClient({ cookies })
  
  // Check auth
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) redirect('/login')
  
  // Fetch data (RLS auto-filters)
  const { data: projects } = await supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false })
  
  return <div>...</div>
}
```

### Supabase Client (Client Component)
```typescript
// components/CreateProjectForm.tsx
'use client'

import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { useState } from 'react'

export function CreateProjectForm() {
  const supabase = createClientComponentClient()
  const [loading, setLoading] = useState(false)
  
  async function handleSubmit(formData: FormData) {
    setLoading(true)
    
    const { data, error } = await supabase
      .from('projects')
      .insert({ name: formData.get('name') })
      .select()
      .single()
    
    if (error) {
      console.error(error)
    } else {
      // Success
    }
    
    setLoading(false)
  }
  
  return <form action={handleSubmit}>...</form>
}
```

---

## Design System (from DESIGN.md)

**Colors** (Tailwind classes):
- Primary: `bg-cyan-600 text-white` (buttons, active nav)
- Background: `bg-white` (cards), `bg-zinc-50` (page)
- Text: `text-zinc-900` (headings), `text-zinc-600` (body), `text-zinc-400` (muted)
- Borders: `border-zinc-200`
- Status badges:
  - Draft: `bg-zinc-100 text-zinc-700 border-zinc-300`
  - Sent: `bg-blue-50 text-blue-700 border-blue-200`
  - Paid: `bg-emerald-50 text-emerald-700 border-emerald-200`

**Typography**:
- Font: Inter (default), JetBrains Mono (numbers)
- Headings: `text-2xl font-semibold` (h2), `text-lg font-semibold` (h3)
- Body: `text-sm` (14px base)

**Components** (shadcn/ui):
- Button: `bg-cyan-600 hover:bg-cyan-700 text-white px-4 py-2 rounded-md`
- Input: `border border-zinc-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-cyan-500`
- Card: `bg-white border border-zinc-200 rounded-lg p-6 shadow-sm`

**Install shadcn/ui components as needed**:
```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add card
npx shadcn-ui@latest add table
npx shadcn-ui@latest add dialog
```

---

## Common Tasks

### Add New Database Table
1. Read schema from `docs/specs/FSD.md` section 3
2. Create migration in Supabase SQL Editor
3. Add TypeScript types in `src/types/`
4. Test RLS policies (verify user isolation)

### Add New API Endpoint
1. Read requirements from `docs/specs/PRD.md`
2. Read API contract from `docs/specs/FSD.md` section 4
3. Create route handler in `src/app/api/`
4. Add Zod validation schema in `src/lib/validations/`
5. Test with Postman/curl

### Add New Page
1. Read screen spec from `docs/specs/DESIGN_SPEC.md`
2. Create page in `src/app/(dashboard)/`
3. Implement 5 states: default, loading, empty, error, success
4. Add to navigation in layout
5. Test responsive (375px, 768px, 1280px)

### Generate Invoice PDF
1. Read PDF structure from `docs/specs/FSD.md` section 8
2. Create `InvoicePDF.tsx` component (React-PDF)
3. API route: `/api/invoices/[id]/pdf`
4. Stream PDF response
5. Test download in browser

---

## Security Checklist

**Every feature MUST:**
- [ ] Use Supabase RLS (no direct database access)
- [ ] Validate input with Zod schemas
- [ ] Check authentication (`session` required)
- [ ] Use parameterized queries (Supabase client auto-handles)
- [ ] Sanitize user input (React auto-escapes)
- [ ] HTTPS only (Vercel enforces)

**Sensitive data:**
- [ ] Passwords: Never store (Supabase Auth handles)
- [ ] Client tokens: 32-char hex, non-guessable
- [ ] API keys: Store in `.env.local`, never commit

---

## Performance Checklist

**Every page MUST:**
- [ ] Use Server Components by default (reduce JS bundle)
- [ ] Paginate lists (10-20 items per page)
- [ ] Index database queries (foreign keys indexed)
- [ ] Optimize images (Next.js Image component)
- [ ] Lazy load heavy components (React.lazy)

**Database:**
- [ ] Avoid N+1 queries (use `.select('*, client(*)')`)
- [ ] Use `.single()` for one result (not `[0]`)
- [ ] Add indexes on filtered columns

---

## Testing Strategy

**Manual Testing** (MVP priority):
- [ ] Complete user flow: Signup → Create project → Log time → Create invoice → Send to client → Client approves → Mark paid
- [ ] Test all 5 states per page (default, loading, empty, error, success)
- [ ] Test responsive (mobile 375px, tablet 768px, desktop 1280px)
- [ ] Test edge cases (delete project with invoices = blocked, edit sent invoice = blocked)

**Automated Testing** (Phase 2):
- Unit tests: Zod schemas, utility functions
- Integration tests: API routes
- E2E tests: Playwright (critical user flows)

---

## Common Errors & Solutions

**Error: "No active session"**
- Solution: Check auth middleware, verify Supabase client setup

**Error: "Row-level security policy violation"**
- Solution: Check RLS policies, verify `freelancer_id` matches `auth.uid()`

**Error: "Module not found"**
- Solution: Check import paths use `@/` alias, restart dev server

**Error: "Hydration mismatch"**
- Solution: Don't use `Date.now()` or `Math.random()` in Server Components

**Error: "Too many re-renders"**
- Solution: Check useState dependencies, avoid setState in render

---

## Deployment Checklist

**Before deploy:**
- [ ] Type check passes: `npm run type-check`
- [ ] Lint passes: `npm run lint`
- [ ] Build succeeds: `npm run build`
- [ ] Environment variables set in Vercel
- [ ] Supabase production project created
- [ ] Database schema migrated to production

**After deploy:**
- [ ] Test production URL (smoke test)
- [ ] Check Sentry for errors
- [ ] Monitor Vercel function logs

---

## Getting Help

**Read these files in order:**
1. `CONTEXT.md` - Project goals
2. `ARCHITECTURE.md` - Technical design
3. `docs/specs/PRD.md` - Feature requirements
4. `docs/specs/FSD.md` - Implementation details

**Common questions:**
- "What's the invoice status flow?" → Read `docs/specs/FSD.md` section 6
- "How do I implement PDF?" → Read `docs/specs/FSD.md` section 8.1
- "What colors to use?" → Read `DESIGN.md` section 2
- "How does auth work?" → Read `ARCHITECTURE.md` section 3

**Still stuck?**
- Check Next.js 15 docs: https://nextjs.org/docs
- Check Supabase docs: https://supabase.com/docs
- Check React-PDF docs: https://react-pdf.org

---

**Last Updated**: 2026-10-02  
**Agent Version**: Compatible with Cursor 0.40+, Windsurf, Claude Code  
**Stack Version**: Next.js 15, Supabase 2.45+, React 18
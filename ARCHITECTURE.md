# System Architecture
Freelance Invoice Tracker

> Technical architecture reference extracted from FSD.md. Read this for database schema, API contracts, and auth flow.

---

## System Overview

**Architecture Pattern**: Monolithic Full-Stack (Next.js)
**Deployment Model**: Serverless (Vercel Edge + Supabase)
**Data Flow**: Client → Next.js API Routes → Supabase PostgreSQL

```
┌─────────────────────────────────────────────┐
│ Browser (Next.js 15 Client)                 │
│ - React Server Components (SSR)             │
│ - Client Components (interactive)           │
└──────────────────┬──────────────────────────┘
                   │ HTTPS / TLS 1.3
                   ▼
┌─────────────────────────────────────────────┐
│ Vercel Edge Network                         │
│ - CDN (static assets)                       │
│ - Serverless Functions (API routes)         │
└──────────────────┬──────────────────────────┘
                   │ Supabase Client SDK
                   ▼
┌─────────────────────────────────────────────┐
│ Supabase Backend-as-a-Service              │
│ ┌─────────────┐ ┌────────┐ ┌──────────┐   │
│ │ PostgreSQL  │ │ Auth   │ │ Storage  │   │
│ │ (Database)  │ │ (JWT)  │ │ (Files)  │   │
│ └─────────────┘ └────────┘ └──────────┘   │
└─────────────────────────────────────────────┘
```

---

## Database Schema

**Source**: `docs/specs/FSD.md` section 3

### Tables Overview

```
auth.users (Supabase managed)
    ↓
profiles (1:1) ← extends user with business info
    ↓
clients (1:N) ← freelancer owns many clients
    ↓
projects (1:N) ← client has many projects
    ↓
    ├─→ time_entries (1:N)
    ├─→ expenses (1:N)
    └─→ invoices (1:N)
```

### 1. profiles

Extends `auth.users` with business profile.

```sql
id                    UUID PRIMARY KEY (refs auth.users.id)
full_name             VARCHAR(150) NOT NULL
business_name         VARCHAR(150)
email                 VARCHAR(255) NOT NULL
phone                 VARCHAR(50)
address               TEXT
tax_id                VARCHAR(100)
avatar_url            VARCHAR(500)

-- Invoice branding
logo_url              VARCHAR(500)
invoice_primary_color VARCHAR(7) DEFAULT '#0891B2'
invoice_footer_text   TEXT

-- Settings
default_tax_rate      DECIMAL(5,2) DEFAULT 0.00
default_currency      VARCHAR(3) DEFAULT 'USD'
invoice_number_prefix VARCHAR(20) DEFAULT 'INV-'
invoice_counter       INT DEFAULT 1

created_at            TIMESTAMP WITH TIME ZONE
updated_at            TIMESTAMP WITH TIME ZONE
```

**RLS**: Users can only read/update their own profile (`auth.uid() = id`)

### 2. clients

```sql
id              UUID PRIMARY KEY
freelancer_id   UUID NOT NULL (refs auth.users, CASCADE)
name            VARCHAR(150) NOT NULL
email           VARCHAR(255) NOT NULL
phone           VARCHAR(50)
address         TEXT
business_name   VARCHAR(150)
is_archived     BOOLEAN DEFAULT FALSE
created_at      TIMESTAMP WITH TIME ZONE
updated_at      TIMESTAMP WITH TIME ZONE
```

**RLS**: `auth.uid() = freelancer_id`

**Indexes**: 
- `idx_clients_freelancer` on `freelancer_id`
- `idx_clients_name` on `(freelancer_id, name)`

### 3. projects

```sql
id            UUID PRIMARY KEY
freelancer_id UUID NOT NULL (refs auth.users, CASCADE)
client_id     UUID NOT NULL (refs clients, RESTRICT)
name          VARCHAR(255) NOT NULL
description   TEXT
hourly_rate   DECIMAL(12,2) NOT NULL CHECK (hourly_rate >= 0)
status        VARCHAR(30) DEFAULT 'active' 
              CHECK (status IN ('active', 'completed', 'archived'))
created_at    TIMESTAMP WITH TIME ZONE
updated_at    TIMESTAMP WITH TIME ZONE
```

**RLS**: `auth.uid() = freelancer_id`

**Business Logic**:
- Cannot delete project if client has invoices (RESTRICT)
- Status: active (working), completed (done), archived (soft-delete)

### 4. time_entries

```sql
id            UUID PRIMARY KEY
freelancer_id UUID NOT NULL (refs auth.users, CASCADE)
project_id    UUID NOT NULL (refs projects, CASCADE)
date          DATE NOT NULL
hours         DECIMAL(6,2) NOT NULL CHECK (hours > 0)
description   TEXT NOT NULL
amount        DECIMAL(12,2) NOT NULL (calculated: hours × project.hourly_rate)
is_invoiced   BOOLEAN DEFAULT FALSE
invoice_id    UUID (refs invoices, SET NULL)
created_at    TIMESTAMP WITH TIME ZONE
updated_at    TIMESTAMP WITH TIME ZONE
```

**RLS**: `auth.uid() = freelancer_id`

**Business Logic**:
- `is_invoiced = true` → cannot edit (linked to invoice)
- `amount` auto-calculated on insert
- Date cannot be in future

### 5. expenses

```sql
id            UUID PRIMARY KEY
freelancer_id UUID NOT NULL (refs auth.users, CASCADE)
project_id    UUID NOT NULL (refs projects, CASCADE)
date          DATE NOT NULL
description   TEXT NOT NULL
amount        DECIMAL(12,2) NOT NULL CHECK (amount > 0)
receipt_url   VARCHAR(500) (Supabase Storage path)
is_invoiced   BOOLEAN DEFAULT FALSE
invoice_id    UUID (refs invoices, SET NULL)
created_at    TIMESTAMP WITH TIME ZONE
updated_at    TIMESTAMP WITH TIME ZONE
```

**RLS**: `auth.uid() = freelancer_id`

**Business Logic**:
- `receipt_url` stored in Supabase Storage bucket: `receipts`
- `is_invoiced = true` → cannot edit

### 6. invoices

```sql
id                  UUID PRIMARY KEY
freelancer_id       UUID NOT NULL (refs auth.users, CASCADE)
client_id           UUID NOT NULL (refs clients, RESTRICT)
project_id          UUID NOT NULL (refs projects, RESTRICT)
invoice_number      VARCHAR(50) UNIQUE NOT NULL
invoice_date        DATE NOT NULL DEFAULT CURRENT_DATE
due_date            DATE NOT NULL
line_items          JSONB NOT NULL
subtotal            DECIMAL(12,2) NOT NULL
tax_rate            DECIMAL(5,2) DEFAULT 0.00
tax_amount          DECIMAL(12,2) DEFAULT 0.00
discount            DECIMAL(12,2) DEFAULT 0.00
total               DECIMAL(12,2) NOT NULL
notes               TEXT
status              VARCHAR(30) DEFAULT 'draft'
                    CHECK (status IN ('draft', 'sent', 'approved', 'paid', 'overdue'))
client_token        VARCHAR(64) UNIQUE (32-char hex for client access)
client_token_revoked BOOLEAN DEFAULT FALSE
approved_at         TIMESTAMP WITH TIME ZONE
paid_at             TIMESTAMP WITH TIME ZONE
created_at          TIMESTAMP WITH TIME ZONE
updated_at          TIMESTAMP WITH TIME ZONE
```

**RLS**: `auth.uid() = freelancer_id` (client access via service role + token validation)

**Indexes**:
- `idx_invoices_freelancer` on `freelancer_id`
- `idx_invoices_status` on `(freelancer_id, status)`
- `idx_invoices_token` on `client_token`

**Business Logic**:
- `invoice_number` format: `{prefix}-{counter}` (e.g., `INV-2024-001`)
- `line_items` JSONB structure:
  ```json
  [
    {
      "description": "Time entry: Homepage design (8 hrs)",
      "quantity": 8,
      "rate": 250000,
      "amount": 2000000
    }
  ]
  ```
- Status flow: draft → sent → approved → paid
- `overdue` computed: `due_date < today AND status IN ('sent', 'approved')`

---

## Authentication & Authorization

### Supabase Auth Flow

```
1. User signs up → Supabase creates auth.users record
2. Trigger creates profiles record (1:1 with auth.users)
3. User logs in → Supabase issues JWT token
4. Token stored in HttpOnly cookie (Supabase client auto-handles)
5. Every request validates JWT → extracts user.id
6. RLS policies filter database by user.id
```

### Row-Level Security (RLS)

**Concept**: Database-level access control. Every query auto-filtered by `auth.uid()`.

**Example**:
```sql
-- User A (id: abc-123) queries projects
SELECT * FROM projects;

-- RLS policy auto-adds WHERE clause:
SELECT * FROM projects WHERE freelancer_id = 'abc-123';

-- User A cannot see User B's projects (database enforces)
```

**Policy Pattern** (all tables):
```sql
CREATE POLICY "Users can manage own data"
    ON table_name FOR ALL
    USING (auth.uid() = freelancer_id);
```

### Client Portal Access

**Challenge**: Clients have no account, but need invoice access.

**Solution**: Token-based authentication
1. Freelancer sends invoice → generates `client_token` (32-char hex)
2. Client accesses `/client/invoice/{token}` (public route)
3. API validates token:
   ```typescript
   const { data } = await supabase
     .from('invoices')
     .select('*')
     .eq('client_token', token)
     .eq('client_token_revoked', false)
     .single()
   ```
4. If valid → show invoice (bypass RLS using service role key)

**Security**:
- Token: 128-bit entropy (cryptographically secure)
- No expiration (manual revoke via `client_token_revoked = true`)
- Rate limiting: 100 requests/hour per IP (Vercel Edge)

---

## API Routes

**Source**: `docs/specs/FSD.md` section 4

### Authentication
- Managed by Supabase (no custom routes)
- `/auth/v1/signup` - Create account
- `/auth/v1/token` - Login
- `/auth/v1/recover` - Password reset

### Projects
- `GET /api/projects` - List all projects (paginated)
- `POST /api/projects` - Create project
- `GET /api/projects/:id` - Get project details
- `PUT /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Archive project

### Time Entries
- `POST /api/time-entries` - Log time
- `PUT /api/time-entries/:id` - Edit time entry
- `DELETE /api/time-entries/:id` - Delete time entry

### Expenses
- `POST /api/expenses` - Log expense
- `PUT /api/expenses/:id` - Edit expense
- `DELETE /api/expenses/:id` - Delete expense

### Invoices
- `GET /api/invoices` - List invoices (filtered by status)
- `POST /api/invoices` - Create invoice
- `PUT /api/invoices/:id` - Update draft invoice
- `POST /api/invoices/:id/send` - Generate client token, mark sent
- `POST /api/invoices/:id/paid` - Mark paid
- `GET /api/invoices/:id/pdf` - Generate PDF download

### Client Portal
- `GET /api/client/invoice/:token` - Get invoice by token
- `POST /api/client/invoice/:token/approve` - Client approves

### Standard Response Format

**Success (200)**:
```json
{
  "success": true,
  "data": { ... }
}
```

**Error (4xx/5xx)**:
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "hourly_rate", "message": "Must be positive" }
    ]
  }
}
```

---

## Data Validation

**All inputs validated with Zod schemas before database insert.**

### Example: Create Project

```typescript
// lib/validations/project.ts
import { z } from 'zod'

export const createProjectSchema = z.object({
  name: z.string().min(1, 'Name is required').max(255),
  client_id: z.string().uuid('Invalid client ID'),
  hourly_rate: z.number().positive('Rate must be positive'),
  description: z.string().optional(),
})

// API route
const validated = createProjectSchema.parse(body)
// Throws ZodError if validation fails (auto-caught by try/catch)
```

**Validation schemas location**: `src/lib/validations/`

---

## File Storage

**Supabase Storage Buckets**:

1. **receipts** (private)
   - Path: `receipts/{freelancer_id}/{expense_id}/{filename}`
   - Access: Authenticated freelancers only
   - Max size: 2MB per file
   - Allowed types: PNG, JPG, PDF

2. **logos** (private)
   - Path: `logos/{freelancer_id}/{filename}`
   - Access: Authenticated freelancers only
   - Max size: 500KB
   - Allowed types: PNG, SVG

3. **avatars** (private)
   - Path: `avatars/{freelancer_id}/{filename}`
   - Max size: 2MB
   - Allowed types: PNG, JPG

**Upload Pattern**:
```typescript
const file = formData.get('receipt') as File

const filePath = `receipts/${session.user.id}/${crypto.randomUUID()}-${file.name}`

const { data, error } = await supabase.storage
  .from('receipts')
  .upload(filePath, file)

// Store data.path in database (expenses.receipt_url)
```

**Download Pattern**:
```typescript
const { data } = await supabase.storage
  .from('receipts')
  .createSignedUrl(expense.receipt_url, 60) // 60s expiry

// Return data.signedUrl to client (temporary access)
```

---

## PDF Generation

**Library**: React-PDF (`@react-pdf/renderer`)

**Strategy**: Server-side rendering in API route

```typescript
// app/api/invoices/[id]/pdf/route.ts
import ReactPDF from '@react-pdf/renderer'
import { InvoicePDF } from '@/components/InvoicePDF'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  // Fetch invoice data
  const invoice = await getInvoice(params.id)
  
  // Render PDF
  const stream = await ReactPDF.renderToStream(
    <InvoicePDF invoice={invoice} />
  )
  
  return new Response(stream as any, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="Invoice-${invoice.invoice_number}.pdf"`
    }
  })
}
```

**Invoice Template**: `src/components/InvoicePDF.tsx` (React-PDF components)

---

## Performance Considerations

### Database
- **Indexes**: All foreign keys indexed automatically
- **Pagination**: Use `.range(start, end)` for lists
- **N+1 Prevention**: Use `.select('*, client(*)')` to join tables
- **Connection Pooling**: Supabase handles (50 max connections free tier)

### Caching
- **Static Pages**: Next.js ISR (revalidate landing page every 1 hour)
- **API Routes**: No caching (always fresh data)
- **Images**: Next.js Image component (auto-optimization)

### Bundle Size
- **React Server Components**: Render on server (0 JS to client)
- **Code Splitting**: Next.js auto-splits routes
- **Tree Shaking**: Unused code removed automatically

---

## Security Measures

### Input Validation
- ✅ Zod schemas (all API routes)
- ✅ Type checking (TypeScript strict mode)
- ✅ Supabase client (parameterized queries, no SQL injection)

### Authentication
- ✅ JWT tokens (Supabase Auth, HttpOnly cookies)
- ✅ RLS policies (database-level isolation)
- ✅ Session expiry (7 days, auto-refresh)

### Data Encryption
- ✅ In transit: HTTPS/TLS 1.3 (Vercel enforces)
- ✅ At rest: AES-256 (Supabase managed)
- ✅ Passwords: bcrypt (Supabase Auth)

### OWASP Top 10
- A01 Broken Access Control: RLS policies
- A02 Cryptographic Failures: HTTPS + AES-256
- A03 Injection: Parameterized queries
- A07 Auth Failures: JWT + bcrypt
- A08 Data Integrity: Zod validation + DB constraints

---

## Environment Variables

**Required in `.env.local`**:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi... # Server-only

# App Config
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Sentry (optional)
NEXT_PUBLIC_SENTRY_DSN=https://xxx@sentry.io/xxx
```

**Production (Vercel)**:
- Same keys, different Supabase project (prod vs staging)
- Add keys in Vercel dashboard → Settings → Environment Variables

---

## Deployment Topology

```
Developer Push (main branch)
    ↓
Vercel CI/CD (auto-build)
    ↓
Deploy to Edge Network (global)
    ↓
Supabase PostgreSQL (us-west-1)
```

**Environments**:
- **Local**: `localhost:3000` → Supabase dev project
- **Staging**: `staging.vercel.app` → Supabase staging project
- **Production**: `your-domain.vercel.app` → Supabase prod project

---

## Monitoring

**Error Tracking** (Sentry):
- Frontend errors: Auto-captured
- API errors: Manual `Sentry.captureException()`
- Alert threshold: >10 errors/hour

**Performance** (Vercel Analytics):
- Core Web Vitals (LCP, FCP, CLS)
- API response times
- Function invocations

**Database** (Supabase):
- Connection pool usage
- Slow queries (>500ms)
- Disk usage (500MB limit free tier)

---

**Reference Docs**:
- Full schema: `docs/specs/FSD.md` section 3
- API contracts: `docs/specs/FSD.md` section 4
- Security: `docs/specs/FSD.md` section 5

**Last Updated**: 2026-10-02
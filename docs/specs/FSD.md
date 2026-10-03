# Functional Specification Document (FSD)
Freelance Invoice Tracker

> Technical architecture specification document defining "HOW" the system is built: database schemas, API contracts, security models, and deployment topology.

---

## 1. Document Metadata
- **System Name**: Freelance Invoice Tracker
- **Client**: Portfolio MVP (Solo Developer)
- **Lead Software Architect**: [Your Name]
- **PRD Reference**: PRD.md v1.0 (Approved)
- **Design Reference**: DESIGN_SPEC.md v1.0 (Frozen)
- **Tech Stack**: Next.js 15 + Supabase + Vercel (Option A - Locked)
- **Document Version**: 1.0.0
- **Document Status**: DRAFT - Pending Approval
- **Approval Date**: 2026-10-02 (tentative)

---

## 2. Component Architecture & Tech Stack

```text
┌─────────────────────────────────────────────────────────────┐
│ Browser / Mobile Client (Next.js 15 App Router + React 18) │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS / TLS 1.3
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Vercel Edge Network (CDN + Auto-SSL + DDoS Protection)     │
└──────────────────────┬──────────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│ Next.js Pages    │      │ Next.js API      │
│ (Server Comp)    │      │ Routes           │
│ - Dashboard      │      │ - /api/projects  │
│ - Projects       │      │ - /api/invoices  │
│ - Invoices       │      │ - /api/pdf       │
└────────┬─────────┘      └────────┬─────────┘
         │                         │
         └──────────┬──────────────┘
                    │ Supabase Client SDK
                    ▼
┌─────────────────────────────────────────────────────────────┐
│ Supabase (Managed Backend-as-a-Service)                    │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│ │ PostgreSQL  │ │ Auth        │ │ Storage     │          │
│ │ (Database)  │ │ (JWT + RLS) │ │ (Receipts)  │          │
│ └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ External Services    │
         │ - Sentry (Errors)    │
         │ - React-PDF (Gen)    │
         └──────────────────────┘
```

### Technology Decisions (Tech Stack Matrix)

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| **Frontend** | Next.js App Router | 15.0+ | SSR for landing page, React Server Components, API routes in one framework |
| | React | 18.0+ | Component-based UI, huge ecosystem (shadcn/ui) |
| | TypeScript | 5.0+ | Type safety, catch errors at compile time |
| | Tailwind CSS | 3.4+ | Utility-first, matches DESIGN.md tokens |
| | shadcn/ui | Latest | Accessible components (Radix UI primitives) |
| **Backend** | Next.js API Routes | 15.0+ | Serverless functions, same codebase as frontend |
| | Supabase Client | 2.45+ | PostgreSQL client, Auth helpers, Storage SDK |
| **Database** | PostgreSQL | 15+ | ACID, foreign keys, robust for invoicing data |
| | Supabase | Managed | Free tier (500MB), auto-backups, RLS built-in |
| **Auth** | Supabase Auth | Built-in | Email/password, JWT tokens, HttpOnly cookies |
| **Storage** | Supabase Storage | Built-in | 1GB free, receipt uploads, logo storage |
| **PDF Generation** | React-PDF | 3.4+ | Pure JS, fast cold start (<200ms), React components |
| | (Fallback) Puppeteer | 22.0+ | HTML→PDF if React-PDF insufficient |
| **Forms** | React Hook Form | 7.50+ | Performance, less re-renders |
| | Zod | 3.22+ | Schema validation, TypeScript inference |
| **Deployment** | Vercel | Hobby (free) | Zero-config, git push auto-deploy |
| **Monitoring** | Sentry | Free tier | Error tracking, 5K events/month |

---

## 3. Database Schema (PostgreSQL DDL)

### 3.1 Supabase Setup

```sql
-- Enable UUID extension (Supabase default, verify enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row-Level Security on all tables (MANDATORY)
-- RLS filters data by authenticated user
```

### 3.2 Schema Design

```sql
-- ============================================
-- TABLE: profiles (extends Supabase auth.users)
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    business_name VARCHAR(150),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    tax_id VARCHAR(100),
    avatar_url VARCHAR(500),
    
    -- Invoice branding settings
    logo_url VARCHAR(500),
    invoice_primary_color VARCHAR(7) DEFAULT '#0891B2', -- Cyan-600
    invoice_footer_text TEXT DEFAULT 'Thank you for your business!',
    
    -- Default settings
    default_tax_rate DECIMAL(5,2) DEFAULT 0.00, -- Percentage (e.g., 11.00 = 11%)
    default_currency VARCHAR(3) DEFAULT 'USD', -- ISO 4217 (USD, IDR, EUR)
    invoice_number_prefix VARCHAR(20) DEFAULT 'INV-',
    invoice_counter INT DEFAULT 1, -- Auto-increment for invoice numbers
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- RLS Policy: Users can only read/update their own profile
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);


-- ============================================
-- TABLE: clients
-- ============================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    business_name VARCHAR(150),
    
    is_archived BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_freelancer ON clients(freelancer_id);
CREATE INDEX idx_clients_name ON clients(freelancer_id, name);

-- RLS Policy: Freelancers can only access their own clients
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own clients"
    ON clients FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: projects
-- ============================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    hourly_rate DECIMAL(12,2) NOT NULL CHECK (hourly_rate >= 0), -- Supports decimals (e.g., 250000.50)
    
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_freelancer ON projects(freelancer_id);
CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(freelancer_id, status);

-- RLS Policy
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own projects"
    ON projects FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: time_entries
-- ============================================
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    hours DECIMAL(6,2) NOT NULL CHECK (hours > 0), -- Supports decimals (e.g., 2.5 hrs)
    description TEXT NOT NULL,
    
    amount DECIMAL(12,2) NOT NULL, -- Calculated: hours * project.hourly_rate
    
    is_invoiced BOOLEAN DEFAULT FALSE, -- Prevent editing after invoiced
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_time_entries_freelancer ON time_entries(freelancer_id);
CREATE INDEX idx_time_entries_project ON time_entries(project_id);
CREATE INDEX idx_time_entries_date ON time_entries(project_id, date);
CREATE INDEX idx_time_entries_invoiced ON time_entries(freelancer_id, is_invoiced);

-- RLS Policy
ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own time entries"
    ON time_entries FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: expenses
-- ============================================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    
    receipt_url VARCHAR(500), -- Supabase Storage path
    
    is_invoiced BOOLEAN DEFAULT FALSE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expenses_freelancer ON expenses(freelancer_id);
CREATE INDEX idx_expenses_project ON expenses(project_id);
CREATE INDEX idx_expenses_invoiced ON expenses(freelancer_id, is_invoiced);

-- RLS Policy
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own expenses"
    ON expenses FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: invoices
-- ============================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- Format: INV-2024-001
    
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    
    -- Line items stored as JSONB for flexibility
    -- Structure: [{"description": "...", "quantity": 8, "rate": 250000, "amount": 2000000}]
    line_items JSONB NOT NULL,
    
    subtotal DECIMAL(12,2) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00, -- Percentage
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL,
    
    notes TEXT, -- Payment terms, bank details
    
    status VARCHAR(30) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'approved', 'paid', 'overdue')),
    
    -- Client portal access
    client_token VARCHAR(64) UNIQUE, -- Secure random token for client access (32-char hex)
    client_token_revoked BOOLEAN DEFAULT FALSE,
    
    approved_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_freelancer ON invoices(freelancer_id);
CREATE INDEX idx_invoices_client ON invoices(client_id);
CREATE INDEX idx_invoices_status ON invoices(freelancer_id, status);
CREATE INDEX idx_invoices_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_token ON invoices(client_token); -- For client portal lookup

-- RLS Policy: Freelancers access own invoices, Clients access via token (separate query)
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own invoices"
    ON invoices FOR ALL
    USING (auth.uid() = freelancer_id);

-- Note: Client portal access bypasses RLS (uses service role key + token validation)


-- ============================================
-- TRIGGERS: Auto-update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_entries_updated_at BEFORE UPDATE ON time_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 3.3 Data Relationships

```text
auth.users (Supabase Auth)
    │
    ├──► profiles (1:1, extends user with business info)
    │
    ├──► clients (1:N, freelancer owns many clients)
    │       │
    │       └──► projects (1:N, client has many projects)
    │               │
    │               ├──► time_entries (1:N, project has many time logs)
    │               ├──► expenses (1:N, project has many expenses)
    │               └──► invoices (1:N, project has many invoices)
    │
    └──► invoices (1:N, freelancer creates many invoices)
```

---

## 4. API Contracts & Endpoint Matrix

### 4.1 Authentication Endpoints (Supabase Auth)

**Managed by Supabase** (no custom API routes needed):
- `POST /auth/v1/signup` - Create account
- `POST /auth/v1/token?grant_type=password` - Login
- `POST /auth/v1/recover` - Request password reset
- `POST /auth/v1/token?grant_type=refresh_token` - Refresh session

### 4.2 Custom API Routes (Next.js)

All routes under `/api/` prefix. Authentication via Supabase JWT (extracted from cookie).

---

#### **POST /api/projects**
Create new project.

**Authentication**: Required (Supabase JWT)

**Request Body**:
```json
{
  "name": "Website Redesign",
  "client_id": "8c4e6123-5e92-4f31-893c-623ab1e4811a",
  "hourly_rate": 250000.00,
  "description": "Homepage mockup + 3 internal pages"
}
```

**Success Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-...",
    "name": "Website Redesign",
    "client_id": "8c4e6123-...",
    "hourly_rate": 250000.00,
    "status": "active",
    "created_at": "2026-10-02T10:00:00Z"
  }
}
```

**Error Responses**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `VALIDATION_ERROR` | Missing required fields, invalid hourly_rate |
| 401 | `UNAUTHORIZED` | No auth token or expired |
| 404 | `CLIENT_NOT_FOUND` | client_id doesn't exist or not owned by user |

---

#### **POST /api/time-entries**
Log time entry for a project.

**Request Body**:
```json
{
  "project_id": "a1b2c3d4-...",
  "date": "2026-10-01",
  "hours": 8.5,
  "description": "Homepage mockup design"
}
```

**Success Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "id": "e5f6g7h8-...",
    "project_id": "a1b2c3d4-...",
    "date": "2026-10-01",
    "hours": 8.5,
    "amount": 2125000.00,
    "description": "Homepage mockup design",
    "is_invoiced": false
  }
}
```

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `INVALID_DATE` | Date in future |
| 400 | `INVALID_HOURS` | Hours ≤ 0 or > 24 |
| 404 | `PROJECT_NOT_FOUND` | project_id invalid |

---

#### **POST /api/invoices**
Create invoice (Step 4 of wizard, after preview).

**Request Body**:
```json
{
  "project_id": "a1b2c3d4-...",
  "client_id": "8c4e6123-...",
  "line_items": [
    {
      "description": "Time entry: Homepage design (8 hrs)",
      "quantity": 8,
      "rate": 250000,
      "amount": 2000000
    },
    {
      "description": "Expense: Stock photos",
      "quantity": 1,
      "rate": 300000,
      "amount": 300000
    }
  ],
  "subtotal": 2300000,
  "tax_rate": 11.00,
  "tax_amount": 253000,
  "discount": 0,
  "total": 2553000,
  "due_date": "2026-10-16",
  "notes": "Payment due within 14 days. Bank: BCA 1234567890"
}
```

**Success Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "id": "i9j0k1l2-...",
    "invoice_number": "INV-2024-015",
    "status": "draft",
    "total": 2553000,
    "created_at": "2026-10-02T10:00:00Z"
  }
}
```

**Business Logic**:
1. Generate invoice_number: `profiles.invoice_number_prefix` + zero-padded counter
2. Increment `profiles.invoice_counter`
3. Mark time_entries/expenses as `is_invoiced = true`
4. Insert invoice record

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `NO_LINE_ITEMS` | line_items array empty |
| 400 | `CALCULATION_MISMATCH` | Subtotal/tax/total doesn't match line items |
| 404 | `PROJECT_NOT_FOUND` | project_id invalid |

---

#### **POST /api/invoices/:id/send**
Generate client portal token and mark invoice as sent.

**Request**: No body

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "client_token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "client_url": "https://app.vercel.app/client/invoice/a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "status": "sent"
  }
}
```

**Business Logic**:
1. Generate 32-char random hex token (`crypto.randomBytes(16).toString('hex')`)
2. Update invoice: `client_token = token`, `status = 'sent'`
3. Return token + full URL

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `ALREADY_SENT` | Invoice status already 'sent' |
| 403 | `CANNOT_SEND_DRAFT` | Must be draft to send |

---

#### **GET /api/client/invoice/:token**
Client views invoice (public endpoint, no auth).

**Authentication**: None (token validates access)

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "invoice_number": "INV-2024-015",
    "invoice_date": "2026-10-02",
    "due_date": "2026-10-16",
    "status": "sent",
    "freelancer": {
      "business_name": "Your Business Name",
      "logo_url": "https://...",
      "address": "123 Street, City",
      "email": "your@email.com"
    },
    "client": {
      "name": "PT ABC",
      "email": "client@abc.com",
      "address": "Client address"
    },
    "line_items": [...],
    "subtotal": 2300000,
    "tax_rate": 11.00,
    "tax_amount": 253000,
    "total": 2553000,
    "notes": "Payment terms..."
  }
}
```

**Business Logic**:
1. Query invoice by `client_token` (bypass RLS, use service role key)
2. Check `client_token_revoked = false`
3. Join with profiles (freelancer info) + clients (client info)

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 404 | `INVALID_TOKEN` | Token not found or revoked |

---

#### **POST /api/client/invoice/:token/approve**
Client approves invoice.

**Request**: No body

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "status": "approved",
    "approved_at": "2026-10-02T11:00:00Z"
  }
}
```

**Business Logic**:
1. Validate token (same as GET)
2. Update invoice: `status = 'approved'`, `approved_at = NOW()`

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `ALREADY_APPROVED` | Status already 'approved' or 'paid' |
| 404 | `INVALID_TOKEN` | Token not found/revoked |

---

#### **POST /api/invoices/:id/paid**
Freelancer marks invoice as paid.

**Request**: No body

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "status": "paid",
    "paid_at": "2026-10-02T12:00:00Z"
  }
}
```

**Business Logic**:
1. Update invoice: `status = 'paid'`, `paid_at = NOW()`

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 400 | `ALREADY_PAID` | Status already 'paid' |
| 403 | `CANNOT_MARK_DRAFT` | Must be 'sent' or 'approved' to mark paid |

---

#### **GET /api/invoices/:id/pdf**
Generate invoice PDF (server-side).

**Authentication**: Required (freelancer) OR valid client token (client access)

**Success Response (200 OK)**:
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="Invoice-INV-2024-015.pdf"

[PDF binary stream]
```

**PDF Generation Strategy**:
1. **React-PDF** (recommended):
   - Define invoice template as React component (`InvoiceDocument.tsx`)
   - Use `@react-pdf/renderer` primitives (`Document`, `Page`, `View`, `Text`)
   - Render server-side: `ReactPDF.renderToStream()`
   - Stream to response

2. **Puppeteer** (fallback if React-PDF insufficient):
   - Render HTML invoice template (same layout as DESIGN_SPEC)
   - Use Puppeteer `page.pdf()` to convert HTML → PDF
   - Trade-off: 300MB bundle size, 2-3s cold start

**Errors**:
| Code | Error | Condition |
|------|-------|-----------|
| 404 | `INVOICE_NOT_FOUND` | Invalid invoice_id |
| 500 | `PDF_GENERATION_FAILED` | React-PDF rendering error |

---

### 4.3 Error Response Format (Standardized)

All API errors return consistent JSON:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "hourly_rate",
        "message": "Must be a positive number"
      }
    ]
  }
}
```

---

## 5. Security & Cryptographic Architecture

### 5.1 Authentication & Authorization

**Supabase Auth**:
- Email/password authentication (bcrypt hashing, managed by Supabase)
- JWT tokens stored in HttpOnly cookies (Supabase client auto-handles)
- Session expiry: 7 days (configurable via Supabase dashboard)
- Refresh tokens: Auto-refreshed by Supabase client

**Row-Level Security (RLS)**:
- All tables enforce RLS policies (see section 3.2)
- Freelancer can only access own data (`auth.uid() = freelancer_id`)
- Client portal bypasses RLS (uses service role key + token validation)

**API Route Protection**:
```typescript
// middleware.ts (Next.js middleware)
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  
  // Check auth for protected routes
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session && req.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', req.url))
  }
  
  return res
}
```

### 5.2 Client Portal Token Security

**Token Generation**:
```typescript
import crypto from 'crypto'

// Generate 32-char hex token (16 bytes = 128 bits entropy)
const clientToken = crypto.randomBytes(16).toString('hex')
// Example: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
```

**Token Properties**:
- Length: 32 characters (hex)
- Entropy: 128 bits (cryptographically secure)
- No expiration (manual revoke via `client_token_revoked = true`)
- Non-guessable (infeasible to brute force)

**Revoke Mechanism**:
```sql
-- Revoke token (prevent further access)
UPDATE invoices
SET client_token_revoked = true
WHERE id = :invoice_id AND freelancer_id = :freelancer_id;
```

### 5.3 Data Encryption

**In Transit**:
- HTTPS enforced (Vercel auto-SSL, TLS 1.3)
- No plain HTTP allowed

**At Rest**:
- Supabase encrypts database (AES-256, managed)
- Supabase Storage encrypts files (AES-256, managed)
- No manual encryption needed (Supabase handles)

**Sensitive Data**:
- Passwords: bcrypt (Supabase Auth)
- JWT tokens: HttpOnly cookies (XSS protection)
- Client tokens: Plain text in DB (32-char hex, non-sensitive)

### 5.4 Input Validation (Zod Schemas)

All forms validated with Zod before API calls:

```typescript
import { z } from 'zod'

// Project creation schema
export const createProjectSchema = z.object({
  name: z.string().min(1, 'Name is required').max(255),
  client_id: z.string().uuid('Invalid client ID'),
  hourly_rate: z.number().positive('Rate must be positive'),
  description: z.string().optional(),
})

// Time entry schema
export const createTimeEntrySchema = z.object({
  project_id: z.string().uuid(),
  date: z.date().max(new Date(), 'Date cannot be in future'),
  hours: z.number().positive().max(24, 'Hours cannot exceed 24'),
  description: z.string().min(1, 'Description is required'),
})
```

### 5.5 Rate Limiting

**Supabase Auth**:
- 5 failed login attempts per 15 minutes (built-in)

**Custom API Routes** (future enhancement):
- Use Vercel Edge Config or Upstash Redis for rate limiting
- MVP: No custom rate limiting (Vercel DDoS protection sufficient for <100 users)

### 5.6 OWASP Top 10 Protection

| Vulnerability | Mitigation |
|---------------|------------|
| **A01: Broken Access Control** | RLS policies enforce user isolation |
| **A02: Cryptographic Failures** | HTTPS enforced, Supabase encrypts at rest |
| **A03: Injection** | Supabase client uses parameterized queries |
| **A04: Insecure Design** | Token-based client access (no password sharing) |
| **A05: Security Misconfiguration** | Vercel/Supabase defaults secure, no custom server config |
| **A06: Vulnerable Components** | Dependabot auto-updates, npm audit pre-deploy |
| **A07: Auth Failures** | Supabase Auth (bcrypt, JWT, session management) |
| **A08: Data Integrity Failures** | Zod validation, database constraints (CHECK) |
| **A09: Logging Failures** | Sentry error tracking, Vercel logs |
| **A10: SSRF** | No external API calls from user input |

---

## 6. Invoice Status State Machine

```text
┌─────────────────────────────────────────────────────────────┐
│                         INVOICE LIFECYCLE                    │
└─────────────────────────────────────────────────────────────┘

        ┌──────────┐
        │  DRAFT   │ ← Initial state (editable, can delete)
        └─────┬────┘
              │ (Send to client)
              ▼
        ┌──────────┐
        │   SENT   │ ← Client link generated (read-only, can revoke)
        └─────┬────┘
              │ (Client clicks "Approve")
              ▼
        ┌──────────┐
        │ APPROVED │ ← Client reviewed, awaiting payment
        └─────┬────┘
              │ (Freelancer marks paid)
              ▼
        ┌──────────┐
        │   PAID   │ ← Final state (locked, record revenue)
        └──────────┘

        ┌──────────┐
        │ OVERDUE  │ ← Computed state (due_date < today AND status IN ['sent', 'approved'])
        └──────────┘
```

### State Transition Rules

| From State | To State | Trigger | Validation |
|------------|----------|---------|------------|
| `draft` | `sent` | POST /api/invoices/:id/send | Must have line_items |
| `sent` | `approved` | POST /api/client/invoice/:token/approve | Valid token |
| `sent` or `approved` | `paid` | POST /api/invoices/:id/paid | Freelancer action only |
| `draft` | (deleted) | DELETE /api/invoices/:id | Only drafts can be deleted |

**Immutable States**:
- `paid`: Cannot revert to unpaid (prevent accidental changes)
- `sent`, `approved`: Cannot edit line items (read-only)

**Overdue Status** (computed, not stored):
```typescript
// Calculated in frontend/API
const isOverdue = 
  invoice.status === 'sent' || invoice.status === 'approved'
  && new Date(invoice.due_date) < new Date()
```

---

## 7. Deployment Topology

### 7.1 Infrastructure (Vercel + Supabase)

```text
┌─────────────────────────────────────────────────────────────┐
│ Vercel Edge Network (Global CDN)                            │
│ - Auto-scaling serverless functions                         │
│ - HTTPS/TLS 1.3 (auto-SSL)                                  │
│ - DDoS protection (Vercel built-in)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│ Static Assets   │      │ API Routes      │
│ (Next.js SSG)   │      │ (Serverless)    │
│ - Landing page  │      │ - /api/*        │
│ - Client portal │      │ Cold start:     │
│ (Edge cached)   │      │ ~300ms          │
└─────────────────┘      └────────┬────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │ Supabase (us-west-1)          │
                  │ - PostgreSQL 15 (500MB)       │
                  │ - Auth (JWT + RLS)            │
                  │ - Storage (1GB)               │
                  │ - Auto-backup (daily, 7 days) │
                  └───────────────────────────────┘
```

### 7.2 Environment Variables

**Production (.env.production)**:
```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi... # Server-only, client portal access

# Sentry
NEXT_PUBLIC_SENTRY_DSN=https://xxx@sentry.io/xxx

# App Config
NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
```

**Local Development (.env.local)**:
```bash
# Supabase (same as production, separate project)
NEXT_PUBLIC_SUPABASE_URL=https://dev-xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...

# Local overrides
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 7.3 Deployment Pipeline

```text
┌─────────────────────────────────────────────────────────────┐
│ 1. Git Push (main branch)                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Vercel Build (CI/CD)                                     │
│    - npm install                                            │
│    - npm run build (Next.js SSG + API routes)               │
│    - TypeScript type check                                  │
│    - Lint check (ESLint)                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Vercel Deploy (auto)                                     │
│    - Deploy to edge network (global)                        │
│    - Preview URLs for PR branches                           │
│    - Production deploy on main branch merge                 │
└─────────────────────────────────────────────────────────────┘
```

**Rollback Strategy**:
- Vercel instant rollback (click "Promote" on previous deployment)
- Database migrations: Manual rollback via Supabase SQL editor

### 7.4 Monitoring & Observability

**Error Tracking** (Sentry):
- Frontend errors: Auto-captured by Sentry SDK
- API errors: Manual `Sentry.captureException()` in catch blocks
- Alert on >10 errors/hour

**Performance Monitoring** (Vercel Analytics):
- Core Web Vitals (FCP, LCP, CLS)
- API route response times
- Serverless function invocations

**Database Monitoring** (Supabase):
- Connection pool usage
- Slow query log (>500ms)
- Disk usage (500MB free tier)

---

## 8. Module 04 Prototype Conversion Strategy

**Chosen Stack**: Next.js 15 (React-based)  
**Compatibility Level**: **Level 1 (Direct Copy)**  
**Conversion Rate**: 95% code reuse

### 8.1 Conversion Plan

**Step 1: Setup Next.js Project**
```bash
npx create-next-app@latest freelance-invoice-tracker \
  --typescript --tailwind --app --src-dir --import-alias "@/*"

cd freelance-invoice-tracker
npm install @supabase/ssr @supabase/auth-helpers-nextjs
npm install react-hook-form zod @hookform/resolvers
npm install @react-pdf/renderer # PDF generation
npm install lucide-react # Icons
```

**Step 2: Copy Design Tokens**
- Copy `DESIGN.md` color palette → `tailwind.config.ts`
- Copy component styles → shadcn/ui installation

**Step 3: Extract Components from DESIGN_SPEC.md**
- Copy 33 screen specs → Create Next.js pages/routes
- DESIGN_SPEC wireframes → React components
- Tailwind classes preserved (no conversion needed)

**Step 4: Implement API Routes**
- Create `/app/api/` routes (see section 4.2)
- Supabase client integration
- Zod validation schemas

**Step 5: Testing**
- Manual QA: Complete user flow (signup → invoice → client approval)
- Edge cases: Empty states, error states, token expiry

**Estimated Conversion Time**: 10-14 days
- Day 1-2: Setup, Supabase schema, auth
- Day 3-5: Projects, time tracking, expenses modules
- Day 6-8: Invoice wizard, PDF generation
- Day 9-10: Client portal, settings
- Day 11-12: Dashboard, polish
- Day 13-14: Testing, bug fixes

### 8.2 Design System Preservation

**From DESIGN.md** (preserved in Tailwind):
```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: '#0891B2', // Cyan-600
        'primary-hover': '#0E7490', // Cyan-700
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

**Component Reuse**:
- shadcn/ui Button, Input, Card, Table → Already Tailwind-based (direct copy)
- Custom components: Extract from DESIGN_SPEC wireframes

**No Conversion Needed**:
- Tailwind classes same in prototype and production
- Color tokens (`bg-cyan-600`) map directly
- Spacing scale (`p-6`, `gap-4`) identical

---

## 9. Technical Specification Sign-Off

This document represents the final architecture specification. All code implementations in **Module 06: Development** must adhere to the schema definitions, API routes, and security architecture above.

| Solo Developer Self-Approval |
| :--- |
| **Name**: [Your Name] |
| **Date**: 2026-10-02 |
| **Status**: ✅ APPROVED - Ready for Module 06 (Development) |

---

**FSD Summary**:
- ✅ Database schema: 6 tables (profiles, clients, projects, time_entries, expenses, invoices)
- ✅ RLS policies: All tables protected by `auth.uid()` filter
- ✅ API contracts: 10+ endpoints (projects, time, expenses, invoices, client portal)
- ✅ Security: HTTPS, bcrypt, JWT, token-based client access, Zod validation
- ✅ PDF generation: React-PDF (recommended) or Puppeteer (fallback)
- ✅ Deployment: Vercel (free tier) + Supabase (free tier), $0/month
- ✅ Conversion strategy: Direct copy (95% reuse), 10-14 days

**Artifacts Complete**:
1. ✅ LOGO_DESIGN_BRIEF.md (10.1KB)
2. ✅ SITEMAP.md (12.1KB, 33 screens)
3. ✅ DESIGN.md (20.4KB, design tokens)
4. ✅ DESIGN_SPEC.md (29.7KB, screen specs)
5. ✅ PRD.md (24KB, 28 requirements)
6. ✅ FSD.md (THIS FILE, technical architecture)

**Next Step**: Module 06 — Development & Implementation (coding phase)

---

**Last Updated**: 2026-10-02  
**Document Status**: DRAFT - Ready for development approval
# Development TODO
Freelance Invoice Tracker

> Task breakdown for M06 Development. Check off as you complete.

---

## Setup Phase (Days 1-2)

### Environment Setup
- [x] Verify Next.js 15 + Tailwind 3.4 installed
- [x] Copy `.env.example` → `.env.local`
- [x] Get Supabase credentials (create project at supabase.com)
- [x] Update `.env.local` with Supabase URL + keys
- [x] Test dev server: `npm run dev`

### Supabase Setup
- [x] Create Supabase project (free tier)
- [x] Copy database schema from `docs/specs/FSD.md` section 3
- [x] Run SQL in Supabase SQL Editor (create tables)
- [x] Enable Row-Level Security (RLS) on all tables
- [x] Create RLS policies (copy from FSD.md)
- [ ] Test: Create user, verify profile auto-created (will verify in Day 3)
- [x] Create Storage buckets: `receipts`, `logos`, `avatars`

### Dependencies Installation
- [x] Install Supabase: `npm install @supabase/ssr @supabase/supabase-js`
- [x] Install forms: `npm install react-hook-form zod @hookform/resolvers`
- [x] Install PDF: `npm install @react-pdf/renderer`
- [x] Install UI: `npm install lucide-react date-fns`
- [x] Install fonts: `npm install geist`
- [x] Install shadcn/ui: `npx shadcn-ui@latest init`

---

## Core Features (Days 3-10)

### Auth Module (Day 3)
- [ ] Create Supabase client utilities (`lib/supabase/`)
  - [ ] `client.ts` - Client component client
  - [ ] `server.ts` - Server component client
  - [ ] `route-handler.ts` - API route client
- [ ] Create auth pages
  - [ ] `app/(auth)/login/page.tsx`
  - [ ] `app/(auth)/signup/page.tsx`
  - [ ] `app/(auth)/forgot-password/page.tsx`
  - [ ] `app/(auth)/reset-password/page.tsx`
- [ ] Create auth middleware (`middleware.ts`)
- [ ] Test: Signup → Login → Protected route redirect

### Dashboard (Day 4)
- [ ] Create layout: `app/(dashboard)/layout.tsx` (sidebar, header)
- [ ] Create dashboard page: `app/(dashboard)/dashboard/page.tsx`
- [ ] Stat cards component (4 cards: revenue, pending, projects, hours)
- [ ] Recent invoices table (5 latest)
- [ ] Quick actions buttons (log time, new project, create invoice)
- [ ] Test: Empty state (no projects) → shows CTA

### Projects Module (Day 5)
- [ ] Create Zod schema: `lib/validations/project.ts`
- [ ] List page: `app/(dashboard)/projects/page.tsx`
  - [ ] Fetch projects (Supabase query)
  - [ ] Table with columns: Name, Client, Rate, Hours, Status
  - [ ] Filter by status (active, completed, archived)
  - [ ] Search bar
  - [ ] "New Project" button
- [ ] Create page: `app/(dashboard)/projects/new/page.tsx`
  - [ ] Form: name, client (dropdown), hourly rate, description
  - [ ] React Hook Form + Zod validation
  - [ ] Submit → API route → redirect to detail
- [ ] Detail page: `app/(dashboard)/projects/[id]/page.tsx`
  - [ ] Summary card (name, client, rate, total hours, total expenses)
  - [ ] Tabs: Time Entries | Expenses | Invoices
  - [ ] Time entries table (date, description, hours, amount)
  - [ ] "Log Time" button
- [ ] Edit page: `app/(dashboard)/projects/[id]/edit/page.tsx`
- [ ] API routes:
  - [ ] `app/api/projects/route.ts` (GET list, POST create)
  - [ ] `app/api/projects/[id]/route.ts` (GET detail, PUT update, DELETE archive)

### Clients Module (Day 6)
- [ ] Create Zod schema: `lib/validations/client.ts`
- [ ] List page: `app/(dashboard)/clients/page.tsx`
- [ ] Create page: `app/(dashboard)/clients/new/page.tsx`
- [ ] Detail page: `app/(dashboard)/clients/[id]/page.tsx`
  - [ ] Client info
  - [ ] Projects list (for this client)
  - [ ] Invoices list (for this client)
  - [ ] Revenue summary (total paid, pending, overdue)
- [ ] Edit page: `app/(dashboard)/clients/[id]/edit/page.tsx`
- [ ] API routes: `app/api/clients/` (CRUD)

### Time Tracking (Day 7)
- [ ] Create Zod schema: `lib/validations/time-entry.ts`
- [ ] Create page: `app/(dashboard)/time-entries/new/page.tsx`
  - [ ] Form: project (dropdown), date, hours, description
  - [ ] Auto-calculate amount (hours × project.hourly_rate)
  - [ ] Submit → API → redirect to project detail
- [ ] Edit page: `app/(dashboard)/time-entries/[id]/edit/page.tsx`
  - [ ] Pre-fill form with existing data
  - [ ] Disable if `is_invoiced = true` (show warning)
- [ ] API routes: `app/api/time-entries/` (POST, PUT, DELETE)

### Expenses (Day 7)
- [ ] Create Zod schema: `lib/validations/expense.ts`
- [ ] Create page: `app/(dashboard)/expenses/new/page.tsx`
  - [ ] Form: project, date, amount, description, receipt upload
  - [ ] Handle file upload (Supabase Storage)
  - [ ] Store receipt URL in database
- [ ] Edit page: `app/(dashboard)/expenses/[id]/edit/page.tsx`
- [ ] API routes: `app/api/expenses/` (POST, PUT, DELETE)

### Invoices Module (Days 8-9)
- [ ] Create Zod schema: `lib/validations/invoice.ts`
- [ ] List page: `app/(dashboard)/invoices/page.tsx`
  - [ ] Table: Invoice #, Client, Date, Amount, Status, Actions
  - [ ] Filter by status (draft, sent, paid, overdue)
  - [ ] Status badges (colored)
  - [ ] Actions: View, Edit (draft only), Send, Download PDF
- [ ] Create wizard: `app/(dashboard)/invoices/new/page.tsx`
  - [ ] Step 1: Select project (dropdown with unbilled time/expenses)
  - [ ] Step 2: Review line items (table, can remove items)
  - [ ] Step 3: Tax/discount form (tax rate, discount, due date, notes)
  - [ ] Step 4: PDF preview (iframe)
  - [ ] Submit → API → create invoice
- [ ] Detail page: `app/(dashboard)/invoices/[id]/page.tsx`
  - [ ] Invoice metadata (number, date, status)
  - [ ] Line items table
  - [ ] Totals breakdown (subtotal, tax, discount, total)
  - [ ] Notes section
  - [ ] Actions: Edit (draft), Send, Mark Paid, Download PDF
- [ ] Edit page: `app/(dashboard)/invoices/[id]/edit/page.tsx` (draft only)
- [ ] API routes:
  - [ ] `app/api/invoices/route.ts` (GET list, POST create)
  - [ ] `app/api/invoices/[id]/route.ts` (GET detail, PUT update)
  - [ ] `app/api/invoices/[id]/send/route.ts` (POST - generate token)
  - [ ] `app/api/invoices/[id]/paid/route.ts` (POST - mark paid)
  - [ ] `app/api/invoices/[id]/pdf/route.ts` (GET - generate PDF)

### PDF Generation (Day 9)
- [ ] Create PDF component: `components/InvoicePDF.tsx`
  - [ ] Use `@react-pdf/renderer` primitives
  - [ ] Layout: Header (logo, business info), Client info, Line items, Totals, Notes
  - [ ] Apply branding (logo URL, primary color from settings)
- [ ] API route: `app/api/invoices/[id]/pdf/route.ts`
  - [ ] Fetch invoice data (join with profiles, clients)
  - [ ] Render `<InvoicePDF />` to stream
  - [ ] Return PDF response (Content-Type: application/pdf)
- [ ] Test: Download PDF, verify formatting

### Client Portal (Day 10)
- [ ] Public layout: `app/client/layout.tsx` (no sidebar, minimal header)
- [ ] Invoice view: `app/client/invoice/[token]/page.tsx`
  - [ ] Validate token (API call)
  - [ ] Display invoice (read-only)
  - [ ] "Download PDF" button
  - [ ] "Approve Invoice" button (POST to API)
  - [ ] Show 404 if token invalid/revoked
- [ ] Success page: `app/client/invoice/[token]/approved/page.tsx`
  - [ ] Thank you message
  - [ ] "View Invoice Again" link
- [ ] API routes:
  - [ ] `app/api/client/invoice/[token]/route.ts` (GET - fetch by token)
  - [ ] `app/api/client/invoice/[token]/approve/route.ts` (POST - approve)

---

## Settings & Polish (Days 11-12)

### Settings Module (Day 11)
- [ ] Profile settings: `app/(dashboard)/settings/profile/page.tsx`
  - [ ] Form: name, email, phone, business name, address, tax ID
  - [ ] Avatar upload (Supabase Storage)
- [ ] Branding settings: `app/(dashboard)/settings/branding/page.tsx`
  - [ ] Logo upload
  - [ ] Primary color picker
  - [ ] Invoice footer text (textarea)
  - [ ] Live preview (show sample invoice)
- [ ] Tax settings: `app/(dashboard)/settings/tax/page.tsx`
  - [ ] Default tax rate (percentage)
  - [ ] Currency dropdown (USD, IDR, EUR)
  - [ ] Number format (1,234.56 vs 1.234,56)
  - [ ] Invoice number prefix (e.g., "INV-")
- [ ] Security settings: `app/(dashboard)/settings/security/page.tsx`
  - [ ] Change password form
- [ ] API routes: `app/api/settings/` (PUT for each setting type)

### UI Components (Day 11)
- [ ] Install shadcn/ui components:
  - [ ] `npx shadcn-ui@latest add button`
  - [ ] `npx shadcn-ui@latest add input`
  - [ ] `npx shadcn-ui@latest add card`
  - [ ] `npx shadcn-ui@latest add table`
  - [ ] `npx shadcn-ui@latest add dialog`
  - [ ] `npx shadcn-ui@latest add dropdown-menu`
  - [ ] `npx shadcn-ui@latest add tabs`
  - [ ] `npx shadcn-ui@latest add badge`
- [ ] Create custom components:
  - [ ] `components/StatusBadge.tsx` (invoice status colors)
  - [ ] `components/EmptyState.tsx` (no data placeholders)
  - [ ] `components/LoadingSpinner.tsx`

### Utilities (Day 12)
- [ ] Create utility functions: `lib/utils.ts`
  - [ ] `formatCurrency(amount, currency)` - Format numbers as currency
  - [ ] `formatDate(date)` - Format dates (DD/MM/YYYY)
  - [ ] `generateInvoiceNumber(prefix, counter)` - INV-2024-001
  - [ ] `calculateInvoiceTotal(lineItems, taxRate, discount)` - Math
- [ ] Create TypeScript types: `types/`
  - [ ] `Invoice.ts`, `Project.ts`, `Client.ts`, `TimeEntry.ts`, `Expense.ts`

---

## Testing & Deployment (Days 13-14)

### Manual Testing (Day 13)
- [ ] **Complete user flow**:
  - [ ] Signup → Create client → Create project → Log time → Log expense
  - [ ] Create invoice → Send to client → Client approves → Mark paid
- [ ] **Empty states**: Verify all "No data" states render correctly
- [ ] **Error states**: Test validation errors, network failures
- [ ] **Edge cases**:
  - [ ] Cannot edit time entry after invoiced
  - [ ] Cannot edit sent invoice (only drafts)
  - [ ] Cannot delete project with invoices
  - [ ] Invalid client token shows 404
- [ ] **Responsive**:
  - [ ] Test 375px (mobile), 768px (tablet), 1280px (desktop)
  - [ ] Sidebar collapses on mobile
  - [ ] Tables scroll horizontally on mobile
- [ ] **Auth**:
  - [ ] Logout redirects to login
  - [ ] Protected routes require auth
  - [ ] Password reset works
- [ ] **RLS (Row-Level Security)**:
  - [ ] Create 2 test users
  - [ ] Verify user A cannot see user B's data
  - [ ] Verify client portal only shows own invoice

### Code Quality (Day 13)
- [ ] Type check: `npm run type-check` (no errors)
- [ ] Lint: `npm run lint` (fix all warnings)
- [ ] Build: `npm run build` (succeeds)
- [ ] Review TODO comments (resolve or document)
- [ ] Remove console.logs (except error logging)

### Deployment Prep (Day 14)
- [ ] Create Supabase production project (separate from dev)
- [ ] Run database migrations on production
- [ ] Set environment variables in Vercel:
  - [ ] `NEXT_PUBLIC_SUPABASE_URL` (production)
  - [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - [ ] `SUPABASE_SERVICE_ROLE_KEY`
  - [ ] `NEXT_PUBLIC_APP_URL` (vercel.app domain)
  - [ ] `NEXT_PUBLIC_SENTRY_DSN` (optional)
- [ ] Connect GitHub repo to Vercel
- [ ] Deploy to Vercel (main branch auto-deploys)
- [ ] Test production URL (smoke test: signup, create invoice)
- [ ] Monitor Sentry for errors (first 24 hours)

### Documentation (Day 14)
- [ ] Update README.md:
  - [ ] Project description
  - [ ] Tech stack
  - [ ] Setup instructions
  - [ ] Environment variables
  - [ ] Screenshots (optional)
- [ ] Create RUNBOOK_LOCAL.md:
  - [ ] How to run locally
  - [ ] How to reset database
  - [ ] Common issues & solutions

---

## Phase 2 (Future - Out of MVP Scope)

### Features
- [ ] Recurring invoices (monthly retainers)
- [ ] Payment gateway (Stripe, PayPal)
- [ ] Email notifications (auto-send invoice)
- [ ] Team collaboration (invite users)
- [ ] Time tracking timer (live stopwatch)
- [ ] Accounting export (QuickBooks, Xero)
- [ ] Multi-language (i18n)
- [ ] Mobile app (React Native)

### Improvements
- [ ] Automated tests (Jest, Playwright)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Database backups (automated)
- [ ] Performance monitoring (Lighthouse)
- [ ] Analytics (user behavior tracking)

---

## Progress Tracking

**Current Status**: Setup Phase (Day 1)

**Completed**: 
- [x] M04: Design (33 screens, design system)
- [x] M05: Architecture (database schema, API contracts)
- [x] M06 Scaffold: Next.js 15 + Tailwind 3.4 installed
- [x] Harness files generated (AGENTS.md, ARCHITECTURE.md, etc.)

**Next**: 
1. Finish downgrade (Next.js 15 + Tailwind 3.4)
2. Deploy harness files to root
3. Setup Supabase project
4. Start auth module

**Blocked**: None

---

**Last Updated**: 2026-10-02  
**Estimated Completion**: 2026-10-16 (14 days)
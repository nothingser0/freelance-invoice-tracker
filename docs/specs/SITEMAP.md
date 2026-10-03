# SITEMAP - Information Architecture
Freelance Invoice Tracker

## Total Screens: 33 screens

---

## PUBLIC PAGES (Unauthenticated)

**Root**: `/`
├── `/` - Landing page (hero, features, pricing, CTA)
├── `/login` - Freelancer login form (email + password)
├── `/signup` - Registration form (name, email, password, business name)
├── `/forgot-password` - Request password reset email
└── `/reset-password?token=xxx` - Reset password with token verification

---

## AUTHENTICATED PAGES (Freelancer Dashboard)

**Dashboard**: `/dashboard` (Landing page after login)
- Overview cards: Total revenue (month/year), pending payments, active projects count
- Recent invoices list (5 latest with status badges)
- Quick actions: New project, Log time, Create invoice

---

### Projects Module
**Base**: `/projects`

├── `/projects` - List view (table: project name, client, hourly rate, total hours, status)
├── `/projects/new` - Create new project form (name, client selection, hourly rate, description)
├── `/projects/:id` - Project detail view
│   ├── Project summary (name, client, rate, total logged hours, total expenses)
│   ├── Time entries table (date, description, hours, amount)
│   ├── Expenses table (date, description, amount, receipt)
│   └── Actions: Log time, Add expense, Create invoice
└── `/projects/:id/edit` - Edit project metadata (name, rate, status)

---

### Time Tracking Module
**Base**: `/time-entries`

├── `/time-entries/new` - Log time entry form (project selection, date, hours, description)
└── `/time-entries/:id/edit` - Edit existing time entry

---

### Expenses Module
**Base**: `/expenses`

├── `/expenses/new` - Log expense form (project selection, date, amount, description, receipt upload)
└── `/expenses/:id/edit` - Edit existing expense

---

### Invoices Module
**Base**: `/invoices`

├── `/invoices` - List view (table: invoice number, client, date, amount, status, actions)
│   ├── Filters: Status (draft, sent, paid), date range, client
│   ├── Status badges: Draft (gray), Sent (blue), Paid (green), Overdue (red)
│   └── Actions per row: View, Edit (draft only), Send, Mark paid, Download PDF
├── `/invoices/new` - Create invoice wizard
│   ├── Step 1: Select project (auto-populate time entries + expenses)
│   ├── Step 2: Review line items (add/remove items, adjust quantities)
│   ├── Step 3: Add tax/discount, set due date, add notes
│   └── Step 4: Preview PDF before saving
├── `/invoices/:id` - Invoice detail view (read-only for sent/paid)
│   ├── Invoice metadata (number, date, due date, status)
│   ├── Line items breakdown (time entries + expenses)
│   ├── Calculation: Subtotal, tax, discount, total
│   ├── Client info, freelancer branding (logo, colors)
│   └── Actions: Edit (draft), Send to client (generate link), Mark paid, Download PDF
├── `/invoices/:id/edit` - Edit draft invoice (only if status = draft)
├── `/invoices/:id/preview` - Full-page PDF preview (before send)
└── `/invoices/:id/send` - Send invoice modal (generate client portal link, copy to clipboard)

---

### Clients Module
**Base**: `/clients`

├── `/clients` - List view (table: client name, email, phone, total projects, total revenue)
├── `/clients/new` - Create client form (name, email, phone, address, business name)
├── `/clients/:id` - Client detail view
│   ├── Client info summary
│   ├── Projects list (all projects for this client)
│   ├── Invoices list (all invoices sent to this client)
│   └── Revenue summary (total paid, pending, overdue)
└── `/clients/:id/edit` - Edit client metadata

---

### Settings Module
**Base**: `/settings`

├── `/settings/profile` - Freelancer profile
│   ├── Personal info (name, email, phone)
│   ├── Business info (business name, address, tax ID)
│   └── Avatar upload
├── `/settings/branding` - Invoice branding customization
│   ├── Logo upload (max 500KB, PNG/SVG)
│   ├── Primary color picker (for invoice header/accents)
│   ├── Invoice template preview (live preview as settings change)
│   └── Invoice footer text (e.g., payment terms, thank you note)
├── `/settings/tax` - Tax & currency settings
│   ├── Default tax rate (%, applies to all invoices unless overridden)
│   ├── Currency (USD, IDR, EUR, etc.)
│   ├── Number format (comma vs period for thousands/decimals)
│   └── Invoice numbering prefix (e.g., "INV-2024-")
└── `/settings/security` - Account security
    ├── Change password form
    └── Two-factor authentication setup (future: not MVP)

---

## CLIENT PORTAL (Public, Token-Authenticated)

**Base**: `/client`

├── `/client/invoice/:token` - Client invoice view (read-only)
│   ├── Invoice details (number, date, due date, amount)
│   ├── Freelancer branding (logo, business info)
│   ├── Line items breakdown (time + expenses)
│   ├── Payment status (pending/paid badge)
│   ├── Actions: Download PDF, Approve invoice (button)
│   └── Footer: "Powered by Freelance Invoice Tracker" + contact info
└── `/client/invoice/:token/approved` - Success page after client approves
    └── Thank you message, next steps (payment instructions if applicable)

---

## Screen Count by Module

| Module | Screens | Notes |
|--------|---------|-------|
| Public | 5 | Landing, login, signup, forgot/reset password |
| Dashboard | 1 | Main landing after auth |
| Projects | 4 | List, new, detail, edit |
| Time Entries | 2 | New, edit |
| Expenses | 2 | New, edit |
| Invoices | 6 | List, new (wizard), detail, edit, preview, send |
| Clients | 4 | List, new, detail, edit |
| Settings | 4 | Profile, branding, tax, security |
| Client Portal | 2 | Invoice view, approval success |
| **TOTAL** | **33** | MVP scope (invoice wizard = 4 separate steps) |

---

## Navigation Structure

### Top Navigation (Authenticated Freelancer)
**Header Bar**:
- Logo (left) → `/dashboard`
- Main Nav (center): 
  - Dashboard
  - Projects
  - Invoices
  - Clients
  - Settings (dropdown)
- User Menu (right): 
  - Avatar + name dropdown
  - Profile
  - Settings
  - Logout

### Mobile Navigation
**Bottom Tab Bar** (responsive <768px):
- Dashboard (home icon)
- Projects (folder icon)
- Invoices (document icon)
- Clients (users icon)
- More (hamburger → settings, logout)

### Breadcrumbs (Context Awareness)
Examples:
- Home > Projects > Project Name > Edit
- Home > Invoices > Invoice #INV-2024-001 > Preview
- Home > Clients > Client Name > Projects

---

## User Flows (Critical Paths)

### Flow 1: First-Time User Onboarding
1. `/signup` → create account
2. `/dashboard` → empty state with "Get Started" prompt
3. `/settings/profile` → complete business info + upload logo
4. `/clients/new` → add first client
5. `/projects/new` → create first project
6. `/time-entries/new` → log first time entry
7. `/invoices/new` → generate first invoice
8. `/invoices/:id/send` → send to client portal

### Flow 2: Daily Time Tracking
1. `/dashboard` → click "Log Time" quick action
2. `/time-entries/new` → select project, enter hours, description
3. Submit → redirect to `/projects/:id` (see updated total hours)

### Flow 3: Monthly Invoicing Routine
1. `/projects/:id` → review logged time + expenses for month
2. Click "Create Invoice" → `/invoices/new`
3. Wizard auto-populates line items from project
4. Adjust tax/discount, set due date
5. `/invoices/:id/preview` → review PDF
6. `/invoices/:id/send` → generate client portal link
7. Copy link, send via email/WhatsApp manually (no auto-email in MVP)

### Flow 4: Client Views & Approves Invoice
1. Client receives link: `https://app.example.com/client/invoice/abc123token`
2. `/client/invoice/:token` → view invoice details + PDF
3. Click "Approve Invoice" → status updates to "Approved" (NOT paid yet)
4. `/client/invoice/:token/approved` → success message
5. Freelancer sees status change in `/invoices` list (Sent → Approved)
6. Freelancer manually marks as Paid when payment received

### Flow 5: Revenue Tracking
1. `/dashboard` → view total revenue cards (monthly/yearly)
2. `/invoices` → filter by "Paid" status
3. Click invoice → `/invoices/:id` → view payment details
4. `/clients/:id` → view per-client revenue breakdown

---

## Route Aliases & Redirects

**Convenience Aliases**:
- `/` (logged in) → redirect to `/dashboard`
- `/` (logged out) → show landing page
- `/invoice/:id` → public share, redirect to `/client/invoice/:token` if valid

**Error Pages**:
- `/404` - Page not found
- `/403` - Unauthorized (client tries to access freelancer dashboard)
- `/500` - Server error

---

## Access Control by Role

| Route Pattern | Freelancer (Owner) | Client (Token) | Public |
|---------------|-------------------|----------------|--------|
| `/` | ✅ Redirect to dashboard | ✅ Landing page | ✅ Landing page |
| `/login`, `/signup` | ✅ (redirect if logged in) | ✅ | ✅ |
| `/dashboard`, `/projects/*`, `/invoices/*`, `/clients/*`, `/settings/*` | ✅ Full access | ❌ 403 | ❌ Redirect to login |
| `/client/invoice/:token` | ✅ (can view own) | ✅ If token valid | ✅ If token valid |

---

## State & Empty States

**Empty States** (Defensive UX):
1. `/dashboard` - No projects yet → "Create your first project" CTA
2. `/projects` - No projects → "Add a project to start tracking time" prompt
3. `/invoices` - No invoices → "Generate your first invoice from a project"
4. `/clients` - No clients → "Add a client to get started"
5. `/projects/:id` - No time entries → "Log your first time entry" button
6. `/projects/:id` - No expenses → "Add an expense" button

**Loading States**:
- Skeleton loaders for tables (projects, invoices, clients lists)
- Spinner for PDF generation (invoice preview)
- Loading indicator for form submissions

**Error States**:
- Form validation errors (inline, per field)
- Invoice send failure (network error, invalid email)
- PDF generation failure (fallback to "Try again" button)

---

## Technical Notes

### URL Patterns
- **RESTful conventions**: `/resource/:id/action`
- **Token auth**: `/client/invoice/:token` uses secure random token (32-char hex), NOT invoice ID (prevents enumeration)
- **Query params**: `/invoices?status=paid&client=123&from=2024-01-01&to=2024-12-31`

### Deep Linking
- Invoice share link must work without login: `/client/invoice/:token`
- Token expires? Optional feature (MVP: no expiry, just revoke via "Revoke link" button)

### SEO (Public Pages Only)
- `/` - Landing page: meta tags, Open Graph
- `/client/invoice/:token` - Invoice view: `noindex, nofollow` (prevent indexing)

---

## Future Expansion (Out of Scope for MVP)

**Phase 2 Features** (not in sitemap):
- Payment gateway integration (Stripe/PayPal) → `/invoices/:id/pay`
- Recurring invoices → `/invoices/recurring/new`
- Team collaboration → `/team`, `/team/invite`
- Accounting export → `/settings/integrations` (QuickBooks, Xero)
- Client self-service portal → `/client/dashboard` (view all invoices, update profile)
- Time tracking timer (stopwatch) → `/timer` live page
- Mobile app (React Native) → native navigation

---

## Validation Checklist

- [x] All user stories from pitch covered (time tracking, expense, invoice generation, client portal)
- [x] Two-sided portal (freelancer dashboard + client read-only view)
- [x] Core loop complete: Log time → Create invoice → Send to client → Approve → Mark paid
- [x] First slice achievable: Create project, log time, generate PDF, client view link
- [x] No out-of-scope features (payment gateway, subscription billing, team, accounting)
- [x] Screen count reasonable for MVP: 30 screens (2-4 weeks realistic for solo dev)
- [x] Navigation structure intuitive (grouped by resource type)
- [x] Empty/loading/error states documented
- [x] Access control clear (freelancer vs client vs public)

---

**Last Updated**: 2026-10-02  
**Approved By**: [Pending user review]  
**Status**: DRAFT - Ready for workflow selection (Manual Figma / AI-Assisted / Hybrid)
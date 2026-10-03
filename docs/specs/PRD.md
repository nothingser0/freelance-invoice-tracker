# Product Requirement Document (PRD)
Freelance Invoice Tracker

> Official product requirements specification document defining all system functionality, user flows, non-functional constraints, and release acceptance criteria.

---

## 1. Document Metadata
- **Product / System Name**: Freelance Invoice Tracker
- **Client**: Portfolio MVP (Solo Developer)
- **Lead Architect / Solo Engineer**: [Your Name]
- **Design Reference**: DESIGN_SPEC.md v1.0 (Frozen)
- **Scope Reference**: SITEMAP.md v1.0 (33 screens)
- **Tech Stack**: Next.js 15 + Supabase + Vercel (Option A - Locked)
- **Document Version**: 1.0.0
- **Document Status**: DRAFT - Pending Approval
- **Approval Date**: 2026-10-02 (tentative)

---

## 2. Executive Summary & Business Objectives

**Product Description**: 
Freelance Invoice Tracker is a project management and invoicing tool for freelancers managing 3-10 clients simultaneously. The system tracks billable hours, expenses, and generates professional PDF invoices with custom branding for client approval via a read-only portal.

**Primary Problem Solved**:
- Freelancers manually track time in spreadsheets, losing billable hours
- Generic Word/Excel invoice templates look unprofessional and lack branding
- No centralized system to track which invoices are sent, approved, or paid
- Clients never confirm receipt, making payment status unclear

**Target Users**:
1. **Freelancers** (developers, designers, consultants): 1-person businesses managing multiple clients, need to track time, create invoices, and monitor payments
2. **Clients**: Receive invoices via shareable link, view line items breakdown, approve invoices (no account required)

**Key Performance Indicators (KPI)**:
- Time to create invoice: < 3 minutes (from project selection to PDF generation)
- Invoice approval rate: ≥ 80% (clients approve within 7 days)
- Payment tracking accuracy: 100% (all invoices marked paid/unpaid correctly)
- User retention: 60% MAU return rate (monthly active users)

---

## 3. User Role & Access Matrix (Role-Based Access Control)

| Role Code | Role Name | Projects | Time/Expenses | Invoices | Clients | Settings | Client Portal |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **ROL-01** | Freelancer (Owner) | Full CRUD | Full CRUD | Full CRUD | Full CRUD | Full Access | Generate Links |
| **ROL-02** | Client (Guest) | No Access | No Access | Read-Only (via token) | No Access | No Access | View Own Invoices |

**Access Control Rules**:
- Freelancer: Authenticated via Supabase Auth (email/password), owns all data
- Client: Token-authenticated (no account required), can only view invoices with valid token
- Multi-tenancy: Each freelancer's data isolated via Supabase RLS (Row-Level Security)
- No team collaboration in MVP (single freelancer per account)

---

## 4. Functional Requirements Specification

### Module 1: Authentication & Session Management

**REQ-AUTH-01: Freelancer Registration**
- **User Story**: As a new freelancer, I want to create an account with email and password so that I can start tracking projects and invoices.
- **Acceptance Criteria**:
  - [ ] Email must be unique and valid format
  - [ ] Password minimum 8 characters, must contain 1 uppercase, 1 lowercase, 1 number
  - [ ] Password stored using Supabase Auth (bcrypt hashing)
  - [ ] Account created includes default settings (tax rate 0%, currency USD, invoice prefix "INV-")
  - [ ] Redirect to `/dashboard` after successful signup

**REQ-AUTH-02: Freelancer Login**
- **User Story**: As a returning freelancer, I want to log in with email/password so that I can access my projects and invoices.
- **Acceptance Criteria**:
  - [ ] Session stored in HttpOnly cookie (Supabase Auth token)
  - [ ] Failed login attempts: max 5 attempts within 15 minutes (Supabase rate limiting)
  - [ ] "Forgot password" link sends reset email via Supabase Auth
  - [ ] Session expires after 7 days of inactivity

**REQ-AUTH-03: Password Reset**
- **User Story**: As a freelancer who forgot password, I want to receive a reset link via email so that I can regain access.
- **Acceptance Criteria**:
  - [ ] Reset link sent via Supabase Auth (expires in 1 hour)
  - [ ] Token validates before showing password reset form
  - [ ] New password must meet same strength requirements as signup
  - [ ] Old password invalidated after successful reset

---

### Module 2: Project Management

**REQ-PROJ-01: Create Project**
- **User Story**: As a freelancer, I want to create a project linked to a client with an hourly rate so that I can track billable time.
- **Acceptance Criteria**:
  - [ ] Required fields: Project name, Client (dropdown), Hourly rate (number)
  - [ ] Optional fields: Description (textarea), Status (Active/Completed/Archived)
  - [ ] Hourly rate must be positive number, supports decimals (e.g., 250000.50)
  - [ ] Project saved to database with `created_at` timestamp
  - [ ] Redirect to `/projects/:id` after creation

**REQ-PROJ-02: View Project Details**
- **User Story**: As a freelancer, I want to view all time entries and expenses for a project so that I can see total billable amount.
- **Acceptance Criteria**:
  - [ ] Display project summary: Name, Client, Hourly rate, Total hours logged, Total expenses
  - [ ] Auto-calculate total value: (Total hours × Hourly rate) + Total expenses
  - [ ] Tabs: Time Entries | Expenses | Invoices
  - [ ] Time Entries tab shows table: Date, Description, Hours, Amount (calculated), Actions (Edit/Delete)
  - [ ] Expenses tab shows table: Date, Description, Amount, Receipt (link), Actions (Edit/Delete)
  - [ ] Empty state: "No time entries yet. Log your first time entry." with CTA button

**REQ-PROJ-03: Edit/Delete Project**
- **User Story**: As a freelancer, I want to edit project details or archive completed projects.
- **Acceptance Criteria**:
  - [ ] Edit: Can change name, hourly rate, description, status
  - [ ] Cannot edit if project has invoices (prevent rate mismatch)
  - [ ] Delete: Soft delete (mark as archived), time entries preserved
  - [ ] Confirmation modal before delete: "Are you sure? This will archive the project."

---

### Module 3: Time Tracking

**REQ-TIME-01: Log Time Entry**
- **User Story**: As a freelancer, I want to log hours worked on a project so that I can bill the client accurately.
- **Acceptance Criteria**:
  - [ ] Required fields: Project (dropdown), Date (date picker), Hours (number), Description (textarea)
  - [ ] Hours must be positive, supports decimals (e.g., 2.5 hrs)
  - [ ] Date cannot be in the future
  - [ ] Amount auto-calculated: Hours × Project hourly rate
  - [ ] Time entry saved with `freelancer_id` for RLS filtering
  - [ ] Redirect to `/projects/:id` after logging

**REQ-TIME-02: Edit/Delete Time Entry**
- **User Story**: As a freelancer, I want to edit or delete time entries if I logged incorrect hours.
- **Acceptance Criteria**:
  - [ ] Edit: Pre-fill form with existing data, allow changes
  - [ ] Cannot edit if time entry already invoiced (show warning)
  - [ ] Delete: Hard delete (remove from database)
  - [ ] Confirmation modal before delete

---

### Module 4: Expense Tracking

**REQ-EXP-01: Log Expense**
- **User Story**: As a freelancer, I want to log project expenses (e.g., stock photos, subscriptions) so that I can add them to invoices.
- **Acceptance Criteria**:
  - [ ] Required fields: Project (dropdown), Date, Amount, Description
  - [ ] Optional: Receipt upload (PNG/JPG/PDF, max 2MB)
  - [ ] Receipt stored in Supabase Storage, URL saved in database
  - [ ] Expense saved with `freelancer_id` for RLS filtering
  - [ ] Redirect to `/projects/:id` after logging

**REQ-EXP-02: Edit/Delete Expense**
- **User Story**: As a freelancer, I want to edit or delete expenses if I logged incorrect amounts.
- **Acceptance Criteria**:
  - [ ] Edit: Pre-fill form, allow changes, can re-upload receipt
  - [ ] Cannot edit if expense already invoiced
  - [ ] Delete: Hard delete, also delete receipt file from Supabase Storage
  - [ ] Confirmation modal before delete

---

### Module 5: Invoice Generation & Management

**REQ-INV-01: Create Invoice (Wizard)**
- **User Story**: As a freelancer, I want to generate an invoice from a project's time entries and expenses so that I can bill the client.
- **Acceptance Criteria**:
  - [ ] **Step 1: Select Project**
    - Dropdown of projects with unbilled time/expenses
    - Display summary: "12 time entries (32 hrs, Rp 8,000,000), 2 expenses (Rp 300,000)"
    - Next button disabled if no project selected
  - [ ] **Step 2: Review Line Items**
    - Auto-populate table: Description (from time entry/expense), Quantity, Rate, Amount
    - Can remove line items (uncheck box)
    - Can add custom line item (manual entry)
    - Subtotal auto-calculates
  - [ ] **Step 3: Tax & Discount**
    - Tax rate input (default from settings, editable)
    - Discount input (optional, in currency)
    - Due date picker (default +14 days)
    - Notes textarea (payment terms, bank details)
    - Calculation: Subtotal - Discount + Tax = Total
  - [ ] **Step 4: Preview PDF**
    - Render full invoice PDF in iframe
    - Show freelancer logo (from settings), business info, client info, line items, totals
    - Buttons: "Back to Edit" | "Save as Draft" | "Send to Client"

**REQ-INV-02: Invoice Statuses**
- **User Story**: As a freelancer, I want to track invoice statuses so that I know which are pending payment.
- **Acceptance Criteria**:
  - [ ] **Draft**: Editable, not sent to client, can delete
  - [ ] **Sent**: Client link generated, read-only, can mark paid or revoke link
  - [ ] **Approved**: Client clicked "Approve" button, awaiting payment
  - [ ] **Paid**: Freelancer manually marked as paid (after receiving payment)
  - [ ] **Overdue**: Due date passed, status = Sent/Approved but not Paid
  - [ ] Status badge colors: Draft (gray), Sent (blue), Approved (cyan), Paid (green), Overdue (red)

**REQ-INV-03: Send Invoice to Client**
- **User Story**: As a freelancer, I want to generate a shareable link so that the client can view and approve the invoice without logging in.
- **Acceptance Criteria**:
  - [ ] Generate secure token (32-char random hex, stored in database)
  - [ ] Link format: `https://app.vercel.app/client/invoice/{token}`
  - [ ] Token never expires (manual revoke via "Revoke Link" button)
  - [ ] Modal shows link + "Copy to Clipboard" button
  - [ ] Status changes to "Sent" after link generated
  - [ ] Freelancer sends link manually (via email/WhatsApp, no auto-email in MVP)

**REQ-INV-04: Edit Draft Invoice**
- **User Story**: As a freelancer, I want to edit draft invoices before sending them.
- **Acceptance Criteria**:
  - [ ] Only draft invoices can be edited
  - [ ] Edit reopens wizard at Step 2 (line items)
  - [ ] Can change line items, tax, discount, notes
  - [ ] Save button updates invoice, stays in draft status

**REQ-INV-05: Mark Invoice as Paid**
- **User Story**: As a freelancer, I want to mark invoices as paid after receiving payment so that I can track revenue.
- **Acceptance Criteria**:
  - [ ] "Mark as Paid" button appears on Sent/Approved invoices
  - [ ] Confirmation modal: "Confirm payment received?"
  - [ ] Status changes to "Paid", `paid_at` timestamp recorded
  - [ ] Cannot revert to unpaid (prevent accidental marking)

**REQ-INV-06: Download Invoice PDF**
- **User Story**: As a freelancer, I want to download invoice PDFs so that I can send them via email or print them.
- **Acceptance Criteria**:
  - [ ] "Download PDF" button on invoice detail page
  - [ ] Generates PDF on-demand (React-PDF server-side)
  - [ ] Filename format: `Invoice-INV-2024-001.pdf`
  - [ ] PDF includes: Freelancer logo, business info, client info, line items, totals, notes

---

### Module 6: Client Portal (Token-Authenticated)

**REQ-CLIENT-01: View Invoice (Client)**
- **User Story**: As a client, I want to view invoice details via a link so that I can verify charges before payment.
- **Acceptance Criteria**:
  - [ ] Client accesses `/client/invoice/{token}` (no login required)
  - [ ] Validate token: If invalid/revoked, show 404 "Invalid or expired link"
  - [ ] Display: Invoice number, date, due date, freelancer branding, line items, totals, notes
  - [ ] Read-only (no editing)
  - [ ] Buttons: "Download PDF" | "Approve Invoice"

**REQ-CLIENT-02: Approve Invoice (Client)**
- **User Story**: As a client, I want to approve an invoice so that the freelancer knows I've reviewed it.
- **Acceptance Criteria**:
  - [ ] "Approve Invoice" button sends POST request to API
  - [ ] Invoice status changes to "Approved"
  - [ ] `approved_at` timestamp recorded
  - [ ] Redirect to `/client/invoice/{token}/approved` (thank you page)
  - [ ] Approval is one-way (client cannot un-approve)

**REQ-CLIENT-03: Download PDF (Client)**
- **User Story**: As a client, I want to download the invoice PDF for my records.
- **Acceptance Criteria**:
  - [ ] "Download PDF" button generates PDF on-demand
  - [ ] Same PDF format as freelancer view (consistent branding)
  - [ ] No authentication required (token validates access)

---

### Module 7: Client Management

**REQ-CLT-01: Create Client**
- **User Story**: As a freelancer, I want to add clients so that I can associate projects and invoices with them.
- **Acceptance Criteria**:
  - [ ] Required fields: Name, Email
  - [ ] Optional fields: Phone, Address, Business name
  - [ ] Email must be valid format (validation)
  - [ ] Client saved with `freelancer_id` for RLS filtering
  - [ ] Redirect to `/clients/:id` after creation

**REQ-CLT-02: View Client Details**
- **User Story**: As a freelancer, I want to view all projects and invoices for a client so that I can see total revenue.
- **Acceptance Criteria**:
  - [ ] Display client info: Name, Email, Phone, Address
  - [ ] Tabs: Projects | Invoices
  - [ ] Projects tab: Table of all projects for this client
  - [ ] Invoices tab: Table of all invoices sent to this client
  - [ ] Revenue summary: Total paid, Total pending, Total overdue

**REQ-CLT-03: Edit/Delete Client**
- **User Story**: As a freelancer, I want to edit client info or delete clients I no longer work with.
- **Acceptance Criteria**:
  - [ ] Edit: Can change name, email, phone, address
  - [ ] Cannot delete if client has projects (show warning)
  - [ ] Delete: Soft delete (mark as archived), projects preserved
  - [ ] Confirmation modal before delete

---

### Module 8: Settings & Customization

**REQ-SET-01: Profile Settings**
- **User Story**: As a freelancer, I want to set my business info so that it appears on invoices.
- **Acceptance Criteria**:
  - [ ] Fields: Name, Email, Phone, Business name, Address, Tax ID
  - [ ] Avatar upload: Drag & drop, max 2MB, PNG/JPG
  - [ ] Avatar stored in Supabase Storage
  - [ ] Save button updates user profile

**REQ-SET-02: Invoice Branding**
- **User Story**: As a freelancer, I want to customize invoice appearance so that it matches my brand.
- **Acceptance Criteria**:
  - [ ] Logo upload: Max 500KB, PNG/SVG only
  - [ ] Logo stored in Supabase Storage, URL saved in settings
  - [ ] Primary color picker: Choose accent color for invoice header
  - [ ] Invoice footer text: Textarea (payment terms, thank you message)
  - [ ] Live preview: Show invoice template with current settings (updates on change)
  - [ ] Save button updates settings

**REQ-SET-03: Tax & Currency Settings**
- **User Story**: As a freelancer, I want to set default tax rate and currency so that invoices auto-calculate correctly.
- **Acceptance Criteria**:
  - [ ] Tax rate input: Percentage (e.g., 11 for 11% VAT)
  - [ ] Currency dropdown: IDR, USD, EUR, GBP (more can be added)
  - [ ] Number format: Radio buttons (1.234.567,89 vs 1,234,567.89)
  - [ ] Invoice numbering prefix: Text input (e.g., "INV-2024-")
  - [ ] Auto-increment counter starts at 001
  - [ ] Save button updates settings

**REQ-SET-04: Change Password**
- **User Story**: As a freelancer, I want to change my password for security.
- **Acceptance Criteria**:
  - [ ] Fields: Current password, New password, Confirm new password
  - [ ] Current password must match existing (validate via Supabase Auth)
  - [ ] New password must meet strength requirements
  - [ ] Passwords must match (new = confirm)
  - [ ] Success: Session invalidated, redirect to login

---

### Module 9: Dashboard & Analytics

**REQ-DASH-01: Dashboard Overview**
- **User Story**: As a freelancer, I want to see key metrics at a glance so that I can track business health.
- **Acceptance Criteria**:
  - [ ] 4 stat cards:
    - Total Revenue (This Month): Sum of paid invoices in current month
    - Pending Payments: Sum of sent/approved invoices (not paid)
    - Active Projects: Count of projects with status = Active
    - Hours Logged (This Month): Sum of time entries in current month
  - [ ] Recent Invoices table: Last 5 invoices with status badges
  - [ ] Quick actions: "Log Time" | "New Project" | "Create Invoice" buttons
  - [ ] Empty state: "No projects yet. Create your first project to start."

---

## 5. Non-Functional Requirements (NFR)

### 5.1 Performance & Scalability
- **API Response Time**: Average endpoint response ≤ 300ms (p95 ≤ 500ms)
- **PDF Generation**: Invoice PDF generates in ≤ 2 seconds (React-PDF server-side)
- **Page Load**: First Contentful Paint (FCP) ≤ 1.5s, Largest Contentful Paint (LCP) ≤ 2.5s
- **Concurrent Users**: System handles 100 concurrent users without degradation (MVP target <100 users, headroom for growth)
- **Database Queries**: All list views paginated (10-20 items per page), use indexes on foreign keys

### 5.2 Availability & Reliability
- **Uptime SLA**: 99.9% monthly uptime (43 minutes downtime/month acceptable)
- **Vercel Free Tier Limits**: 100GB bandwidth/month (cold starts acceptable for MVP)
- **Supabase Free Tier**: 500MB database, 1GB storage, 50K monthly active users
- **Backups**: Supabase automatic daily backups (7-day retention, free tier)
- **Error Tracking**: Sentry captures exceptions, 5K errors/month free tier

### 5.3 Security & Compliance

**Authentication & Authorization**:
- Supabase Auth: Email/password, bcrypt hashing, session tokens in HttpOnly cookies
- Row-Level Security (RLS): All tables filtered by `freelancer_id`, clients cannot access other freelancers' data
- Token-based client access: 32-char random hex tokens for invoice links (non-guessable)
- Rate limiting: 5 failed login attempts per 15 minutes (Supabase built-in)

**Data Encryption**:
- **In Transit**: HTTPS only (TLS 1.3), enforced by Vercel/Supabase
- **At Rest**: Supabase encrypts database and storage (AES-256)
- **Sensitive Data**: No credit card data stored (out of scope), tax IDs optional

**Privacy & Compliance**:
- **UU PDP Compliance** (Indonesia): Not required for MVP (personal project, no real user data)
- **GDPR Compliance**: Not required (no EU users targeted)
- **Data Deletion**: Freelancer can delete own account (cascade delete all projects/invoices/clients)
- **No Third-Party Tracking**: No Google Analytics, Facebook Pixel, or ads (privacy-first MVP)

**Input Validation**:
- All forms use Zod schema validation (type-safe, prevents injection)
- File uploads: Type validation (MIME type check), size limits (2MB max)
- SQL injection: Prevented by Supabase client (parameterized queries)
- XSS protection: React escapes by default, no `dangerouslySetInnerHTML`

### 5.4 Usability & Accessibility
- **WCAG 2.1 AA Compliance**: All text ≥4.5:1 contrast, keyboard navigable, screen reader compatible
- **Mobile Responsive**: Works on 375px (iPhone SE) to 1920px (desktop)
- **Touch Targets**: All buttons ≥44px height (mobile tap-friendly)
- **Error Messages**: Inline validation, clear error text (e.g., "Email is required" not "Field required")
- **Loading States**: Skeleton loaders, spinners, disabled buttons during async operations

### 5.5 Browser & Device Support
- **Browsers**: Chrome 100+, Firefox 100+, Safari 15+, Edge 100+ (last 2 versions)
- **Mobile**: iOS Safari 15+, Chrome Android 100+
- **No IE11 support** (Next.js 15 drops legacy browsers)

---

## 6. Third-Party Service Dependencies

| Service Name | Integration Category | Free Tier Limits | Required Credentials | Fallback Plan |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase** | Database + Auth + Storage | 500MB DB, 1GB storage, 50K MAU | API URL, anon key, service role key | Migrate to Neon or self-hosted PostgreSQL |
| **Vercel** | Hosting + Deployment | 100GB bandwidth/month, serverless functions | Git integration (auto-deploy) | Migrate to Netlify, Railway, or DigitalOcean |
| **Sentry** | Error Monitoring | 5K errors/month | DSN key | Remove or self-host Sentry (Glitchtip) |
| **React-PDF** | PDF Generation | No limits (local library) | N/A | Fallback to Puppeteer (heavier bundle) |
| **(Optional) Resend** | Email (future)| 100 emails/day | API key | Manual email (copy invoice link) |

**No Payment Gateway**: Out of scope for MVP (manual payment tracking only)

---

## 7. Out of Scope (Future Phases)

**Phase 2 Features** (Not in MVP):
- Recurring invoices (monthly retainers)
- Payment gateway integration (Stripe, PayPal)
- Multi-user teams (invite collaborators)
- Time tracking timer (live stopwatch)
- Accounting export (QuickBooks, Xero sync)
- Email notifications (auto-send invoice via email)
- Client self-service portal (clients can update profile, view all invoices)
- Mobile app (React Native)
- Multi-language support (i18n)

---

## 8. Release Acceptance Criteria (MVP Launch Gate)

**Technical Readiness**:
- [ ] All 33 screens implemented and functional
- [ ] Database schema deployed to Supabase production
- [ ] Supabase RLS policies tested (freelancer A cannot access freelancer B's data)
- [ ] Invoice PDF generation works (React-PDF or Puppeteer)
- [ ] Client portal token authentication works (valid tokens show invoice, invalid = 404)
- [ ] Forms validated (Zod schemas, inline errors)
- [ ] Mobile responsive (tested on 375px, 768px, 1280px breakpoints)
- [ ] Lighthouse score: Performance ≥80, Accessibility ≥90, Best Practices ≥90
- [ ] Sentry error monitoring active (no critical errors in staging)

**User Testing**:
- [ ] Complete user flow tested: Signup → Create project → Log time → Create invoice → Send to client → Client approves → Mark paid
- [ ] Empty states verified (no projects, no invoices, no time entries)
- [ ] Error states verified (invalid token, network failure, validation errors)
- [ ] Edge cases tested (delete project with invoices, edit sent invoice = blocked)

**Deployment**:
- [ ] Deployed to Vercel production (custom domain optional)
- [ ] Supabase production database (separate from staging)
- [ ] Environment variables secured (.env.local not committed)
- [ ] README.md updated (setup instructions, tech stack, features)

**Launch Criteria**:
- [ ] Solo developer self-approval (portfolio project, no client sign-off)
- [ ] Public demo accessible via Vercel URL
- [ ] 3-5 sample invoices generated (showcase portfolio)

---

## 9. Product Requirement Document Sign-Off Sheet

This document serves as the official baseline for formulating the Functional Specification Document (FSD) and final system acceptance testing.

| Solo Developer Self-Approval |
| :--- |
| **Name**: [Your Name] |
| **Date**: 2026-10-02 |
| **Status**: ✅ APPROVED - Proceed to FSD.md (Technical Specifications) |

---

**PRD Summary**:
- ✅ 33 screens defined (9 modules)
- ✅ 28 functional requirements (REQ-AUTH-01 to REQ-DASH-01)
- ✅ 5 NFR categories (performance, security, usability, availability, browser support)
- ✅ Tech stack locked: Next.js 15 + Supabase + Vercel ($0/month)
- ✅ Out of scope defined (prevent scope creep)
- ✅ Acceptance criteria clear (checklist-based testing)

**Next Step**: Generate `FSD.md` (database schema, API contracts, security blueprint, deployment topology)

---

**Last Updated**: 2026-10-02  
**Document Status**: DRAFT - Ready for FSD generation
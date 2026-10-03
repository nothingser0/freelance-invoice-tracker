# Project Context
Freelance Invoice Tracker

> Why this project exists, who it's for, and what problems it solves.

---

## Problem Statement

**Freelancers managing 3-10 clients simultaneously face:**

1. **Time Tracking Chaos**
   - Manual spreadsheets lose billable hours
   - No centralized system to track project time
   - Forget to log hours → lose money

2. **Unprofessional Invoicing**
   - Word/Excel templates look generic
   - No custom branding (logo, colors)
   - Manual calculations prone to errors

3. **Payment Tracking Confusion**
   - Clients never confirm receipt (lost in email)
   - No visibility into payment status (sent? approved? paid?)
   - Chase payments manually via WhatsApp/email

4. **Client Communication Overhead**
   - Send invoice via email → no confirmation
   - Client asks "Did I already pay this?" → search email threads
   - No central portal for clients to view invoices

---

## Solution

**All-in-one time tracking + invoicing tool** with:

1. **Time & Expense Tracking**
   - Log hours per project (8.5 hrs × Rp 250,000/hr = Rp 2,125,000)
   - Track expenses (receipts, subscriptions)
   - Auto-calculate billable amounts

2. **Professional Invoice Generation**
   - PDF with custom branding (logo, colors)
   - Auto-calculate: (Time + Expenses) × Tax - Discount = Total
   - Line items breakdown for transparency

3. **Client Portal**
   - Share link (no client login required)
   - Client views invoice, clicks "Approve"
   - Freelancer sees approval status instantly

4. **Payment Tracking**
   - Dashboard shows: Total revenue, Pending payments, Overdue invoices
   - Mark as paid when payment received
   - Historical record for tax reporting

---

## Target Users

### Primary: Freelancers
- **Who**: Developers, designers, consultants (1-person businesses)
- **Size**: Managing 3-10 clients
- **Pain**: Manually tracking time in spreadsheets, generic invoices, payment confusion
- **Goal**: Professional invoicing, accurate time tracking, payment visibility

**Example Persona**: 
- **Sarah, 28, Freelance UI/UX Designer**
- 7 active clients (mix of local + international)
- Charges Rp 200,000-500,000/hour depending on project
- Spends 2 hours/week manually creating invoices in Figma
- Lost Rp 5,000,000 last year due to forgotten billable hours

### Secondary: Clients
- **Who**: Small businesses, startups, agencies hiring freelancers
- **Pain**: Lost invoices in email, no record of payment status
- **Goal**: Quick invoice approval, centralized history

---

## Core User Flow

```
1. Freelancer creates PROJECT
   - Name: "Website Redesign"
   - Client: PT ABC
   - Hourly Rate: Rp 250,000

2. Freelancer logs TIME ENTRIES
   - Date: 2024-10-01
   - Hours: 8.5
   - Description: "Homepage mockup design"
   - Amount: Rp 2,125,000 (auto-calculated)

3. Freelancer logs EXPENSES
   - Date: 2024-09-28
   - Amount: Rp 500,000
   - Description: "Stock photos license"
   - Receipt: Upload JPG

4. Freelancer creates INVOICE
   - Select project
   - Auto-populate time entries + expenses
   - Add tax (11%), discount (optional)
   - Preview PDF
   - Click "Send to Client"

5. System generates CLIENT LINK
   - Token: abc123xyz (32-char secure)
   - URL: https://app.vercel.app/client/invoice/abc123xyz
   - Freelancer copies link, sends via WhatsApp/email

6. Client opens link (NO LOGIN)
   - Views invoice details
   - Downloads PDF
   - Clicks "Approve Invoice"

7. Freelancer sees APPROVAL
   - Invoice status: Approved
   - Notified via dashboard
   - Waits for payment

8. Payment received
   - Freelancer marks as PAID
   - Revenue tracked in dashboard
   - Historical record kept
```

---

## Business Goals

### MVP (2-3 weeks)
- ✅ Portfolio showcase (demonstrate full-stack skills)
- ✅ Real-world functionality (actually usable by freelancers)
- ✅ Complete user flow (end-to-end: track → invoice → approve → paid)

### Phase 2 (Future)
- Recurring invoices (monthly retainers)
- Payment gateway integration (Stripe, PayPal)
- Email notifications (auto-send invoice)
- Team collaboration (invite other freelancers)
- Accounting export (QuickBooks, Xero)

---

## Success Metrics

**MVP Launch**:
- 3-5 sample invoices generated (showcase portfolio)
- Complete user flow tested (no blocking bugs)
- Deployed to Vercel (public URL accessible)

**Real Usage** (if shared publicly):
- 10 freelancers sign up within 1 month
- 50 invoices generated within 3 months
- 80% invoice approval rate (clients approve within 7 days)
- 60% MAU return rate (users come back monthly)

---

## Technical Constraints

**Budget**: $0/month (free tier only)
- Vercel Hobby: 100GB bandwidth/month
- Supabase Free: 500MB database, 1GB storage

**Timeline**: 2-3 weeks (MVP launch)
- Week 1: Setup, database, auth, projects module
- Week 2: Invoices, PDF generation, client portal
- Week 3: Polish, testing, deployment

**Complexity**: Medium
- Multi-role auth (freelancer vs client)
- PDF generation (custom branding)
- Client portal (token-based access)
- Invoice workflow (draft → sent → approved → paid)

---

## Scope Boundaries

### In Scope (MVP)
- Time tracking (log hours per project)
- Expense tracking (receipts, amount)
- Invoice generation (PDF with branding)
- Client portal (view + approve)
- Payment tracking (manual mark as paid)
- Settings (profile, branding, tax rate)

### Out of Scope (Phase 2)
- Payment gateway (Stripe, PayPal)
- Recurring invoices (subscriptions)
- Team collaboration (multi-user accounts)
- Email notifications (auto-send)
- Time tracking timer (live stopwatch)
- Mobile app (React Native)
- Accounting sync (QuickBooks, Xero)
- Multi-language (i18n)

---

## Competitive Landscape

**Existing Solutions**:

1. **FreshBooks** (Rp 200k/month)
   - ✅ Full-featured (invoicing + accounting)
   - ❌ Expensive for solo freelancers
   - ❌ Overkill features (payroll, proposals)

2. **Wave** (Free)
   - ✅ Free invoicing
   - ❌ US/Canada only (no Rupiah support)
   - ❌ Generic templates (no custom branding)

3. **Invoice Ninja** (Rp 100k/month)
   - ✅ Open-source
   - ❌ Complex setup (self-hosted)
   - ❌ Ugly UI (outdated design)

4. **Google Sheets + Word** (Free)
   - ✅ Free
   - ❌ Manual (copy-paste, error-prone)
   - ❌ No automation (calculate tax manually)
   - ❌ Unprofessional (no branding)

**Our Differentiator**:
- ✅ Free (MVP, $0/month)
- ✅ Simple (3-click invoice generation)
- ✅ Professional (custom branding, PDF)
- ✅ Modern UI (Tailwind, shadcn/ui)
- ✅ Client portal (no login required)

---

## Design Principles

1. **Fast over Complete**
   - MVP ships in 2-3 weeks (not 6 months)
   - Core flow working > 100% feature parity

2. **Simple over Configurable**
   - One invoice template (not 10 variants)
   - Essential settings only (tax rate, currency)

3. **Professional over Playful**
   - Neutral colors (zinc, cyan)
   - Business tool aesthetic (not consumer app)

4. **Data-Dense over Whitespace**
   - Tables fit 10-15 rows (not 5)
   - Compact padding (information first)

5. **Boring over Clever**
   - Standard patterns (no reinventing)
   - Proven tech stack (Next.js, Supabase)

---

## Key Decisions & Rationale

**Why Next.js 15?**
- Full-stack in one framework (frontend + API)
- Free deployment (Vercel Hobby)
- React Server Components (fast, SEO-friendly)
- Expertise match (JS/TS familiar)

**Why Supabase?**
- Free tier (500MB database, 1GB storage)
- Auth built-in (no custom JWT logic)
- RLS (database-level security)
- Real-time (future: live invoice updates)

**Why React-PDF?**
- Pure JS (no Chromium, fast cold start)
- Customizable (React components)
- Free (no external API costs)

**Why No Payment Gateway?**
- Scope creep (adds 1-2 weeks)
- Compliance overhead (PCI-DSS)
- MVP focus (track payments manually)

**Why Token-Based Client Portal?**
- Clients don't need accounts (friction reduction)
- Secure (32-char hex, non-guessable)
- Simple (send link via WhatsApp/email)

---

## Risks & Mitigations

**Risk 1: Free tier limits exceeded**
- Mitigation: Monitor Vercel bandwidth (alert at 80GB/month)
- Fallback: Upgrade to Pro ($20/month) if needed

**Risk 2: PDF generation slow (cold starts)**
- Mitigation: Use React-PDF (fast) not Puppeteer (slow)
- Fallback: Generate PDF asynchronously, notify when ready

**Risk 3: RLS policies misconfigured (data leak)**
- Mitigation: Test with 2 users, verify isolation
- Rollback: Supabase has daily backups (7-day retention)

**Risk 4: Client token guessed (unauthorized access)**
- Mitigation: 128-bit entropy (infeasible to brute force)
- Rate limiting: 100 requests/hour per IP

---

## Project History

- **2026-10-02**: M04 Design (33 screens, design system)
- **2026-10-02**: M05 Architecture (database schema, API contracts, stack selection)
- **2026-10-02**: M06 Development (scaffold, harness files, implementation start)

---

**Reference Docs**:
- Requirements: `docs/specs/PRD.md`
- Technical Specs: `docs/specs/FSD.md`
- Design System: `docs/specs/DESIGN_SPEC.md`

**Last Updated**: 2026-10-02
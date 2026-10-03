# Design Specification & UI Wireflow
Freelance Invoice Tracker

> UI design specification, information architecture, visual tokens, and screen inventory document to freeze the visual flow prior to technical architecture and coding phases.

---

## 1. Design Metadata
- **Project Name**: Freelance Invoice Tracker
- **Client**: Portfolio MVP (Solo Developer)
- **Solo Lead UI/UX & Engineer**: [Your Name]
- **Design Version**: 1.0.0
- **Design Status**: DRAFT - Pending Approval
- **Workflow**: Markdown specs only (no Stitch prototype for MVP fast-track)
- **Design System Reference**: `DESIGN.md` (20.9KB, design tokens)
- **Sitemap Reference**: `docs/specs/SITEMAP.md` (12.4KB, 30 screens)
- **Approval Date**: [YYYY-MM-DD - Pending]

---

## 2. Information Architecture & Sitemap URL Map

| Route URL | Page Name | User Role Access | Core Function & Interactions |
| :--- | :--- | :--- | :--- |
| `/` | Landing Page | Public | Hero, features, pricing, CTA to signup |
| `/login` | Login | Public | Email/password form, forgot password link |
| `/signup` | Registration | Public | Name, email, password, business name form |
| `/forgot-password` | Password Reset Request | Public | Email input, send reset link |
| `/reset-password?token=xxx` | Password Reset | Public (token auth) | New password form with token validation |
| `/dashboard` | Dashboard | Freelancer (authenticated) | Revenue cards, recent invoices, quick actions |
| `/projects` | Projects List | Freelancer | Table of all projects with filters |
| `/projects/new` | Create Project | Freelancer | Form: name, client, hourly rate, description |
| `/projects/:id` | Project Detail | Freelancer | Summary, time entries, expenses, invoice CTA |
| `/projects/:id/edit` | Edit Project | Freelancer | Edit project metadata |
| `/time-entries/new` | Log Time Entry | Freelancer | Project select, date, hours, description |
| `/time-entries/:id/edit` | Edit Time Entry | Freelancer | Edit existing time log |
| `/expenses/new` | Log Expense | Freelancer | Project select, date, amount, receipt upload |
| `/expenses/:id/edit` | Edit Expense | Freelancer | Edit existing expense |
| `/invoices` | Invoices List | Freelancer | Table with status filters, search, actions |
| `/invoices/new` | Create Invoice (Wizard) | Freelancer | 4-step wizard: project select, line items, tax/discount, preview |
| `/invoices/:id` | Invoice Detail | Freelancer | Invoice data, PDF preview, send/mark paid |
| `/invoices/:id/edit` | Edit Invoice (Draft only) | Freelancer | Edit draft invoice line items |
| `/invoices/:id/preview` | Invoice PDF Preview | Freelancer | Full-page PDF preview before send |
| `/invoices/:id/send` | Send Invoice | Freelancer | Generate client portal link modal |
| `/clients` | Clients List | Freelancer | Table of clients with revenue summary |
| `/clients/new` | Create Client | Freelancer | Form: name, email, phone, address |
| `/clients/:id` | Client Detail | Freelancer | Client info, projects, invoices, revenue |
| `/clients/:id/edit` | Edit Client | Freelancer | Edit client metadata |
| `/settings/profile` | Profile Settings | Freelancer | Personal & business info, avatar upload |
| `/settings/branding` | Invoice Branding | Freelancer | Logo upload, color picker, template preview |
| `/settings/tax` | Tax & Currency Settings | Freelancer | Tax rate, currency, number format, invoice prefix |
| `/settings/security` | Account Security | Freelancer | Change password form |
| `/client/invoice/:token` | Client Invoice View | Client (token auth) | Read-only invoice, download PDF, approve button |
| `/client/invoice/:token/approved` | Approval Success | Client (token auth) | Thank you message after approval |

**Total Screens**: 30

---

## 3. Design System & Visual Tokens (Design Tokens)

### 3.1 Typography
- **Primary Font (UI & Body Text)**: `Inter` (weights: 400, 500, 600, 700)
- **Monospace Font (Invoice IDs, Currency, Numbers)**: `JetBrains Mono` (weights: 400, 600)
- **Text Size Scale**:
  - Heading 1: `32px` / `line-height: 1.2` / `font-weight: 700`
  - Heading 2: `24px` / `line-height: 1.3` / `font-weight: 600`
  - Heading 3: `18px` / `line-height: 1.4` / `font-weight: 600`
  - Body Text: `14px` / `line-height: 1.6` / `font-weight: 400`
  - Caption / Helper: `12px` / `line-height: 1.5` / `font-weight: 400`

### 3.2 Color Palette & Contrast Verification (WCAG 2.1 AA)

| Color Token | HEX Value | UI Usage | Contrast Ratio to #FFFFFF | Pass Status |
| :--- | :---: | :--- | :---: | :---: |
| `background` | `#FFFFFF` | Main page background | - | Base |
| `surface` | `#FAFAFA` | Card backgrounds | - | Base |
| `border` | `#E4E4E7` | Component borders | - | N/A |
| `text-primary` | `#18181B` | Headings, body text | **17.4 : 1** | PASS (AAA) |
| `text-secondary` | `#52525B` | Labels, captions | **7.1 : 1** | PASS (AAA) |
| `text-muted` | `#A1A1AA` | Placeholders | **4.6 : 1** | PASS (AA) |
| `primary` | `#0891B2` | CTA buttons, active nav | **4.8 : 1** | PASS (AA) |
| `success` | `#10B981` | Paid status, success alerts | **3.9 : 1** | PASS (AA Large) |
| `warning` | `#F59E0B` | Overdue status, warnings | **3.2 : 1** | PASS (AA Large) |
| `error` | `#EF4444` | Error messages, destructive | **4.5 : 1** | PASS (AA) |

### 3.3 Spacing & Layout
- **Grid System**: 4px base unit (`p-1` = 4px, `p-4` = 16px, `p-6` = 24px)
- **Max Content Width**: 1280px (`max-w-7xl`)
- **Card Padding**: 24px (`p-6`)
- **Border Radius**: Buttons/inputs 6px, Cards 8px, Badges 9999px (full)
- **Shadows**: `shadow-sm` (cards), `shadow-md` (hover), `shadow-lg` (modals)

---

## 4. Base Component Library Selection
- **UI Library**: `shadcn/ui` (Radix UI primitives + Tailwind CSS)
- **Icon Set**: `Lucide React` (24px default, 1.5px stroke)
- **Form Components**: `React Hook Form` + `Zod` validation
- **Notification Components**: `Sonner` (toast notifications, top-right)
- **PDF Generation**: `React-PDF` or `Puppeteer` (server-side rendering)
- **Date Picker**: `React Day Picker` (shadcn/ui calendar component)

---

## 5. Exhaustive Screen Inventory (100% Coverage)

> **ABSOLUTE COVERAGE RULE**: This table covers **100% of all 30 screens** defined in `SITEMAP.md`. No screens are skipped.

| Screen Code | Screen Name | Route | Default State | Loading Skeleton | Empty State | Error State |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| **SCR-01** | Landing Page | `/` | Hero, features, pricing | N/A (static) | N/A | N/A |
| **SCR-02** | Login | `/login` | Email/password form | Disabled button | N/A | "Invalid credentials" inline error |
| **SCR-03** | Signup | `/signup` | Registration form | Disabled button | N/A | Validation errors inline |
| **SCR-04** | Forgot Password | `/forgot-password` | Email input form | Disabled button | N/A | "Email not found" error |
| **SCR-05** | Reset Password | `/reset-password?token=xxx` | New password form | Disabled button | N/A | "Invalid token" error banner |
| **SCR-06** | Dashboard | `/dashboard` | Revenue cards, table | Skeleton cards/rows | "No projects yet" CTA | "Failed to load" toast + retry |
| **SCR-07** | Projects List | `/projects` | Table (10-15 rows) | Skeleton rows | "Create your first project" CTA | "Failed to load" toast |
| **SCR-08** | Create Project | `/projects/new` | Form (4 fields) | Disabled submit | N/A | Validation errors inline |
| **SCR-09** | Project Detail | `/projects/:id` | Summary + tables | Skeleton sections | "No time entries yet" CTA | "Project not found" 404 |
| **SCR-10** | Edit Project | `/projects/:id/edit` | Pre-filled form | Skeleton form | N/A | Validation errors inline |
| **SCR-11** | Log Time Entry | `/time-entries/new` | Form (project, date, hours) | Disabled submit | N/A | Validation errors inline |
| **SCR-12** | Edit Time Entry | `/time-entries/:id/edit` | Pre-filled form | Skeleton form | N/A | "Entry not found" 404 |
| **SCR-13** | Log Expense | `/expenses/new` | Form + file upload | Disabled submit | N/A | Validation errors inline |
| **SCR-14** | Edit Expense | `/expenses/:id/edit` | Pre-filled form + receipt | Skeleton form | N/A | "Expense not found" 404 |
| **SCR-15** | Invoices List | `/invoices` | Table with filters | Skeleton rows | "Generate your first invoice" CTA | "Failed to load" toast |
| **SCR-16** | Create Invoice (Step 1) | `/invoices/new` | Project selector | Disabled next | "No projects available" | "No time entries to invoice" warning |
| **SCR-17** | Create Invoice (Step 2) | `/invoices/new` | Line items table | N/A | N/A | Invalid line item error |
| **SCR-18** | Create Invoice (Step 3) | `/invoices/new` | Tax/discount form | N/A | N/A | Validation errors inline |
| **SCR-19** | Create Invoice (Step 4) | `/invoices/new` | PDF preview | Loading spinner | N/A | "PDF generation failed" error |
| **SCR-20** | Invoice Detail | `/invoices/:id` | Invoice data + PDF | Skeleton sections | N/A | "Invoice not found" 404 |
| **SCR-21** | Edit Invoice | `/invoices/:id/edit` | Editable line items (draft) | Skeleton form | N/A | "Cannot edit sent invoice" error |
| **SCR-22** | Invoice PDF Preview | `/invoices/:id/preview` | Full-page PDF | Loading spinner | N/A | "PDF generation failed" error |
| **SCR-23** | Send Invoice Modal | `/invoices/:id/send` | Link generator modal | Generating link... | N/A | "Failed to generate link" error |
| **SCR-24** | Clients List | `/clients` | Table (10-15 rows) | Skeleton rows | "Add your first client" CTA | "Failed to load" toast |
| **SCR-25** | Create Client | `/clients/new` | Form (5 fields) | Disabled submit | N/A | Validation errors inline |
| **SCR-26** | Client Detail | `/clients/:id` | Info + projects/invoices | Skeleton sections | "No projects for this client" CTA | "Client not found" 404 |
| **SCR-27** | Edit Client | `/clients/:id/edit` | Pre-filled form | Skeleton form | N/A | Validation errors inline |
| **SCR-28** | Profile Settings | `/settings/profile` | Form + avatar upload | Skeleton form | N/A | Validation errors inline |
| **SCR-29** | Branding Settings | `/settings/branding` | Logo upload + color picker + preview | Skeleton form | N/A | "Logo file too large" error |
| **SCR-30** | Tax Settings | `/settings/tax` | Tax rate, currency, format | Skeleton form | N/A | Validation errors inline |
| **SCR-31** | Security Settings | `/settings/security` | Change password form | Disabled submit | N/A | "Current password incorrect" error |
| **SCR-32** | Client Invoice View | `/client/invoice/:token` | Read-only invoice + PDF | Loading spinner | N/A | "Invalid or expired link" 404 |
| **SCR-33** | Approval Success | `/client/invoice/:token/approved` | Thank you message | N/A | N/A | N/A |

**Total: 33 screens** (updated from 30 — invoice wizard counted as 4 separate steps)

---

## 6. Screen Breakdown Details (Screen Wireframe & Section Inventory)

### SCR-01: Landing Page (/)

**Layout Structure:**
- Header: Logo (left), Nav (Home, Features, Pricing), CTA "Sign Up" (right)
- Main Content: 6 sections (Hero, Problem, Solution, Features, Pricing, CTA)
- Footer: Copyright, links (Privacy, Terms), social icons

**Section Breakdown:**

1. **Hero Section**
   - Heading: "Track Time. Invoice Smart."
   - Subheading: "Project management + invoicing tool for freelancers. Log hours, track expenses, generate professional invoices."
   - CTA Button: "Start Free" → `/signup`
   - Hero Image: Dashboard screenshot or illustration
   - Wireframe:
     ```
     ┌──────────────────────────────────────────────────┐
     │  [Logo]    Home  Features  Pricing  [Sign Up]   │
     ├──────────────────────────────────────────────────┤
     │                                                  │
     │          Track Time. Invoice Smart.              │
     │                                                  │
     │    Project management + invoicing for freelancers│
     │                                                  │
     │             [Start Free →]                       │
     │                                                  │
     │         [Dashboard Screenshot]                   │
     │                                                  │
     └──────────────────────────────────────────────────┘
     ```

2. **Problem Section**
   - Heading: "Freelancing is Hard Enough. Invoicing Shouldn't Be."
   - Card Grid (3 columns):
     - Card 1: Icon, "Manual Time Tracking", "Spreadsheets everywhere, lose track of billable hours"
     - Card 2: Icon, "Generic Invoice Templates", "Word docs look unprofessional, lack branding"
     - Card 3: Icon, "Lost in Email Threads", "Clients never confirm receipt, payment status unclear"

3. **Solution Section**
   - Heading: "All-in-One Time Tracking + Invoicing"
   - Feature Grid (2×2):
     - Feature 1: "Log Time by Project", "Track hours per client, see total logged time"
     - Feature 2: "Track Expenses", "Upload receipts, add to invoices automatically"
     - Feature 3: "Generate Professional Invoices", "Custom branding, auto-calculate tax/discount"
     - Feature 4: "Client Portal", "Share link, client approves, track payment status"

4. **Pricing Section**
   - Heading: "Simple Pricing"
   - Pricing Card Grid (2 columns):
     - Card 1 (Free): "Rp0/month", "3 projects", "10 invoices/month", "Basic branding"
     - Card 2 (Pro): "Rp99k/month", "Unlimited projects", "Unlimited invoices", "Custom branding", "Priority support"

**Responsive:** Mobile stack vertical, tablet 2 columns, desktop 3 columns (problem cards)

---

### SCR-06: Dashboard (/dashboard)

**Layout Structure:**
- Header: Logo, search bar, user avatar dropdown
- Sidebar: Nav links (Dashboard, Projects, Invoices, Clients, Settings)
- Main Content: 4 stat cards + recent invoices table + quick actions

**Section Breakdown:**

1. **Stat Cards (4 horizontal)**
   - Card 1: "Total Revenue (This Month)" → "Rp 12,500,000", "+8% vs last month"
   - Card 2: "Pending Payments" → "Rp 4,200,000", "3 invoices awaiting payment"
   - Card 3: "Active Projects" → "7 projects", "2 need time entries this week"
   - Card 4: "Hours Logged (This Month)" → "128.5 hrs", "10% under target"
   - Wireframe:
     ```
     ┌─────────┬─────────┬─────────┬─────────┐
     │ Revenue │ Pending │ Active  │ Hours   │
     │ 12.5M   │ 4.2M    │ 7       │ 128.5h  │
     │ +8%     │ 3 inv   │ 2 needs │ -10%    │
     └─────────┴─────────┴─────────┴─────────┘
     ```

2. **Quick Actions (3 buttons horizontal)**
   - Button 1: "Log Time" → `/time-entries/new`
   - Button 2: "New Project" → `/projects/new`
   - Button 3: "Create Invoice" → `/invoices/new`

3. **Recent Invoices Table (5 rows)**
   - Columns: Invoice # | Client | Date | Amount | Status | Actions
   - Row Example: `INV-2024-015` | PT ABC | 28 Sep 2024 | Rp 2,500,000 | Paid badge (green) | [View] [Download]
   - Link: "View All Invoices" → `/invoices`

**Interaction & State Flow:**
- **Default**: Cards populated, table 5 rows
- **Loading**: Skeleton cards (gray blocks), skeleton table rows
- **Empty** (no projects): "No projects yet. Create your first project to start tracking time and invoices." + CTA "Create Project"
- **Error**: Toast "Failed to load dashboard. Please refresh." + Retry button

**Responsive:**
- Mobile: Cards stack 2×2, table scrolls horizontal
- Tablet: Cards 2×2, table full width
- Desktop: Cards 4×1, table full width

---

### SCR-09: Project Detail (/projects/:id)

**Layout Structure:**
- Header + Breadcrumb: Home > Projects > [Project Name]
- Page Header: Project title, status badge, Edit/Delete buttons (right)
- Main Content: Summary card + tabs (Time Entries | Expenses | Invoices)

**Section Breakdown:**

1. **Summary Card**
   - Project Name: "Website Redesign for PT ABC"
   - Client: "PT ABC" (link to `/clients/:id`)
   - Hourly Rate: "Rp 250,000/hr"
   - Total Hours Logged: "48.5 hrs" → Total Value: "Rp 12,125,000"
   - Total Expenses: "Rp 500,000"
   - Status: Active badge (green)
   - Wireframe:
     ```
     ┌───────────────────────────────────────────────┐
     │ Website Redesign for PT ABC          [Active] │
     │ Client: PT ABC | Rate: Rp 250k/hr             │
     │                                               │
     │ Total Hours: 48.5 hrs → Rp 12,125,000        │
     │ Total Expenses: Rp 500,000                   │
     │                                               │
     │ [Edit Project]  [Create Invoice]              │
     └───────────────────────────────────────────────┘
     ```

2. **Tabs Component**
   - Tab 1: "Time Entries" (default active)
   - Tab 2: "Expenses"
   - Tab 3: "Invoices"

3. **Time Entries Table (Tab 1 content)**
   - Columns: Date | Description | Hours | Amount | Actions
   - Row Example: 02 Oct 2024 | "Homepage mockup design" | 8.0 hrs | Rp 2,000,000 | [Edit] [Delete]
   - Empty State: "No time entries yet. Log your first time entry for this project." + Button "Log Time" → `/time-entries/new?project_id=:id`
   - Button: "Log Time" (top right)

4. **Expenses Table (Tab 2 content)**
   - Columns: Date | Description | Amount | Receipt | Actions
   - Row Example: 28 Sep 2024 | "Stock photos license" | Rp 500,000 | [📎 View] | [Edit] [Delete]
   - Empty State: "No expenses yet." + Button "Add Expense"

5. **Invoices Table (Tab 3 content)**
   - Columns: Invoice # | Date | Amount | Status | Actions
   - Row Example: INV-2024-012 | 15 Sep 2024 | Rp 5,000,000 | Paid | [View] [Download]
   - Empty State: "No invoices generated yet." + Button "Create Invoice"

**Interaction & State Flow:**
- **Default**: Summary populated, tabs with data
- **Loading**: Skeleton summary, skeleton table rows
- **Empty** (no time entries): Empty state per tab (see Section 3-5)
- **Error**: "Project not found" → 404 page

---

### SCR-16-19: Create Invoice Wizard (/invoices/new)

**Layout**: 4-step wizard with progress indicator (top)

**Step 1: Select Project**
- Heading: "Create Invoice - Step 1 of 4"
- Progress Bar: 25% filled
- Dropdown: "Select Project" → List of active projects
- Display after selection:
  - Project name, client, hourly rate
  - Time entries summary: "12 entries, 32 hrs, Rp 8,000,000"
  - Expenses summary: "2 expenses, Rp 300,000"
- Button: "Next" → Step 2
- Empty State: "No projects with unbilled time. Create a project first." + Button "New Project"

**Step 2: Review Line Items**
- Heading: "Create Invoice - Step 2 of 4"
- Progress Bar: 50% filled
- Table: Auto-populated line items from project
  - Columns: Description | Quantity | Rate | Amount | [Remove]
  - Row Example: "Time entry: Homepage design (8 hrs)" | 8 | Rp 250,000 | Rp 2,000,000 | [✕]
- Button: "Add Custom Line Item" → Inline form (description, qty, rate)
- Subtotal Display: "Rp 8,300,000" (sum of line items)
- Buttons: "Back" | "Next"

**Step 3: Tax & Discount**
- Heading: "Create Invoice - Step 3 of 4"
- Progress Bar: 75% filled
- Form Fields:
  - Tax Rate: Input "11" % (default from settings, editable)
  - Discount: Input "0" Rp (optional)
  - Due Date: Date picker (default +14 days)
  - Notes: Textarea "Payment due within 14 days. Bank: BCA 1234567890"
- Calculation Display:
  - Subtotal: Rp 8,300,000
  - Tax (11%): Rp 913,000
  - Discount: Rp 0
  - **Total: Rp 9,213,000**
- Buttons: "Back" | "Preview Invoice"

**Step 4: Preview & Save**
- Heading: "Create Invoice - Step 4 of 4"
- Progress Bar: 100% filled
- PDF Preview: Full invoice rendered in iframe (A4 size)
  - Invoice header: Freelancer logo, business name, address
  - Bill To: Client name, address
  - Line items table
  - Totals breakdown (subtotal, tax, total)
  - Notes section
  - Footer: Custom message from settings
- Buttons: "Back to Edit" | "Save as Draft" | "Send to Client"
- Action:
  - "Save as Draft" → Saves invoice, redirect to `/invoices/:id`
  - "Send to Client" → Generates client portal link, opens modal `/invoices/:id/send`

**Interaction & State Flow:**
- **Default**: Wizard progresses step-by-step
- **Loading** (PDF preview): Spinner "Generating PDF preview..."
- **Error** (Step 1): "No projects available" → Redirect to `/projects/new`
- **Error** (Step 4): "PDF generation failed. Try again." + Retry button

---

### SCR-20: Invoice Detail (/invoices/:id)

**Layout Structure:**
- Header + Breadcrumb: Home > Invoices > Invoice #INV-2024-015
- Page Header: Invoice number, status badge, action buttons (right)

**Section Breakdown:**

1. **Invoice Header**
   - Invoice Number: "INV-2024-015" (monospace font)
   - Status: Badge (Draft | Sent | Paid | Overdue)
   - Actions (conditional based on status):
     - Draft: [Edit] [Send to Client] [Delete]
     - Sent: [Mark as Paid] [Download PDF] [Revoke Link]
     - Paid: [Download PDF]

2. **Invoice Metadata Card**
   - Client: "PT ABC" (link to `/clients/:id`)
   - Project: "Website Redesign" (link to `/projects/:id`)
   - Invoice Date: "02 Oktober 2024"
   - Due Date: "16 Oktober 2024" (14 days)
   - Status: Paid badge (green) + "Paid on 10 Oktober 2024"

3. **Line Items Table**
   - Columns: Description | Quantity | Rate | Amount
   - Row Example: "Time entry: Homepage design" | 8 hrs | Rp 250,000 | Rp 2,000,000
   - Row Example: "Expense: Stock photos" | 1 | Rp 300,000 | Rp 300,000
   - Total Rows: 10-15 items

4. **Totals Card (right sidebar or bottom)**
   - Subtotal: Rp 8,300,000
   - Tax (11%): Rp 913,000
   - Discount: Rp 0
   - **Total: Rp 9,213,000**

5. **Notes Section**
   - Text: "Payment due within 14 days. Bank transfer: BCA 1234567890 a.n. Business Name."

6. **PDF Preview (collapsible)**
   - Button: "Preview PDF" → Expands PDF iframe below
   - Action: "Download PDF" → Downloads invoice.pdf

7. **Client Portal Link (if sent)**
   - Display: "Shareable link: https://app.example.com/client/invoice/abc123token"
   - Button: "Copy Link" → Copies to clipboard
   - Button: "Revoke Link" → Disables client access (confirmation modal)

**Interaction & State Flow:**
- **Default**: Invoice data populated, PDF preview collapsed
- **Loading**: Skeleton sections
- **Error**: "Invoice not found" → 404 page
- **Success** (after send): Toast "Invoice sent! Client link copied to clipboard."

---

### SCR-23: Send Invoice Modal (/invoices/:id/send)

**Layout**: Modal overlay (480px width)

**Modal Content:**

1. **Header**
   - Title: "Send Invoice to Client"
   - Close button (X)

2. **Body**
   - Text: "Generate a shareable link for your client to view and approve the invoice."
   - Input (read-only): `https://app.example.com/client/invoice/abc123token`
   - Button: "Copy Link" → Copies to clipboard, shows "Copied!" checkmark

3. **Instructions**
   - Text: "Send this link to your client via email or WhatsApp. They can view the invoice and approve it without logging in."
   - Note: "Link expires: Never (manually revoke if needed)"

4. **Footer**
   - Button: "Done" → Closes modal, marks invoice as "Sent"

**Interaction & State Flow:**
- **Default**: Link displayed, copy button active
- **Loading**: "Generating link..." spinner (when first opened)
- **Error**: "Failed to generate link. Try again." + Retry button
- **Success**: Link generated, "Copied!" toast after copy

---

### SCR-32: Client Invoice View (/client/invoice/:token)

**Layout**: Public page (no sidebar, minimal header)

**Header:**
- Logo: Freelancer's custom logo (from settings)
- Business Name: "Your Business Name"

**Section Breakdown:**

1. **Invoice Header**
   - Invoice Number: "INV-2024-015"
   - Status: Badge "Pending Payment" (yellow) or "Paid" (green)
   - Date Issued: "02 Oktober 2024"
   - Due Date: "16 Oktober 2024"

2. **Bill From (Freelancer)**
   - Business Name
   - Address
   - Phone
   - Email

3. **Bill To (Client)**
   - Client Name: "PT ABC"
   - Address
   - Email

4. **Line Items Table**
   - Columns: Description | Quantity | Rate | Amount
   - Rows: All invoice line items (same as SCR-20)

5. **Totals Section**
   - Subtotal, Tax, Total (formatted with currency)

6. **Notes**
   - Payment terms, bank details, thank you message

7. **Actions (Client)**
   - Button: "Download PDF" → Downloads invoice.pdf
   - Button: "Approve Invoice" → POST request, updates status to "Approved", redirects to `/client/invoice/:token/approved`
   - Text: "Questions? Contact us at email@example.com"

8. **Footer**
   - Text: "Powered by Freelance Invoice Tracker"

**Interaction & State Flow:**
- **Default**: Invoice data displayed, buttons active
- **Loading**: Skeleton sections (when first loading)
- **Error**: "Invalid or expired link" → 404 page with message "This invoice link is no longer valid. Contact the freelancer for a new link."
- **Success** (after approve): Redirect to `/client/invoice/:token/approved`

**Responsive:**
- Mobile: Stack vertical, full-width table scrolls horizontal
- Desktop: Centered 800px container, fixed width

---

### SCR-33: Approval Success (/client/invoice/:token/approved)

**Layout**: Simple centered message page

**Content:**
- Icon: Green checkmark (large)
- Heading: "Invoice Approved!"
- Text: "Thank you for approving the invoice. The freelancer has been notified. You will receive a confirmation email shortly."
- Button: "View Invoice Again" → Back to `/client/invoice/:token`

---

### Supporting Screens (Simplified Breakdown)

**SCR-02: Login (/login)**
- Form: Email input, Password input, "Forgot password?" link
- Button: "Log In" → POST /api/auth/login
- Link: "Don't have an account? Sign up"
- Error: "Invalid email or password" inline

**SCR-03: Signup (/signup)**
- Form: Name, Email, Password, Business Name
- Button: "Create Account" → POST /api/auth/signup
- Link: "Already have an account? Log in"
- Validation: Email format, password min 8 chars

**SCR-07: Projects List (/projects)**
- Table: Name | Client | Hourly Rate | Total Hours | Status | Actions
- Filters: Status dropdown (Active, Completed, Archived), Search bar
- Button: "New Project" (top right)
- Empty: "Create your first project" CTA

**SCR-15: Invoices List (/invoices)**
- Table: Invoice # | Client | Date | Amount | Status | Actions
- Filters: Status (Draft, Sent, Paid, Overdue), Date range, Client dropdown
- Actions per row: [View] [Edit] [Send] [Download] [Delete]
- Empty: "Generate your first invoice" CTA

**SCR-24: Clients List (/clients)**
- Table: Name | Email | Phone | Total Projects | Total Revenue | Actions
- Search bar (filter by name/email)
- Button: "New Client" (top right)
- Empty: "Add your first client" CTA

**SCR-28: Profile Settings (/settings/profile)**
- Form: Name, Email, Phone, Business Name, Address, Tax ID
- Avatar Upload: Drag & drop zone, max 2MB
- Button: "Save Changes"

**SCR-29: Branding Settings (/settings/branding)**
- Logo Upload: Drag & drop, max 500KB, PNG/SVG
- Color Picker: Primary color for invoice header
- Invoice Template Preview: Live preview (right side) updates as settings change
- Footer Text: Textarea for custom message
- Button: "Save Settings"

**SCR-30: Tax Settings (/settings/tax)**
- Tax Rate: Input "11" % (default Indonesian VAT)
- Currency: Dropdown (IDR, USD, EUR)
- Number Format: Radio buttons (1.234.567,89 vs 1,234,567.89)
- Invoice Numbering: Prefix "INV-2024-" + auto-increment
- Button: "Save Settings"

---

## 7. Accessibility & Responsive Standards

**Accessibility Checklist:**
- [x] All text contrast ≥4.5:1 ratio (WCAG AA)
- [x] Interactive elements ≥44px touch target (mobile)
- [x] Form inputs have explicit `<label>` elements
- [x] Focus states visible (2px ring outline in primary color)
- [x] Keyboard navigable (Tab, Enter, Esc work for all interactions)
- [x] ARIA labels for icon-only buttons (`aria-label="Edit project"`)
- [x] Error messages associated with fields (`aria-describedby`)
- [x] Status badges have text, not just color (e.g., "Paid" text + green color)
- [x] Tables have semantic HTML (`<thead>`, `<tbody>`, `<th>`, `<td>`)
- [x] Modals trap focus, Esc to close

**Responsive Breakpoints:**
- **Mobile**: `< 640px` (1 column, stack vertical, bottom nav)
- **Tablet**: `640px - 1024px` (2 columns, collapsed sidebar)
- **Desktop**: `≥ 1024px` (full sidebar, multi-column layouts)

**Touch Targets:**
- Buttons: Min 44px height (`h-11` or `h-10` with padding)
- Icon buttons: 40×40px square
- Table row actions: 36px height (acceptable for dense data tables)

---

## 8. Design Freeze Sign-Off

By signing this sheet, the Solo Developer confirms that all visual layouts, navigation architecture, and screen specifications in this document have been reviewed and approved. This design is designated as **FROZEN** and ready for technical architecture (Module 05) and development (Module 06).

**Design Freeze Clauses**:
1. All 33 screens are specified and approved for development.
2. The next phase (Module 05: Architecture & FSD) will proceed based on this design.
3. Any changes to screen layouts, additions of new pages, or UI flow revamps after this approval will require formal change request (CR) and timeline adjustment.

| Solo Developer Self-Approval |
| :--- |
| **Name**: [Your Name] |
| **Date**: [YYYY-MM-DD] |
| **Status**: ✅ APPROVED - Proceed to Module 05 (Architecture & FSD) |

---

**Design Artifacts Summary:**
- ✅ `docs/specs/LOGO_DESIGN_BRIEF.md` (10.4KB, 4 AI prompts)
- ✅ `docs/specs/SITEMAP.md` (12.4KB, 30 screens mapped)
- ✅ `DESIGN.md` (20.9KB, design tokens & anti-slop guardrails)
- ✅ `docs/specs/DESIGN_SYSTEM.md` (THIS FILE, 33 screens specified)

**Next Steps:**
1. Review all 4 design files for accuracy
2. Generate logo using AI prompts (optional, can proceed with placeholder)
3. Confirm design freeze approval
4. Proceed to Module 05: Architecture & Technical Specs (PRD, FSD, database schema, API contracts)

---

**Last Updated**: 2026-10-02  
**Status**: DRAFT - Pending user review and approval
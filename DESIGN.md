# Design System Specification - Freelance Invoice Tracker

> Foundational design system reference for AI agent consumption during development (Module 06). Maintains visual consistency and prevents generic interface generation ("AI Slop").

---

## 1. Design Philosophy & Anti-Slop Directives

**Core Principles:**

1. **Flat & Structured First**:
   - DO NOT use heavy drop shadows, floating cards, or glassmorphism.
   - Use flat 1px neutral borders (`border border-zinc-200 dark:border-zinc-800`) to separate containers.
   
2. **Neutral Monochrome + Single Accent Color**:
   - DO NOT use neon gradients, purple/pink gradients, or multiple brand colors.
   - 90% neutral gray (Zinc scale). 1 primary accent: **Cyan-600** (`#0891B2`) for CTAs, active states, invoice branding.
   
3. **Real Data & Domain Context**:
   - DO NOT use Lorem Ipsum or generic placeholder text.
   - Use real freelance/invoice terminology: "Time logged", "Invoice #INV-2024-001", "Rp 2,500,000", "Pending payment".
   - Currency formats: Support Rupiah (Rp), USD ($), EUR (€) with proper thousand separators.
   - Date format: Indonesian context uses DD/MM/YYYY or "2 Oktober 2024".
   
4. **Information Density > Whitespace**:
   - Business tool, not marketing landing page. Tables should fit 10-15 rows per screen without scrolling.
   - Compact padding: `py-2 px-3` for table cells, `py-3 px-4` for form fields.
   
5. **Accessibility Compliance (WCAG 2.1 AA)**:
   - Text contrast ratio ≥4.5:1 against background.
   - All interactive elements ≥44px touch target (mobile).
   - Keyboard navigable: visible focus states, logical tab order.

---

## 2. Color Palette & Semantic Tokens

### 2.1 Light Mode (Default)

**Backgrounds:**
- Primary Background: `#FFFFFF`
- Surface / Card Background: `#FAFAFA` (Zinc-50)
- Hover Surface: `#F4F4F5` (Zinc-100)
- Border: `#E4E4E7` (Zinc-200)

**Text:**
- Primary Text (Headings, Body): `#18181B` (Zinc-900) — Contrast 17.4:1 (AAA)
- Secondary Text (Labels, Captions): `#52525B` (Zinc-600) — Contrast 7.1:1 (AAA)
- Muted Text (Placeholders, Disabled): `#A1A1AA` (Zinc-400) — Contrast 4.6:1 (AA)

### 2.2 Dark Mode (Optional - Phase 2)

**Backgrounds:**
- Primary Background: `#09090B` (Zinc-950)
- Surface / Card Background: `#18181B` (Zinc-900)
- Hover Surface: `#27272A` (Zinc-800)
- Border: `#3F3F46` (Zinc-700)

**Text:**
- Primary Text: `#FAFAFA` (Zinc-50)
- Secondary Text: `#D4D4D8` (Zinc-300)
- Muted Text: `#71717A` (Zinc-500)

### 2.3 Brand & Semantic Colors

**Brand Primary (Accent):**
- `#0891B2` (Cyan-600) — Primary CTA buttons, active nav, invoice accent color
- `#0E7490` (Cyan-700) — Hover state for primary buttons
- `#CFFAFE` (Cyan-100) — Subtle background for info alerts, invoice badges

**Semantic States:**
- Success: `#10B981` (Emerald-500) — Paid invoices, success messages
- Warning: `#F59E0B` (Amber-500) — Overdue invoices, pending actions
- Error: `#EF4444` (Red-500) — Validation errors, failed actions
- Info: `#3B82F6` (Blue-500) — Draft status, informational alerts

**Status Badge Colors (Invoice & Project):**
- Draft: `bg-zinc-100 text-zinc-700 border-zinc-300`
- Sent: `bg-blue-50 text-blue-700 border-blue-200`
- Approved: `bg-cyan-50 text-cyan-700 border-cyan-200`
- Paid: `bg-emerald-50 text-emerald-700 border-emerald-200`
- Overdue: `bg-red-50 text-red-700 border-red-200`

---

## 3. Typography System

**Font Families:**
- **UI/Body**: Inter (weights: 400, 500, 600, 700)
  - Load from Google Fonts: `@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');`
- **Monospace (Invoice IDs, Numbers, Currency)**: JetBrains Mono (weights: 400, 600)
  - Load from Google Fonts: `@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&display=swap');`

**Type Scale:**
- `h1`: 32px / 700 (bold) / -0.02em letter-spacing / 1.2 line-height
  - Usage: Page titles ("Projects", "Invoices")
- `h2`: 24px / 600 (semibold) / -0.01em / 1.3
  - Usage: Section headings ("Time Entries", "Invoice Details")
- `h3`: 18px / 600 (semibold) / 0 / 1.4
  - Usage: Card titles, modal headers
- `body`: 14px / 400 (regular) / 0 / 1.6
  - Usage: Table cells, form labels, body text
- `small`: 12px / 400 (regular) / 0 / 1.5
  - Usage: Captions, helper text, timestamps ("Created 2 hours ago")

**Number Formatting (Financial Data):**
- Font: JetBrains Mono 14px / 500
- Alignment: Right-aligned in tables
- Format: 
  - Rupiah: `Rp 2.500.000` (period for thousands, no decimal for whole numbers)
  - USD: `$2,500.00` (comma for thousands, decimal for cents)
  - Hours: `12.5 hrs` (decimal point, 1 decimal place)

---

## 4. Component Shapes & Spacing

**Corner Radius:**
- Buttons: `6px` (`rounded-md`)
- Input Fields: `6px` (`rounded-md`)
- Cards: `8px` (`rounded-lg`)
- Modals: `12px` (`rounded-xl`)
- Status Badges: `9999px` (`rounded-full`)
- Avatar: `9999px` (circular)

**Spacing Scale (4px Grid):**
- `xs`: 4px (`p-1`, `gap-1`)
- `sm`: 8px (`p-2`, `gap-2`)
- `md`: 12px (`p-3`, `gap-3`)
- `base`: 16px (`p-4`, `gap-4`)
- `lg`: 24px (`p-6`, `gap-6`)
- `xl`: 32px (`p-8`, `gap-8`)

**Layout Containers:**
- Max content width: `1280px` (`max-w-7xl`)
- Page padding: `px-4` mobile, `px-6` tablet, `px-8` desktop
- Card padding: `p-6` (24px)
- Section spacing: `gap-6` between cards, `gap-8` between major sections

**Mobile Breakpoints:**
- Mobile: `< 640px` (1 column, bottom nav)
- Tablet: `640px - 1024px` (2 columns, collapsed sidebar)
- Desktop: `>= 1024px` (full sidebar, multi-column layouts)

---

## 5. Shadows & Borders (Subtle Depth)

**Shadows (Minimal Usage):**
- Card Default: `0 1px 3px rgba(0, 0, 0, 0.1)` (`shadow-sm`)
- Card Hover: `0 4px 6px rgba(0, 0, 0, 0.1)` (`shadow-md`)
- Modal/Dropdown: `0 10px 15px rgba(0, 0, 0, 0.1)` (`shadow-lg`)

**FORBIDDEN:**
- `shadow-xl`, `shadow-2xl` (too dramatic for business tool)
- Colored shadows (`shadow-cyan-500/50`)
- Inner shadows (neumorphism)

**Borders (Primary Separation Method):**
- Default: `1px solid #E4E4E7` (Zinc-200)
- Focus State: `2px solid #0891B2` (Cyan-600) with `ring-2 ring-offset-2`
- Table Dividers: `border-t border-zinc-200` (1px top border per row)
- Input Fields: `border border-zinc-300` default, `border-cyan-500` focus

---

## 6. Component Library (shadcn/ui Base)

**Use shadcn/ui primitives (Radix UI)** for accessibility, customize with design tokens above.

### 6.1 Buttons

**Variants:**
1. **Primary (CTA):**
   - `bg-cyan-600 text-white hover:bg-cyan-700`
   - Height: 40px (`h-10`)
   - Padding: `px-4`
   - Font: 14px / 600 (semibold)
   - Usage: "Create Invoice", "Save Project", "Send to Client"

2. **Secondary (Outline):**
   - `border border-zinc-300 text-zinc-700 hover:bg-zinc-50`
   - Same dimensions as Primary
   - Usage: "Cancel", "Edit", "View Details"

3. **Destructive (Danger):**
   - `bg-red-600 text-white hover:bg-red-700`
   - Usage: "Delete Project", "Revoke Invoice Link"

4. **Ghost (Minimal):**
   - `text-zinc-700 hover:bg-zinc-100`
   - Usage: Table action icons (Edit, Delete), dropdown menu items

**Icon Buttons:**
- Size: 40x40px (square, `h-10 w-10`)
- Padding: `p-2` (icon 24px inside)
- Usage: Edit icon, Delete icon, More actions (three dots)

### 6.2 Form Inputs

**Text Input:**
```html
<label class="block text-sm font-medium text-zinc-700 mb-1">Project Name</label>
<input 
  type="text" 
  class="w-full h-10 px-3 border border-zinc-300 rounded-md focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500"
  placeholder="Enter project name"
/>
<p class="mt-1 text-xs text-zinc-500">This will appear on invoices sent to clients.</p>
```

**Textarea:**
- Min height: 80px (3-4 lines)
- Resize: vertical only (`resize-y`)
- Usage: Project description, invoice notes

**Select Dropdown:**
- Custom styled with chevron icon
- Max height dropdown: 240px with scroll
- Option padding: `py-2 px-3`

**Date Picker:**
- Calendar icon on right
- Format: DD/MM/YYYY (Indonesian) or MM/DD/YYYY (US)
- Range picker for invoice filtering (From Date → To Date)

**File Upload (Logo, Receipt):**
- Drag & drop zone: `border-2 border-dashed border-zinc-300`
- Max size display: "Max 500KB, PNG/JPG/SVG"
- Preview thumbnail after upload (48x48px)

### 6.3 Tables (Data-Dense)

**Structure:**
```html
<table class="w-full">
  <thead class="bg-zinc-50 border-b border-zinc-200">
    <tr>
      <th class="py-3 px-4 text-left text-xs font-semibold text-zinc-700 uppercase tracking-wide">
        Invoice #
      </th>
      <!-- More headers -->
    </tr>
  </thead>
  <tbody class="divide-y divide-zinc-200">
    <tr class="hover:bg-zinc-50">
      <td class="py-3 px-4 text-sm font-mono text-zinc-900">INV-2024-001</td>
      <!-- More cells -->
    </tr>
  </tbody>
</table>
```

**Features:**
- Sticky header (if >15 rows)
- Zebra striping: Optional, use `even:bg-zinc-50` (subtle)
- Sortable columns: Chevron icon in header (up/down)
- Row actions: Right-aligned column with icon buttons (Edit, Delete, More)
- Pagination: Bottom center, "1-10 of 45" with Prev/Next buttons

**Responsive:**
- Mobile (<640px): Stack cards instead of table (each row = card with vertical labels)

### 6.4 Cards

**Default Card:**
```html
<div class="bg-white border border-zinc-200 rounded-lg p-6 shadow-sm">
  <h3 class="text-lg font-semibold text-zinc-900 mb-4">Project Summary</h3>
  <!-- Card content -->
</div>
```

**Stat Card (Dashboard):**
```html
<div class="bg-white border border-zinc-200 rounded-lg p-6">
  <p class="text-xs font-medium text-zinc-500 uppercase tracking-wide">Total Revenue</p>
  <p class="mt-2 text-3xl font-bold text-zinc-900">Rp 45,000,000</p>
  <p class="mt-1 text-sm text-emerald-600">+12% from last month</p>
</div>
```

### 6.5 Status Badges

**Size:** `px-2 py-1` (compact), `text-xs font-medium`, `rounded-full`, `border`

**Examples:**
- Draft: `bg-zinc-100 text-zinc-700 border-zinc-300`
- Sent: `bg-blue-50 text-blue-700 border-blue-200`
- Paid: `bg-emerald-50 text-emerald-700 border-emerald-200`

### 6.6 Modals & Dialogs

**Overlay:** `bg-black/50` (50% opacity backdrop)

**Dialog:**
- Max width: 480px (small), 640px (medium), 896px (large)
- Padding: `p-6`
- Header: `text-lg font-semibold text-zinc-900 mb-4`
- Footer: Button group (Cancel left, Primary right)

**Usage:**
- Confirm delete: Small modal
- Create invoice wizard: Large modal with steps
- Send invoice: Medium modal with link preview

### 6.7 Toasts / Alerts

**Position:** Top-right corner, stack vertically

**Types:**
- Success: `bg-emerald-50 border-l-4 border-emerald-500 text-emerald-800`
- Error: `bg-red-50 border-l-4 border-red-500 text-red-800`
- Info: `bg-blue-50 border-l-4 border-blue-500 text-blue-800`

**Auto-dismiss:** 5 seconds (success/info), manual dismiss (error)

---

## 7. Layout Patterns

### 7.1 Dashboard Layout

**Structure:**
```
┌─────────────────────────────────────────────┐
│ Header (Logo, Nav, User Menu)              │
├──────┬──────────────────────────────────────┤
│      │  Main Content                        │
│ Side │  ┌────────┬────────┬────────┐       │
│ bar  │  │ Stat   │ Stat   │ Stat   │       │
│      │  │ Card 1 │ Card 2 │ Card 3 │       │
│ Nav  │  └────────┴────────┴────────┘       │
│      │                                      │
│      │  ┌───────────────────────────────┐  │
│      │  │ Recent Invoices Table         │  │
│      │  └───────────────────────────────┘  │
└──────┴──────────────────────────────────────┘
```

**Sidebar:**
- Width: 240px (desktop), collapsed 64px (tablet), hidden (mobile → bottom nav)
- Nav items: Icon + label, active state (`bg-cyan-50 text-cyan-700 border-l-2 border-cyan-600`)

**Header:**
- Height: 64px
- Shadow: `shadow-sm` (1px bottom border alternative)

### 7.2 List View (Projects, Invoices, Clients)

**Structure:**
```
Page Title + New Button (right)
Filters (Status dropdown, Date range, Search bar)
Table (10-15 rows)
Pagination (bottom center)
```

### 7.3 Detail View (Project, Invoice, Client)

**Structure:**
```
Breadcrumb (Home > Projects > Project Name)
Page Header (Title, Status badge, Action buttons)
─────────────────────────────────────────────
Summary Card (Key metrics: Total hours, Revenue, Status)
Tabs (Time Entries | Expenses | Invoices)
Tab Content (Table or list)
```

### 7.4 Form Pages (New/Edit)

**Structure:**
```
Page Title + Cancel/Save buttons (right)
Form Card (white background, border)
  Section 1: Basic Info (Name, Client, Rate)
  Divider
  Section 2: Details (Description, Date range)
  Divider
  Section 3: Branding (Logo upload, Color picker)
Action Bar (Cancel button, Save button)
```

---

## 8. Invoice PDF Design (Print-Optimized)

**Layout:**
- Page size: A4 (210mm x 297mm)
- Margins: 20mm all sides
- Font: Inter (body), JetBrains Mono (numbers)
- Colors: Use brand colors (`#0891B2` header accent) but ensure grayscale printable

**Structure:**
```
┌─────────────────────────────────────────────┐
│ [Freelancer Logo]    Invoice #INV-2024-001 │
│ Business Name        Date: 02/10/2024      │
│ Address, Phone       Due: 16/10/2024       │
├─────────────────────────────────────────────┤
│ Bill To:                                    │
│ Client Name                                 │
│ Client Address                              │
├─────────────────────────────────────────────┤
│ Line Items Table                            │
│ ┌──────────────┬──────┬───────┬──────────┐ │
│ │ Description  │ Qty  │ Rate  │ Amount   │ │
│ ├──────────────┼──────┼───────┼──────────┤ │
│ │ Time entry 1 │ 8 hr │ 250k  │ 2,000k   │ │
│ └──────────────┴──────┴───────┴──────────┘ │
├─────────────────────────────────────────────┤
│                          Subtotal: 2,000k   │
│                          Tax (11%): 220k    │
│                          Total: 2,220k      │
├─────────────────────────────────────────────┤
│ Notes: Payment due within 14 days.         │
│ Bank: BCA 1234567890 (Business Name)       │
├─────────────────────────────────────────────┤
│ Footer: Thank you for your business!       │
│ [Custom footer text from settings]         │
└─────────────────────────────────────────────┘
```

**Customization (from Settings > Branding):**
- Logo: Top left, max 200px width, auto-height
- Primary color: Header background or left border accent
- Footer text: Custom "Thank you" message + payment terms

---

## 9. Animations & Interactions (Minimal)

**Allowed:**
- Hover state: Opacity change (`hover:opacity-90`), background color shift
- Focus state: Ring outline (`focus:ring-2 ring-cyan-500`)
- Transitions: 150ms ease-out (buttons, links)
- Loading spinners: Simple rotating circle (tailwindcss `animate-spin`)
- Toast slide-in: From top-right, 200ms ease-out

**FORBIDDEN:**
- Page transitions (no Framer Motion route animations)
- Parallax scrolling
- Floating/levitating cards (`transform: translateY(-10px)`)
- Gradient animations (shifting colors)
- Skeleton loaders with shimmer (use static gray blocks)
- Confetti/celebration effects (even for "Invoice Paid" — keep professional)

---

## 10. Accessibility Checklist

- [ ] All text ≥4.5:1 contrast ratio (WCAG AA)
- [ ] Interactive elements ≥44px touch target (mobile)
- [ ] Form inputs have explicit `<label>` elements
- [ ] Focus states visible (2px ring outline)
- [ ] Keyboard navigable (Tab, Enter, Esc work)
- [ ] ARIA labels for icon-only buttons (`aria-label="Edit project"`)
- [ ] Error messages associated with fields (`aria-describedby`)
- [ ] Status badges have text, not just color (`"Paid"` text + green color)
- [ ] Tables have `<thead>`, `<tbody>` structure
- [ ] Modals trap focus, Esc to close

---

## 11. Tech Stack Constraints

**Framework:** Next.js 15 (App Router)
**Styling:** Tailwind CSS 3.4+ (utility classes only, NO custom CSS files)
**Components:** shadcn/ui (Radix UI primitives)
**Icons:** Lucide React (consistent icon set, 24px default size)
**PDF Generation:** React-PDF or Puppeteer (server-side)
**Forms:** React Hook Form + Zod validation

**NO:**
- CSS-in-JS libraries (styled-components, emotion)
- Component libraries with heavy themes (Material UI, Ant Design)
- Animation libraries (Framer Motion) — exception: prototype demos only
- Chart libraries (MVP skip analytics dashboards)

---

## 12. Anti-Slop Validation Checklist

Before marking design complete, verify ZERO of these exist:

**Visual Slop:**
- [ ] Gradients (`bg-gradient-to-r`)
- [ ] Glassmorphism (`backdrop-blur`)
- [ ] Shadows > `shadow-md`
- [ ] Border radius > 12px (except `rounded-full`)
- [ ] Colored shadows
- [ ] Floating card hover effects

**Code Slop:**
- [ ] Tailwind classes > 20 per element (refactor to component)
- [ ] Custom `@keyframes` for static content
- [ ] Hardcoded pixel values outside Tailwind scale (`w-[347px]`)

**Content Slop:**
- [ ] Lorem Ipsum placeholder text
- [ ] Generic headlines ("Unlock Your Potential")
- [ ] Emoji overuse in UI (🚀💥✨)

---

## 13. Design Token Export (CSS Variables)

For consistency across React components and PDF generation:

```css
:root {
  /* Colors */
  --color-primary: #0891B2;
  --color-primary-hover: #0E7490;
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  
  /* Backgrounds */
  --bg-primary: #FFFFFF;
  --bg-surface: #FAFAFA;
  --bg-hover: #F4F4F5;
  
  /* Text */
  --text-primary: #18181B;
  --text-secondary: #52525B;
  --text-muted: #A1A1AA;
  
  /* Borders */
  --border-default: #E4E4E7;
  --border-focus: #0891B2;
  
  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 12px;
  --spacing-base: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  
  /* Radius */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
}
```

**Tailwind Config:**
```js
// tailwind.config.ts
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#0891B2',
        'primary-hover': '#0E7490',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

---

## 14. Component State Matrix (5 States Per Screen)

Every screen MUST handle these states:

1. **Default (Happy Path):** Data loaded, interactive
2. **Loading:** Skeleton loaders or spinner (no data yet)
3. **Empty:** No data, show prompt + CTA ("Create your first project")
4. **Error:** Network failure, show error message + "Retry" button
5. **Success:** After action (e.g., "Invoice sent successfully" toast)

**Example (Projects List):**
- Default: Table with 10 projects
- Loading: 10 skeleton rows (gray blocks)
- Empty: "No projects yet. Create one to start tracking time." + "New Project" button
- Error: "Failed to load projects. Check your connection." + "Retry" button
- Success: Toast "Project created successfully!" (after creating new project)

---

**Last Updated:** 2026-10-02  
**Status:** DRAFT - Ready for DESIGN_SYSTEM.md generation  
**Next Step:** Generate comprehensive screen specs in `docs/specs/DESIGN_SYSTEM.md`
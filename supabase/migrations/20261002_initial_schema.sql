-- ============================================
-- Freelance Invoice Tracker - Database Schema
-- Generated: 2026-10-02 (Fixed FK order)
-- Source: docs/specs/FSD.md section 3
-- ============================================

-- ============================================
-- EXTENSIONS
-- ============================================


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
    invoice_primary_color VARCHAR(7) DEFAULT '#0891B2',
    invoice_footer_text TEXT DEFAULT 'Thank you for your business!',
    
    -- Default settings
    default_tax_rate DECIMAL(5,2) DEFAULT 0.00,
    default_currency VARCHAR(3) DEFAULT 'USD',
    invoice_number_prefix VARCHAR(20) DEFAULT 'INV-',
    invoice_counter INT DEFAULT 1,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own clients"
    ON clients FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: projects
-- ============================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    hourly_rate DECIMAL(12,2) NOT NULL CHECK (hourly_rate >= 0),
    
    status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_freelancer ON projects(freelancer_id);
CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(freelancer_id, status);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own projects"
    ON projects FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: invoices (MOVED BEFORE time_entries/expenses)
-- ============================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    
    line_items JSONB NOT NULL,
    
    subtotal DECIMAL(12,2) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL,
    
    notes TEXT,
    
    status VARCHAR(30) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'approved', 'paid', 'overdue')),
    
    client_token VARCHAR(64) UNIQUE,
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
CREATE INDEX idx_invoices_token ON invoices(client_token);

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own invoices"
    ON invoices FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: time_entries (NOW SAFE - invoices exists)
-- ============================================
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    hours DECIMAL(6,2) NOT NULL CHECK (hours > 0),
    description TEXT NOT NULL,
    
    amount DECIMAL(12,2) NOT NULL,
    
    is_invoiced BOOLEAN DEFAULT FALSE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_time_entries_freelancer ON time_entries(freelancer_id);
CREATE INDEX idx_time_entries_project ON time_entries(project_id);
CREATE INDEX idx_time_entries_date ON time_entries(project_id, date);
CREATE INDEX idx_time_entries_invoiced ON time_entries(freelancer_id, is_invoiced);

ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own time entries"
    ON time_entries FOR ALL
    USING (auth.uid() = freelancer_id);


-- ============================================
-- TABLE: expenses (NOW SAFE - invoices exists)
-- ============================================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    
    receipt_url VARCHAR(500),
    
    is_invoiced BOOLEAN DEFAULT FALSE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expenses_freelancer ON expenses(freelancer_id);
CREATE INDEX idx_expenses_project ON expenses(project_id);
CREATE INDEX idx_expenses_invoiced ON expenses(freelancer_id, is_invoiced);

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Freelancers can manage own expenses"
    ON expenses FOR ALL
    USING (auth.uid() = freelancer_id);


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

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_entries_updated_at BEFORE UPDATE ON time_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- TRIGGER: Auto-create profile on user signup
-- ============================================
CREATE OR REPLACE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, full_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_profile_for_user();

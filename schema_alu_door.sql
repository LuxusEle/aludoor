-- =============================================================================
-- ALU DOOR PILOT - SUPABASE DATABASE SCHEMA
-- -----------------------------------------------------------------------------
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard/project/iefeibuhjupnpmcomxbg/sql)
-- =============================================================================

-- 1. Create ALU Doors Table
CREATE TABLE IF NOT EXISTS public.alu_doors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT '70S Sliding Door',
    system_type TEXT NOT NULL DEFAULT '70S 2-Track Aluminium Sliding Door',
    width_mm NUMERIC(10, 2) NOT NULL,
    height_mm NUMERIC(10, 2) NOT NULL,
    bom_data JSONB DEFAULT '{}'::jsonb,
    nesting_data JSONB DEFAULT '{}'::jsonb,
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create ALU Nesting Jobs Table (1D Linear Cutting Stock Optimization)
CREATE TABLE IF NOT EXISTS public.alu_nesting_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    door_id UUID REFERENCES public.alu_doors(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    stock_bar_length_mm NUMERIC(10, 2) DEFAULT 6000.0,
    blade_kerf_mm NUMERIC(10, 2) DEFAULT 3.5,
    total_stock_bars_needed INT DEFAULT 0,
    total_offcut_waste_percent NUMERIC(5, 2) DEFAULT 0.0,
    cutting_patterns JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Vendor Price Catalog Table (Smart Price Memory for Quotes)
CREATE TABLE IF NOT EXISTS public.alu_vendor_price_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_name TEXT UNIQUE NOT NULL,
    category TEXT DEFAULT 'Aluminium Extrusions',
    currency TEXT DEFAULT 'LKR',
    prices JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Seed Default Sri Lanka Vendors
INSERT INTO public.alu_vendor_price_catalog (vendor_name, category, currency, prices)
VALUES 
('Alumex PLC', 'Aluminium Extrusions', 'LKR', '{"70S-1001-1": 8500, "70S-1101-1": 9200, "70S-1201-1": 6800, "70S-1401": 4500, "70S-1501": 6200, "70S-1701": 4200, "70S-1601": 4800}'::jsonb),
('Amex Aluminium', 'Aluminium Extrusions', 'LKR', '{"70S-1001-1": 8200, "70S-1101-1": 8900, "70S-1201-1": 6600, "70S-1401": 4350, "70S-1501": 5950, "70S-1701": 4050, "70S-1601": 4650}'::jsonb),
('Swisstek Aluminium', 'Aluminium Extrusions', 'LKR', '{"70S-1001-1": 8400, "70S-1101-1": 9100, "70S-1201-1": 6750, "70S-1401": 4450, "70S-1501": 6100, "70S-1701": 4150, "70S-1601": 4750}'::jsonb)
ON CONFLICT (vendor_name) DO UPDATE 
SET prices = EXCLUDED.prices, updated_at = now();

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.alu_doors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alu_nesting_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alu_vendor_price_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on alu_vendor_price_catalog"
ON public.alu_vendor_price_catalog FOR SELECT TO public USING (true);

CREATE POLICY "Allow authenticated insert/update on alu_vendor_price_catalog"
ON public.alu_vendor_price_catalog FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read on alu_doors"
ON public.alu_doors FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow authenticated insert on alu_doors"
ON public.alu_doors FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Allow authenticated update on alu_doors"
ON public.alu_doors FOR UPDATE
TO public
USING (true);

CREATE POLICY "Allow public read on alu_nesting_jobs"
ON public.alu_nesting_jobs FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public insert on alu_nesting_jobs"
ON public.alu_nesting_jobs FOR INSERT
TO public
WITH CHECK (true);

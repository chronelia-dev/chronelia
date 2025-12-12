-- ============================================
-- CREAR ESTRUCTURA COMPLETA DE CHRONELIA
-- ============================================
-- Este script crea TODA la estructura necesaria desde cero
-- ============================================

-- ============================================
-- PASO 1: CREAR TABLA DE NEGOCIOS
-- ============================================
CREATE TABLE IF NOT EXISTS public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ============================================
-- PASO 2: CREAR TABLA DE USUARIOS
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'worker',
  business_id uuid NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ============================================
-- PASO 3: CREAR ÍNDICES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);
CREATE INDEX IF NOT EXISTS idx_users_business_id ON public.users(business_id);
CREATE INDEX IF NOT EXISTS idx_businesses_schema_name ON public.businesses(schema_name);

-- ============================================
-- PASO 4: VERIFICAR TABLAS CREADAS
-- ============================================
SELECT 
  table_name as "Tabla Creada",
  table_type as "Tipo"
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('businesses', 'users')
ORDER BY table_name;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- Deberías ver:
-- | Tabla Creada | Tipo       |
-- |--------------|------------|
-- | businesses   | BASE TABLE |
-- | users        | BASE TABLE |
-- ============================================


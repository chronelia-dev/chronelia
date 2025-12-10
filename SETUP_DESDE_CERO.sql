-- ============================================
-- CHRONELIA - SETUP DESDE CERO
-- ============================================
-- Este script crea TODA la estructura necesaria
-- Ejecuta esto COMPLETO en Supabase SQL Editor

-- ============================================
-- PASO 1: Crear tabla de negocios
-- ============================================
CREATE TABLE IF NOT EXISTS public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 2: Crear tabla de usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text,
  email text UNIQUE NOT NULL,
  password_hash text,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'worker')),
  active boolean DEFAULT true,
  business_id uuid REFERENCES public.businesses(id),
  schema_name text,
  business_name text,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 3: Insertar negocio
-- ============================================
INSERT INTO public.businesses (id, name, schema_name)
VALUES (
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'Locos X Cerveza',
  'locosxcerveza'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- PASO 4: Crear schema del negocio
-- ============================================
CREATE SCHEMA IF NOT EXISTS locosxcerveza;

-- ============================================
-- PASO 5: Crear tabla de reservas
-- ============================================
CREATE TABLE IF NOT EXISTS locosxcerveza.reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text,
  qr_code text,
  total_duration integer NOT NULL,
  actual_duration integer DEFAULT 0,
  start_time timestamptz NOT NULL DEFAULT NOW(),
  end_time timestamptz,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  worker_name text,
  group_size integer DEFAULT 1,
  extensions integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Índices para rendimiento
CREATE INDEX IF NOT EXISTS idx_reservations_status 
ON locosxcerveza.reservations(status);

CREATE INDEX IF NOT EXISTS idx_reservations_start_time 
ON locosxcerveza.reservations(start_time DESC);

CREATE INDEX IF NOT EXISTS idx_reservations_worker 
ON locosxcerveza.reservations(worker_name);

-- ============================================
-- PASO 6: Crear tabla de usuarios del negocio
-- ============================================
CREATE TABLE IF NOT EXISTS locosxcerveza.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'worker')),
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 7: Crear tabla de clientes
-- ============================================
CREATE TABLE IF NOT EXISTS locosxcerveza.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  total_visits integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 8: Crear tabla de estadísticas
-- ============================================
CREATE TABLE IF NOT EXISTS locosxcerveza.daily_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date UNIQUE NOT NULL DEFAULT CURRENT_DATE,
  total_reservations integer DEFAULT 0,
  completed_reservations integer DEFAULT 0,
  cancelled_reservations integer DEFAULT 0,
  total_time integer DEFAULT 0,
  average_duration integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 9: Insertar usuarios de prueba
-- ============================================

-- Usuario Admin
INSERT INTO public.users (
  id,
  username,
  email,
  password_hash,
  full_name,
  role,
  active,
  business_id,
  schema_name,
  business_name
)
VALUES (
  gen_random_uuid(),
  'admin',
  'admin@chronelia.com',
  'Chronelia@202x',
  'Administrador',
  'admin',
  true,
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'locosxcerveza',
  'Locos X Cerveza'
)
ON CONFLICT (email) DO UPDATE SET
  schema_name = 'locosxcerveza',
  business_name = 'Locos X Cerveza',
  business_id = 'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab';

-- Usuario Trabajador
INSERT INTO public.users (
  id,
  username,
  email,
  password_hash,
  full_name,
  role,
  active,
  business_id,
  schema_name,
  business_name
)
VALUES (
  gen_random_uuid(),
  'trabajador',
  'trabajador@chronelia.com',
  'Chronelia@202x',
  'Trabajador de Prueba',
  'worker',
  true,
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'locosxcerveza',
  'Locos X Cerveza'
)
ON CONFLICT (email) DO UPDATE SET
  schema_name = 'locosxcerveza',
  business_name = 'Locos X Cerveza',
  business_id = 'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab';

-- ============================================
-- PASO 10: Copiar usuarios a schema del negocio
-- ============================================
INSERT INTO locosxcerveza.users (id, username, email, full_name, role, active)
SELECT id, username, email, full_name, role, active
FROM public.users
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- PASO 11: Configurar permisos
-- ============================================
-- Dar permisos al rol 'anon' (usuarios no autenticados)
GRANT USAGE ON SCHEMA locosxcerveza TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA locosxcerveza TO anon;

-- Dar permisos al rol 'authenticated' (usuarios autenticados)
GRANT USAGE ON SCHEMA locosxcerveza TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA locosxcerveza TO authenticated;

-- Permisos en funciones
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Permisos por defecto para nuevas tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA locosxcerveza 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Ver tablas creadas en public
SELECT 
  '✅ Tablas en schema PUBLIC' as verificacion,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Ver tablas en schema del negocio
SELECT 
  '✅ Tablas en schema LOCOSXCERVEZA' as verificacion,
  table_name
FROM information_schema.tables
WHERE table_schema = 'locosxcerveza'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Ver usuarios creados
SELECT 
  '✅ USUARIOS CONFIGURADOS' as verificacion,
  email,
  username,
  role,
  schema_name,
  business_name,
  CASE 
    WHEN schema_name IS NOT NULL THEN '✅ LISTO'
    ELSE '❌ SIN SCHEMA'
  END as estado
FROM public.users
ORDER BY role, email;

-- Ver negocio creado
SELECT 
  '✅ NEGOCIO CONFIGURADO' as verificacion,
  name,
  schema_name,
  created_at
FROM public.businesses;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- 
-- ✅ Tablas en PUBLIC:
--    - businesses
--    - users
--
-- ✅ Tablas en LOCOSXCERVEZA:
--    - customers
--    - daily_stats
--    - reservations
--    - users
--
-- ✅ USUARIOS:
--    - admin@chronelia.com | schema: locosxcerveza | ✅ LISTO
--    - trabajador@chronelia.com | schema: locosxcerveza | ✅ LISTO
--
-- ✅ NEGOCIO:
--    - Locos X Cerveza | schema: locosxcerveza
--
-- ============================================
-- SIGUIENTE PASO:
-- Ejecutar: FUNCIONES_RPC_MULTI_TENANT.sql
-- ============================================


-- ============================================
-- CHRONELIA - RESET COMPLETO Y SETUP
-- ============================================
-- ⚠️ ADVERTENCIA: Este script BORRA TODO y crea desde cero
-- Solo ejecuta esto si estás seguro

-- ============================================
-- PASO 1: ELIMINAR TODO LO EXISTENTE
-- ============================================

-- Eliminar schema del negocio si existe
DROP SCHEMA IF EXISTS locosxcerveza CASCADE;

-- Eliminar tablas en public si existen
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;

-- ============================================
-- PASO 2: CREAR TABLA DE NEGOCIOS
-- ============================================
CREATE TABLE public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 3: CREAR TABLA DE USUARIOS
-- ============================================
CREATE TABLE public.users (
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
-- PASO 4: INSERTAR NEGOCIO
-- ============================================
INSERT INTO public.businesses (id, name, schema_name)
VALUES (
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'Locos X Cerveza',
  'locosxcerveza'
);

-- ============================================
-- PASO 5: CREAR SCHEMA DEL NEGOCIO
-- ============================================
CREATE SCHEMA locosxcerveza;

-- ============================================
-- PASO 6: CREAR TABLA DE RESERVAS
-- ============================================
CREATE TABLE locosxcerveza.reservations (
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

-- Índices
CREATE INDEX idx_reservations_status ON locosxcerveza.reservations(status);
CREATE INDEX idx_reservations_start_time ON locosxcerveza.reservations(start_time DESC);
CREATE INDEX idx_reservations_worker ON locosxcerveza.reservations(worker_name);

-- ============================================
-- PASO 7: CREAR TABLA DE USUARIOS DEL NEGOCIO
-- ============================================
CREATE TABLE locosxcerveza.users (
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
-- PASO 8: CREAR TABLA DE CLIENTES
-- ============================================
CREATE TABLE locosxcerveza.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  total_visits integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 9: CREAR TABLA DE ESTADÍSTICAS
-- ============================================
CREATE TABLE locosxcerveza.daily_stats (
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
-- PASO 10: INSERTAR USUARIOS
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
);

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
);

-- ============================================
-- PASO 11: COPIAR USUARIOS AL SCHEMA
-- ============================================
INSERT INTO locosxcerveza.users (id, username, email, full_name, role, active)
SELECT id, username, email, full_name, role, active
FROM public.users;

-- ============================================
-- PASO 12: CONFIGURAR PERMISOS
-- ============================================
GRANT USAGE ON SCHEMA locosxcerveza TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA locosxcerveza TO anon;

GRANT USAGE ON SCHEMA locosxcerveza TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA locosxcerveza TO authenticated;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA locosxcerveza 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Mostrar tablas en public
SELECT 
  '✅ TABLAS EN PUBLIC' as paso,
  table_name,
  (SELECT COUNT(*) 
   FROM information_schema.columns 
   WHERE table_schema = 'public' 
     AND table_name = tables.table_name) as columnas
FROM information_schema.tables tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Mostrar tablas en locosxcerveza
SELECT 
  '✅ TABLAS EN LOCOSXCERVEZA' as paso,
  table_name,
  (SELECT COUNT(*) 
   FROM information_schema.columns 
   WHERE table_schema = 'locosxcerveza' 
     AND table_name = tables.table_name) as columnas
FROM information_schema.tables tables
WHERE table_schema = 'locosxcerveza'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Mostrar usuarios creados
SELECT 
  '✅ USUARIOS CREADOS' as paso,
  email,
  role,
  schema_name,
  business_name,
  CASE 
    WHEN schema_name IS NOT NULL THEN '✅ CONFIGURADO'
    ELSE '❌ SIN CONFIGURAR'
  END as estado
FROM public.users
ORDER BY role, email;

-- Mostrar negocio
SELECT 
  '✅ NEGOCIO CREADO' as paso,
  name,
  schema_name
FROM public.businesses;

-- Contar registros en reservations
SELECT 
  '✅ TABLA RESERVATIONS' as paso,
  COUNT(*) as total_reservas,
  'Lista para usar' as estado
FROM locosxcerveza.reservations;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- 
-- Deberías ver:
--
-- TABLAS EN PUBLIC (2):
--   - businesses (3 columnas)
--   - users (11 columnas)
--
-- TABLAS EN LOCOSXCERVEZA (4):
--   - customers
--   - daily_stats
--   - reservations ← ¡LA MÁS IMPORTANTE!
--   - users
--
-- USUARIOS CREADOS (2):
--   - admin@chronelia.com | admin | locosxcerveza | ✅ CONFIGURADO
--   - trabajador@chronelia.com | worker | locosxcerveza | ✅ CONFIGURADO
--
-- NEGOCIO:
--   - Locos X Cerveza | locosxcerveza
--
-- TABLA RESERVATIONS:
--   - 0 reservas | Lista para usar
--
-- ============================================
-- SIGUIENTE PASO:
-- ============================================
-- Ejecutar: FUNCIONES_RPC_MULTI_TENANT.sql
-- ============================================


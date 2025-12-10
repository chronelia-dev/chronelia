-- ============================================
-- CHRONELIA - SETUP COMPLETO DE BASE DE DATOS
-- ============================================
-- Ejecuta este script COMPLETO en Supabase SQL Editor
-- Esto creará toda la estructura necesaria desde cero

-- ============================================
-- PASO 1: Crear tabla de negocios (public.businesses)
-- ============================================
CREATE TABLE IF NOT EXISTS public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 2: Crear tabla de usuarios (public.users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
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
-- PASO 3: Crear negocio de ejemplo
-- ============================================
INSERT INTO public.businesses (id, name, schema_name)
VALUES (
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'Locos X Cerveza',
  'locosxcerveza'
)
ON CONFLICT (schema_name) DO NOTHING;

-- ============================================
-- PASO 4: Crear schema para el negocio
-- ============================================
CREATE SCHEMA IF NOT EXISTS locosxcerveza;

-- ============================================
-- PASO 5: Crear tablas en el schema del negocio
-- ============================================

-- Tabla de usuarios del negocio
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

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS locosxcerveza.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Tabla de reservas
CREATE TABLE IF NOT EXISTS locosxcerveza.reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text,
  qr_code text,
  total_duration integer NOT NULL,
  actual_duration integer,
  start_time timestamptz NOT NULL DEFAULT NOW(),
  end_time timestamptz,
  status text NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
  worker_name text,
  group_size integer DEFAULT 1,
  extensions integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Tabla de estadísticas diarias
CREATE TABLE IF NOT EXISTS locosxcerveza.daily_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date UNIQUE NOT NULL DEFAULT CURRENT_DATE,
  total_reservations integer DEFAULT 0,
  completed_reservations integer DEFAULT 0,
  cancelled_reservations integer DEFAULT 0,
  total_time integer DEFAULT 0,
  average_duration integer DEFAULT 0,
  total_revenue numeric(10,2) DEFAULT 0,
  created_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 6: Crear usuarios de prueba en public.users
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
-- PASO 7: Dar permisos a usuarios anónimos
-- ============================================
GRANT USAGE ON SCHEMA locosxcerveza TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA locosxcerveza TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Verificar tablas creadas
SELECT 
  '✅ Tablas en public' as verificacion,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar tablas en schema del negocio
SELECT 
  '✅ Tablas en locosxcerveza' as verificacion,
  table_name
FROM information_schema.tables
WHERE table_schema = 'locosxcerveza'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar usuarios creados
SELECT 
  '✅ Usuarios creados' as verificacion,
  email,
  username,
  role,
  schema_name,
  business_name,
  active
FROM public.users
ORDER BY role, email;

-- Verificar negocio creado
SELECT 
  '✅ Negocio creado' as verificacion,
  id,
  name,
  schema_name,
  created_at
FROM public.businesses;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- Deberías ver:
-- 
-- ✅ Tablas en public: businesses, users
-- ✅ Tablas en locosxcerveza: users, customers, reservations, daily_stats
-- ✅ Usuarios creados: admin y trabajador (ambos con schema_name = 'locosxcerveza')
-- ✅ Negocio creado: Locos X Cerveza (schema_name = 'locosxcerveza')
--
-- ============================================
-- SIGUIENTE PASO:
-- ============================================
-- Ejecuta el archivo: FUNCIONES_RPC_MULTI_TENANT.sql
-- para crear las funciones que permiten guardar/obtener reservas
-- ============================================


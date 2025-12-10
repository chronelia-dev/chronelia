-- ============================================
-- CHRONELIA - RESET TOTAL Y SETUP MULTI-TENANT
-- ============================================
-- Este script ELIMINA TODO y crea un sistema multi-tenant limpio
-- 
-- ARQUITECTURA:
-- - Cada negocio tiene su propio schema
-- - Los usuarios se asocian a un negocio/schema
-- - Las reservas se guardan en el schema del negocio
-- - Realtime sincroniza automáticamente
-- ============================================

-- ============================================
-- PASO 1: LIMPIAR TODO
-- ============================================

-- Eliminar todos los schemas de negocios
DROP SCHEMA IF EXISTS locosxcerveza CASCADE;
-- Si tienes otros schemas de negocios, agrégalos aquí

-- Eliminar tablas en public
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;

-- Eliminar funciones RPC antiguas
DROP FUNCTION IF EXISTS save_reservation CASCADE;
DROP FUNCTION IF EXISTS get_active_reservations CASCADE;
DROP FUNCTION IF EXISTS get_reservation_history CASCADE;
DROP FUNCTION IF EXISTS get_workers CASCADE;

-- ============================================
-- PASO 2: CREAR TABLA DE NEGOCIOS
-- ============================================
CREATE TABLE public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PASO 3: CREAR TABLA DE USUARIOS
-- ============================================
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'worker')),
  business_id uuid NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  schema_name text NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_users_business_id ON public.users(business_id);
CREATE INDEX idx_users_schema_name ON public.users(schema_name);
CREATE INDEX idx_users_email ON public.users(email);

-- ============================================
-- PASO 4: INSERTAR NEGOCIO DE EJEMPLO
-- ============================================
INSERT INTO public.businesses (id, name, schema_name, active)
VALUES (
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'Locos X Cerveza',
  'locosxcerveza',
  true
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
  worker_name text NOT NULL,
  worker_id uuid,
  group_size integer DEFAULT 1,
  extensions integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Índices para consultas rápidas
CREATE INDEX idx_reservations_status ON locosxcerveza.reservations(status);
CREATE INDEX idx_reservations_start_time ON locosxcerveza.reservations(start_time DESC);
CREATE INDEX idx_reservations_worker_id ON locosxcerveza.reservations(worker_id);

-- ============================================
-- PASO 7: HABILITAR REALTIME
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE locosxcerveza.reservations;

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
-- PASO 10: INSERTAR USUARIOS DE PRUEBA
-- ============================================

-- Admin
INSERT INTO public.users (
  id,
  email,
  password,
  full_name,
  role,
  business_id,
  schema_name,
  active
)
VALUES (
  gen_random_uuid(),
  'admin@locosxcerveza.com',
  'Chronelia@2025',
  'Administrador',
  'admin',
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'locosxcerveza',
  true
);

-- Trabajador 1
INSERT INTO public.users (
  id,
  email,
  password,
  full_name,
  role,
  business_id,
  schema_name,
  active
)
VALUES (
  gen_random_uuid(),
  'trabajador@locosxcerveza.com',
  'Chronelia@2025',
  'Carlos López',
  'worker',
  'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
  'locosxcerveza',
  true
);

-- ============================================
-- PASO 11: FUNCIONES RPC MULTI-TENANT
-- ============================================

-- Función para guardar reserva
CREATE OR REPLACE FUNCTION save_reservation(
  p_schema_name text,
  p_id uuid,
  p_customer_name text,
  p_customer_email text,
  p_qr_code text,
  p_total_duration integer,
  p_actual_duration integer,
  p_start_time timestamptz,
  p_end_time timestamptz,
  p_status text,
  p_worker_name text,
  p_worker_id uuid,
  p_group_size integer,
  p_extensions integer
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result_id uuid;
BEGIN
  EXECUTE format(
    'INSERT INTO %I.reservations 
     (id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
      start_time, end_time, status, worker_name, worker_id, group_size, extensions)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
     ON CONFLICT (id) DO UPDATE SET
       customer_name = EXCLUDED.customer_name,
       customer_email = EXCLUDED.customer_email,
       qr_code = EXCLUDED.qr_code,
       total_duration = EXCLUDED.total_duration,
       actual_duration = EXCLUDED.actual_duration,
       start_time = EXCLUDED.start_time,
       end_time = EXCLUDED.end_time,
       status = EXCLUDED.status,
       worker_name = EXCLUDED.worker_name,
       worker_id = EXCLUDED.worker_id,
       group_size = EXCLUDED.group_size,
       extensions = EXCLUDED.extensions,
       updated_at = NOW()
     RETURNING id',
    p_schema_name
  ) USING p_id, p_customer_name, p_customer_email, p_qr_code, 
          p_total_duration, p_actual_duration, p_start_time, p_end_time, 
          p_status, p_worker_name, p_worker_id, p_group_size, p_extensions
  INTO result_id;
  
  RETURN result_id;
END;
$$;

-- Función para obtener reservas activas
CREATE OR REPLACE FUNCTION get_active_reservations(p_schema_name text)
RETURNS TABLE (
  id uuid,
  customer_name text,
  customer_email text,
  qr_code text,
  total_duration integer,
  actual_duration integer,
  start_time timestamptz,
  end_time timestamptz,
  status text,
  worker_name text,
  worker_id uuid,
  group_size integer,
  extensions integer,
  created_at timestamptz,
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT 
      id, customer_name, customer_email, qr_code, total_duration, 
      actual_duration, start_time, end_time, status, worker_name, 
      worker_id, group_size, extensions, created_at, updated_at
     FROM %I.reservations 
     WHERE status = ''active''
     ORDER BY start_time DESC',
    p_schema_name
  );
END;
$$;

-- Función para obtener historial de reservas
CREATE OR REPLACE FUNCTION get_reservation_history(p_schema_name text)
RETURNS TABLE (
  id uuid,
  customer_name text,
  customer_email text,
  qr_code text,
  total_duration integer,
  actual_duration integer,
  start_time timestamptz,
  end_time timestamptz,
  status text,
  worker_name text,
  worker_id uuid,
  group_size integer,
  extensions integer,
  created_at timestamptz,
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT 
      id, customer_name, customer_email, qr_code, total_duration, 
      actual_duration, start_time, end_time, status, worker_name, 
      worker_id, group_size, extensions, created_at, updated_at
     FROM %I.reservations 
     WHERE status IN (''completed'', ''cancelled'')
     ORDER BY start_time DESC
     LIMIT 100',
    p_schema_name
  );
END;
$$;

-- Función para obtener trabajadores
CREATE OR REPLACE FUNCTION get_workers(p_schema_name text)
RETURNS TABLE (
  id uuid,
  email text,
  full_name text,
  role text,
  active boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT u.id, u.email, u.full_name, u.role, u.active
  FROM public.users u
  WHERE u.schema_name = p_schema_name
    AND u.role = 'worker'
    AND u.active = true
  ORDER BY u.full_name;
END;
$$;

-- ============================================
-- PASO 12: CONFIGURAR PERMISOS
-- ============================================

-- Permisos en schema
GRANT USAGE ON SCHEMA locosxcerveza TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA locosxcerveza TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA locosxcerveza TO anon, authenticated;

-- Permisos en funciones
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Permisos por defecto
ALTER DEFAULT PRIVILEGES IN SCHEMA locosxcerveza 
GRANT ALL ON TABLES TO anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA locosxcerveza 
GRANT ALL ON SEQUENCES TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Ver estructura creada
SELECT '✅ NEGOCIOS CREADOS' as paso, name, schema_name, active 
FROM public.businesses;

SELECT '✅ USUARIOS CREADOS' as paso, email, full_name, role, schema_name, active 
FROM public.users 
ORDER BY role, email;

SELECT '✅ TABLAS EN SCHEMA' as paso, table_name 
FROM information_schema.tables 
WHERE table_schema = 'locosxcerveza'
ORDER BY table_name;

SELECT '✅ FUNCIONES RPC' as paso, routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_type = 'FUNCTION'
  AND routine_name IN ('save_reservation', 'get_active_reservations', 'get_reservation_history', 'get_workers')
ORDER BY routine_name;

SELECT '✅ REALTIME HABILITADO' as paso, 
  schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND schemaname = 'locosxcerveza';

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- 
-- NEGOCIOS: Locos X Cerveza | locosxcerveza | active
-- 
-- USUARIOS:
--   - admin@locosxcerveza.com | Administrador | admin | locosxcerveza
--   - trabajador@locosxcerveza.com | Carlos López | worker | locosxcerveza
-- 
-- TABLAS: customers, daily_stats, reservations
-- 
-- FUNCIONES: get_active_reservations, get_reservation_history, 
--            get_workers, save_reservation
-- 
-- REALTIME: locosxcerveza | reservations
-- ============================================

-- ============================================
-- CREDENCIALES DE ACCESO:
-- ============================================
-- 
-- Admin:
--   Email: admin@locosxcerveza.com
--   Password: Chronelia@2025
-- 
-- Trabajador:
--   Email: trabajador@locosxcerveza.com
--   Password: Chronelia@2025
-- ============================================


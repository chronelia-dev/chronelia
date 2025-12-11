-- ============================================
-- PASO 2: CONFIGURAR BASE MULTI-TENANT
-- ============================================
-- Este script crea la estructura base del sistema
-- NO crea negocios ni usuarios todavía

-- ============================================
-- 1. CREAR TABLA DE NEGOCIOS
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
-- 2. CREAR TABLA DE USUARIOS
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

-- Índices para rendimiento
CREATE INDEX idx_users_business_id ON public.users(business_id);
CREATE INDEX idx_users_schema_name ON public.users(schema_name);
CREATE INDEX idx_users_email ON public.users(email);

-- ============================================
-- 3. FUNCIONES RPC MULTI-TENANT
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

-- Función para obtener historial
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
-- 4. CONFIGURAR PERMISOS GLOBALES
-- ============================================

-- Permisos en funciones
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ Tabla businesses creada' as paso, 
  COUNT(*) as registros 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'businesses';

SELECT '✅ Tabla users creada' as paso, 
  COUNT(*) as registros 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'users';

SELECT '✅ Funciones RPC creadas' as paso, 
  routine_name as funcion
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_type = 'FUNCTION'
  AND routine_name IN ('save_reservation', 'get_active_reservations', 'get_reservation_history', 'get_workers')
ORDER BY routine_name;

-- ============================================
-- ✅ ESTRUCTURA BASE LISTA
-- ============================================
-- 
-- Ahora puedes agregar tu negocio usando:
-- PASO_3_AGREGAR_NEGOCIO.sql
-- 
-- ============================================


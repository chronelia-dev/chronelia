-- ============================================
-- FUNCIONES RPC PARA MULTI-TENANT
-- ============================================
-- Estas funciones permiten acceder a tablas en schemas específicos
-- desde el cliente de Supabase JS

-- ============================================
-- FUNCIÓN: Obtener reservas activas de un schema
-- ============================================
CREATE OR REPLACE FUNCTION get_active_reservations(schema_name text)
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
  group_size integer,
  extensions integer,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
     start_time, end_time, status, worker_name, group_size, extensions, created_at
     FROM %I.reservations 
     WHERE status = ''active''
     ORDER BY start_time DESC',
    schema_name
  );
END;
$$;

-- ============================================
-- FUNCIÓN: Obtener historial de reservas
-- ============================================
CREATE OR REPLACE FUNCTION get_reservation_history(schema_name text, limit_count integer DEFAULT 50)
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
  group_size integer,
  extensions integer,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
     start_time, end_time, status, worker_name, group_size, extensions, created_at
     FROM %I.reservations 
     WHERE status = ''completed''
     ORDER BY end_time DESC
     LIMIT $1',
    schema_name
  ) USING limit_count;
END;
$$;

-- ============================================
-- FUNCIÓN: Obtener trabajadores de un schema
-- ============================================
CREATE OR REPLACE FUNCTION get_workers(schema_name text)
RETURNS TABLE (
  id uuid,
  username text,
  email text,
  full_name text,
  role text,
  active boolean,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, username, email, full_name, role, active, created_at
     FROM %I.users 
     ORDER BY full_name ASC',
    schema_name
  );
END;
$$;

-- ============================================
-- FUNCIÓN: Guardar reserva en schema
-- ============================================
CREATE OR REPLACE FUNCTION save_reservation(
  schema_name text,
  reservation_id uuid,
  p_customer_name text,
  p_customer_email text,
  p_qr_code text,
  p_total_duration integer,
  p_actual_duration integer,
  p_start_time timestamptz,
  p_end_time timestamptz,
  p_status text,
  p_worker_name text,
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
      start_time, end_time, status, worker_name, group_size, extensions)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
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
       group_size = EXCLUDED.group_size,
       extensions = EXCLUDED.extensions
     RETURNING id',
    schema_name
  ) USING reservation_id, p_customer_name, p_customer_email, p_qr_code, 
          p_total_duration, p_actual_duration, p_start_time, p_end_time, 
          p_status, p_worker_name, p_group_size, p_extensions
  INTO result_id;
  
  RETURN result_id;
END;
$$;

-- ============================================
-- VERIFICAR QUE LAS FUNCIONES SE CREARON
-- ============================================
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_name IN (
  'get_active_reservations',
  'get_reservation_history',
  'get_workers',
  'save_reservation'
)
ORDER BY routine_name;

-- ============================================
-- INSTRUCCIONES
-- ============================================
/*

✅ PASO 1: Ejecuta este script completo en Supabase SQL Editor

✅ PASO 2: Verifica que las 4 funciones se crearon correctamente

✅ PASO 3: El código de la app ya está actualizado para usar estas funciones

✅ PASO 4: Recarga la app y todo debería funcionar

*/



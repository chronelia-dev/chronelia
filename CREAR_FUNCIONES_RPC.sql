-- ============================================
-- CREAR FUNCIONES RPC PARA CHRONELIA
-- ============================================
-- 
-- 📋 INSTRUCCIONES:
-- 1. Abre Supabase Dashboard: https://supabase.com/dashboard
-- 2. Ve a tu proyecto Chronelia
-- 3. Ve a SQL Editor (en el menú lateral)
-- 4. Copia y pega TODO este archivo
-- 5. Haz clic en "Run" (esquina inferior derecha)
-- 6. Verifica que aparezcan las 5 funciones al final
--
-- ============================================

-- ============================================
-- PASO 1: ELIMINAR FUNCIONES ANTIGUAS
-- ============================================
DROP FUNCTION IF EXISTS get_workers(text);
DROP FUNCTION IF EXISTS get_active_reservations(text);
DROP FUNCTION IF EXISTS get_reservation_history(text, integer);
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, integer, integer);
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, uuid, integer, integer);
DROP FUNCTION IF EXISTS login_user(text, text);

-- ============================================
-- FUNCIÓN 1: get_workers
-- Obtener todos los trabajadores de un schema
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
-- FUNCIÓN 2: get_active_reservations
-- Obtener reservas activas de un schema
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
  worker_id uuid,
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
     start_time, end_time, status, worker_name, worker_id, group_size, extensions, created_at
     FROM %I.reservations 
     WHERE status = ''active''
     ORDER BY start_time DESC',
    schema_name
  );
END;
$$;

-- ============================================
-- FUNCIÓN 3: get_reservation_history
-- Obtener historial de reservas de un schema
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
  worker_id uuid,
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
     start_time, end_time, status, worker_name, worker_id, group_size, extensions, created_at
     FROM %I.reservations 
     WHERE status = ''completed''
     ORDER BY end_time DESC
     LIMIT $1',
    schema_name
  ) USING limit_count;
END;
$$;

-- ============================================
-- FUNCIÓN 4: save_reservation
-- Guardar o actualizar una reserva en un schema
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
       extensions = EXCLUDED.extensions
     RETURNING id',
    schema_name
  ) USING reservation_id, p_customer_name, p_customer_email, p_qr_code, 
          p_total_duration, p_actual_duration, p_start_time, p_end_time, 
          p_status, p_worker_name, p_worker_id, p_group_size, p_extensions
  INTO result_id;
  
  RETURN result_id;
END;
$$;

-- ============================================
-- FUNCIÓN 5: login_user
-- Autenticar usuario y retornar información del negocio
-- ============================================
CREATE OR REPLACE FUNCTION login_user(
  input_username text,
  input_password text
)
RETURNS TABLE (
  success boolean,
  message text,
  user_id uuid,
  username text,
  email text,
  full_name text,
  role text,
  schema_name text,
  business_id uuid,
  business_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user RECORD;
  v_business RECORD;
BEGIN
  -- Buscar usuario por username y password
  SELECT users.id, users.username, users.email, users.full_name, users.role, users.business_id
  INTO v_user
  FROM public.users
  WHERE users.username = input_username 
    AND users.password_hash = input_password
    AND users.active = true;

  -- Si no se encuentra el usuario
  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      false, 
      'Usuario o contraseña incorrectos'::text,
      NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, 
      NULL::text, NULL::uuid, NULL::text;
    RETURN;
  END IF;

  -- Obtener información del negocio
  SELECT b.id, b.name, b.schema_name
  INTO v_business
  FROM public.businesses b
  WHERE b.id = v_user.business_id;

  -- Si no se encuentra el negocio
  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      false, 
      'Negocio no encontrado'::text,
      NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, 
      NULL::text, NULL::uuid, NULL::text;
    RETURN;
  END IF;

  -- Login exitoso
  RETURN QUERY SELECT 
    true,
    'Login exitoso'::text,
    v_user.id,
    v_user.username,
    v_user.email,
    v_user.full_name,
    v_user.role,
    v_business.schema_name,
    v_business.id,
    v_business.name;
END;
$$;

-- ============================================
-- VERIFICAR QUE LAS FUNCIONES SE CREARON
-- ============================================
SELECT 
  routine_name as "Función Creada",
  routine_type as "Tipo"
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_workers',
    'get_active_reservations',
    'get_reservation_history',
    'save_reservation',
    'login_user'
  )
ORDER BY routine_name;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- Deberías ver una tabla con 5 funciones:
--
-- | Función Creada              | Tipo     |
-- |-----------------------------|----------|
-- | get_active_reservations     | FUNCTION |
-- | get_reservation_history     | FUNCTION |
-- | get_workers                 | FUNCTION |
-- | login_user                  | FUNCTION |
-- | save_reservation            | FUNCTION |
--
-- ============================================
-- 🎉 ¡LISTO!
-- ============================================
-- Si ves las 5 funciones, todo está correcto.
-- Ahora puedes cerrar esta ventana y recargar la app.


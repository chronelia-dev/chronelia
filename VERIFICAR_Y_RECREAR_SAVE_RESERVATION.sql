-- ============================================
-- VERIFICAR Y RECREAR save_reservation
-- ============================================

-- Paso 1: Ver si la función existe
SELECT 
  routine_name,
  routine_type,
  routine_schema
FROM information_schema.routines
WHERE routine_name = 'save_reservation';

-- Paso 2: Ver los parámetros de la función
SELECT 
  routine_name,
  parameter_name,
  data_type,
  ordinal_position
FROM information_schema.parameters
WHERE specific_schema = 'public'
  AND specific_name LIKE '%save_reservation%'
ORDER BY ordinal_position;

-- Paso 3: Eliminar la función si existe (con todas las posibles firmas)
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, integer, integer) CASCADE;
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, uuid, integer, integer) CASCADE;
DROP FUNCTION IF EXISTS public.save_reservation CASCADE;

-- Paso 4: Crear la función correctamente
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
  -- Log para debug
  RAISE NOTICE 'Guardando reserva en schema: %', schema_name;
  RAISE NOTICE 'ID reserva: %', reservation_id;
  
  -- Insertar o actualizar reserva
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
  ) 
  USING reservation_id, p_customer_name, p_customer_email, p_qr_code,
        p_total_duration, p_actual_duration, p_start_time, p_end_time,
        p_status, p_worker_name, p_worker_id, p_group_size, p_extensions
  INTO result_id;
  
  RAISE NOTICE 'Reserva guardada con ID: %', result_id;
  
  RETURN result_id;
END;
$$;

-- Paso 5: Verificar que se creó correctamente
SELECT 
  '✅ Función creada' as resultado,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_name = 'save_reservation'
  AND routine_schema = 'public';

-- Paso 6: Probar la función manualmente
SELECT save_reservation(
  'somacafe',                                    -- schema_name
  gen_random_uuid(),                             -- reservation_id (genera uno nuevo)
  'Cliente Prueba Manual',                       -- customer_name
  'prueba@test.com',                             -- customer_email
  'TEST-MANUAL-' || floor(random() * 1000000),   -- qr_code
  3600,                                          -- total_duration (60 min en segundos)
  NULL,                                          -- actual_duration
  now(),                                         -- start_time
  NULL,                                          -- end_time
  'active',                                      -- status
  'Admin SomaCafe',                              -- worker_name
  NULL,                                          -- worker_id
  1,                                             -- group_size
  0                                              -- extensions
) as "ID Reserva Creada";

-- Paso 7: Ver la reserva creada
SELECT 
  '✅ Reservas en somacafe.reservations' as verificacion,
  id,
  customer_name,
  status,
  start_time
FROM somacafe.reservations
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- Deberías ver:
-- 1. La función save_reservation creada en public
-- 2. Un UUID de la reserva de prueba creada
-- 3. La reserva listada en somacafe.reservations
-- ============================================


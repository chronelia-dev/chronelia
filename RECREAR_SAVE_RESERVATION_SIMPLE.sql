-- ============================================
-- RECREAR save_reservation (SIMPLIFICADO)
-- ============================================
-- Este script simplemente elimina y recrea la función
-- ============================================

-- Paso 1: Eliminar todas las versiones de la función
DROP FUNCTION IF EXISTS save_reservation CASCADE;
DROP FUNCTION IF EXISTS public.save_reservation CASCADE;

-- Paso 2: Crear la función correctamente
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
  -- Insertar o actualizar reserva en el schema del negocio
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
  
  RETURN result_id;
END;
$$;

-- Paso 3: Probar la función con una reserva de prueba
SELECT save_reservation(
  'somacafe',                                    -- schema_name (ajusta si es diferente)
  gen_random_uuid(),                             -- reservation_id
  'Cliente Prueba',                              -- customer_name
  'prueba@test.com',                             -- customer_email
  'TEST-' || floor(random() * 1000000)::text,    -- qr_code
  3600,                                          -- total_duration (60 min)
  NULL,                                          -- actual_duration
  now(),                                         -- start_time
  NULL,                                          -- end_time
  'active',                                      -- status
  'Admin SomaCafe',                              -- worker_name
  NULL,                                          -- worker_id
  1,                                             -- group_size
  0                                              -- extensions
) as "✅ ID de Reserva Creada";

-- Paso 4: Ver las reservas en la tabla
SELECT 
  '✅ RESERVAS CREADAS' as seccion,
  id,
  customer_name,
  status,
  worker_name,
  start_time
FROM somacafe.reservations
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- ✅ SI VES UN UUID Y UNA RESERVA LISTADA, 
--    ¡LA FUNCIÓN ESTÁ FUNCIONANDO!
-- ============================================


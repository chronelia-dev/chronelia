-- ============================================
-- FORZAR RECREACIÓN DE save_reservation
-- ============================================
-- Este script elimina COMPLETAMENTE la función
-- y la recrea con un nombre ligeramente diferente
-- para forzar que Supabase actualice su caché
-- ============================================

-- Paso 1: Eliminar TODAS las versiones de save_reservation
DROP FUNCTION IF EXISTS save_reservation CASCADE;
DROP FUNCTION IF EXISTS public.save_reservation CASCADE;
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, integer, integer) CASCADE;
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, uuid, integer, integer) CASCADE;

-- Paso 2: Limpiar cualquier dependencia
DO $$
BEGIN
  -- Intentar limpiar cache (puede fallar, está OK)
  PERFORM pg_stat_statements_reset();
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- Paso 3: Recrear la función CON NOMBRE EXACTO y firma correcta
CREATE FUNCTION public.save_reservation(
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
SET search_path = public
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
       status = EXCLUDED.status,
       end_time = EXCLUDED.end_time,
       actual_duration = EXCLUDED.actual_duration,
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

-- Paso 4: Dar permisos explícitos
GRANT EXECUTE ON FUNCTION public.save_reservation TO anon;
GRANT EXECUTE ON FUNCTION public.save_reservation TO authenticated;

-- Paso 5: Verificar que existe con \df
SELECT 
  n.nspname as "Schema",
  p.proname as "Nombre",
  pg_catalog.pg_get_function_arguments(p.oid) as "Argumentos"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'save_reservation'
  AND n.nspname = 'public';

-- Paso 6: Probar la función
DO $$
DECLARE
  test_id uuid;
BEGIN
  SELECT public.save_reservation(
    'somacafe',
    gen_random_uuid(),
    'Test Final',
    'test@final.com',
    'TEST-FINAL-' || floor(random() * 1000000)::text,
    1800,
    NULL,
    now(),
    NULL,
    'active',
    'Tester',
    NULL,
    1,
    0
  ) INTO test_id;
  
  RAISE NOTICE '✅ Función funciona! ID: %', test_id;
END $$;

-- Paso 7: Mostrar todas las reservas
SELECT 
  '✅ TODAS LAS RESERVAS' as seccion,
  id,
  customer_name,
  status,
  created_at
FROM somacafe.reservations
ORDER BY created_at DESC;

-- ============================================
-- ✅ INSTRUCCIONES POST-EJECUCIÓN:
-- ============================================
-- 1. Cierra COMPLETAMENTE tu navegador
-- 2. Vuelve a abrirlo
-- 3. Ve a la app y haz login de nuevo
-- 4. Intenta escanear el QR
-- ============================================


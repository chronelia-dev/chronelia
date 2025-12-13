-- ============================================
-- LIMPIAR RESERVAS DE PRUEBA
-- ============================================
-- Este script elimina todas las reservas de prueba
-- y deja la base de datos limpia
-- ============================================

-- Ver las reservas actuales
SELECT 
  '🔍 RESERVAS ACTUALES' as seccion,
  id,
  customer_name,
  status,
  start_time,
  created_at
FROM somacafe.reservations
ORDER BY created_at DESC;

-- Eliminar TODAS las reservas de prueba
DELETE FROM somacafe.reservations;

-- Verificar que se eliminaron
SELECT 
  '✅ DESPUÉS DE LIMPIAR' as seccion,
  COUNT(*) as "Total de Reservas"
FROM somacafe.reservations;

-- ============================================
-- AHORA RECARGA LA APP
-- ============================================
-- 1. Presiona Ctrl + Shift + R en el navegador
-- 2. Haz login nuevamente
-- 3. El dashboard debería mostrar "No hay reservas activas"
-- 4. Escanea un QR real para crear una reserva nueva
-- ============================================

-- ============================================
-- VERIFICAR FUNCIÓN get_active_reservations
-- ============================================
SELECT 
  '🔍 PROBANDO get_active_reservations' as test,
  *
FROM get_active_reservations('somacafe');

-- Debería retornar 0 filas después de limpiar


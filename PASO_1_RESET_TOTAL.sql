-- ============================================
-- PASO 1: RESET TOTAL - LIMPIAR TODO
-- ============================================
-- Este script ELIMINA TODO de la base de datos
-- Ejecútalo primero para empezar desde cero

-- Eliminar todos los schemas de negocios que existan
DROP SCHEMA IF EXISTS locosxcerveza CASCADE;
DROP SCHEMA IF EXISTS elrefugio CASCADE;
DROP SCHEMA IF EXISTS laperlita CASCADE;
-- Agrega aquí cualquier otro schema que tengas

-- Eliminar tablas en public
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;

-- Eliminar todas las funciones RPC
DROP FUNCTION IF EXISTS save_reservation CASCADE;
DROP FUNCTION IF EXISTS get_active_reservations CASCADE;
DROP FUNCTION IF EXISTS get_reservation_history CASCADE;
DROP FUNCTION IF EXISTS get_workers CASCADE;
DROP FUNCTION IF EXISTS login_user CASCADE;

-- Verificación
SELECT '✅ Base de datos limpia - Lista para configurar' as status;

-- ============================================
-- SIGUIENTE PASO: 
-- Ejecuta PASO_2_CONFIGURAR_BASE_MULTI_TENANT.sql
-- ============================================


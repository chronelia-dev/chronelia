-- ============================================
-- DIAGNÓSTICO DE BASE DE DATOS
-- ============================================
-- Ejecuta este script para ver qué falta en tu BD
-- ============================================

-- 1. ¿Existe la tabla public.businesses?
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'businesses'
    ) 
    THEN '✅ Tabla public.businesses existe'
    ELSE '❌ Tabla public.businesses NO existe'
  END as resultado;

-- 2. ¿Existe la tabla public.users?
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'users'
    ) 
    THEN '✅ Tabla public.users existe'
    ELSE '❌ Tabla public.users NO existe'
  END as resultado;

-- 3. ¿Qué columnas tiene la tabla public.users?
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- 4. ¿Qué columnas tiene la tabla public.businesses?
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'businesses'
ORDER BY ordinal_position;

-- 5. ¿Cuántos negocios hay?
SELECT COUNT(*) as "Cantidad de Negocios" FROM public.businesses;

-- 6. ¿Cuántos usuarios hay?
SELECT COUNT(*) as "Cantidad de Usuarios" FROM public.users;

-- 7. Ver usuarios existentes (sin passwords)
SELECT id, username, email, full_name, role, business_id, active 
FROM public.users;

-- 8. Ver negocios existentes
SELECT id, name, schema_name, created_at 
FROM public.businesses;


-- ============================================
-- COMANDOS SIMPLES PARA DIAGNOSTICAR
-- ============================================
-- Ejecuta cada uno por separado y copia el resultado

-- ============================================
-- 1. Ver usuarios en el mapeo
-- ============================================
SELECT * FROM public.user_business_map;

-- ============================================
-- 2. Ver usuarios en business_prueba
-- ============================================
SELECT username, password_hash, email, full_name, role, active 
FROM business_prueba.users;

-- ============================================
-- 3. Probar login con admin
-- ============================================
SELECT * FROM login_user('admin', 'admin123');

-- ============================================
-- 4. Ver negocios
-- ============================================
SELECT schema_name, business_name, active FROM public.businesses;

-- ============================================
-- 5. Verificar si la función existe
-- ============================================
SELECT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'login_user');









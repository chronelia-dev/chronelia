-- ============================================
-- CHRONELIA - MULTI-TENANT CON SCHEMAS
-- PARTE 2: CREAR NEGOCIOS Y USUARIOS
-- ============================================
-- EJECUTAR ESTE SCRIPT DESPUÉS DEL PASO 1

-- ============================================
-- 1. CREAR NEGOCIOS
-- ============================================

-- Negocio 1: Demo Chronelia
SELECT create_business_schema(
  'business_demo',
  'Demo Chronelia',
  'demo@chronelia.com',
  '+34 600 000 000',
  'Calle Demo 123, Madrid',
  'premium',
  20
);

-- Negocio 2: Restaurante La Bella Vista
SELECT create_business_schema(
  'business_bella',
  'Restaurante La Bella Vista',
  'contacto@labellavista.com',
  '+34 91 555 1234',
  'Plaza Mayor 15, Madrid',
  'basic',
  5
);

-- Negocio 3: Spa & Wellness Center
SELECT create_business_schema(
  'business_spa',
  'Spa & Wellness Center',
  'info@spawellness.com',
  '+34 93 444 5678',
  'Avenida Diagonal 500, Barcelona',
  'premium',
  15
);

-- ============================================
-- 2. CREAR USUARIOS
-- ============================================

-- Usuarios para Demo Chronelia
SELECT create_business_user('business_demo', 'admin', 'admin@chronelia.com', 'chronelia2025', 'Administrador Demo', 'admin');
SELECT create_business_user('business_demo', 'trabajador', 'trabajador@chronelia.com', 'trabajador123', 'Juan Trabajador', 'worker');

-- Usuarios para Restaurante
SELECT create_business_user('business_bella', 'admin_bella', 'admin@labellavista.com', 'bella2025', 'Admin Bella Vista', 'admin');
SELECT create_business_user('business_bella', 'mesero_carlos', 'carlos@labellavista.com', 'carlos123', 'Carlos Mesero', 'worker');

-- Usuarios para Spa
SELECT create_business_user('business_spa', 'admin_spa', 'admin@spawellness.com', 'spa2025', 'Admin Spa Wellness', 'admin');
SELECT create_business_user('business_spa', 'terapeuta_ana', 'ana@spawellness.com', 'ana123', 'Ana Terapeuta', 'worker');

-- ============================================
-- 3. VERIFICAR CONFIGURACIÓN
-- ============================================

-- Ver negocios creados
SELECT 
  '=== NEGOCIOS CREADOS ===' as info,
  schema_name,
  business_name,
  plan_type,
  max_workers
FROM public.businesses
ORDER BY created_at;

-- Ver usuarios por negocio
SELECT '=== USUARIOS DEMO CHRONELIA ===' as info, username, email, full_name, role FROM business_demo.users;
SELECT '=== USUARIOS RESTAURANTE ===' as info, username, email, full_name, role FROM business_bella.users;
SELECT '=== USUARIOS SPA ===' as info, username, email, full_name, role FROM business_spa.users;

-- Ver mapeo de usuarios
SELECT 
  '=== MAPEO DE USUARIOS ===' as info,
  username,
  schema_name,
  business_name
FROM public.user_business_map
ORDER BY schema_name, username;

-- ============================================
-- ✅ CONFIGURACIÓN COMPLETADA
-- ============================================

/*

USUARIOS DE PRUEBA CREADOS:

Demo Chronelia (schema: business_demo):
  - admin / chronelia2025
  - trabajador / trabajador123

Restaurante La Bella Vista (schema: business_bella):
  - admin_bella / bella2025
  - mesero_carlos / carlos123

Spa & Wellness (schema: business_spa):
  - admin_spa / spa2025
  - terapeuta_ana / ana123

CÓMO VER EN SUPABASE:
1. Ve a Table Editor
2. Cambia el selector "Schema" a: business_demo, business_bella o business_spa
3. Verás las tablas de cada negocio por separado

PARA AGREGAR NUEVO CLIENTE:
SELECT create_business_schema('business_nuevo', 'Nuevo Negocio');
SELECT create_business_user('business_nuevo', 'admin_nuevo', 'admin@nuevo.com', 'password', 'Admin', 'admin');

*/





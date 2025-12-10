-- ============================================
-- FIX RÁPIDO: Agregar columna 'active' a businesses
-- ============================================
-- El login necesita la columna 'active' en la tabla businesses

-- Agregar columna 'active' a la tabla businesses
ALTER TABLE public.businesses 
ADD COLUMN IF NOT EXISTS active boolean DEFAULT true;

-- Actualizar todos los negocios existentes como activos
UPDATE public.businesses 
SET active = true 
WHERE active IS NULL;

-- Verificar que se agregó correctamente
SELECT 
  '✅ Columna active agregada' as resultado,
  name,
  schema_name,
  active
FROM public.businesses;

-- ============================================
-- LISTO: Ahora intenta iniciar sesión de nuevo
-- ============================================


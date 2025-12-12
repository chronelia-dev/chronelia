-- ============================================
-- PROBAR EXACTAMENTE COMO LO LLAMA LA APP
-- ============================================

-- Ver el formato exacto de respuesta
SELECT * FROM login_user('admin', 'admin123');

-- Ver el tipo de dato que retorna
SELECT 
  pg_typeof(success) as tipo_success,
  pg_typeof(message) as tipo_message,
  pg_typeof(user_id) as tipo_user_id
FROM login_user('admin', 'admin123');

-- Ver si retorna una sola fila o varias
SELECT COUNT(*) as numero_de_filas
FROM login_user('admin', 'admin123');









# ⚡ INICIO RÁPIDO - CHRONELIA PRODUCCIÓN

## 🎯 3 PASOS PARA COMENZAR

---

### 📝 PASO 1: CONFIGURAR SUPABASE (5 minutos)

1. Ve a: **https://supabase.com/dashboard**
2. Abre tu proyecto de Chronelia
3. Clic en **SQL Editor** (icono de código en el menú izquierdo)
4. Clic en **+ New Query**
5. Abre el archivo: `SETUP_PRODUCCION_SUPABASE.sql`
6. Copia TODO el contenido
7. Pégalo en el editor de Supabase
8. Clic en **▶ Run** (esquina inferior derecha)
9. Espera a que aparezca: **"Success. No rows returned"**

**✅ ¡Listo!** Usuario admin creado en la base de datos.

---

### 📱 PASO 2: INSTALAR APP (2 minutos)

1. Conecta tu móvil Android al PC
2. Copia el archivo a tu móvil:
   ```
   Chronelia-PRODUCCION-v2.0.apk
   ```
3. En el móvil, busca el archivo y toca para instalar
4. Si pregunta por permisos, acepta "Instalar apps desconocidas"
5. Toca **Instalar**

**✅ ¡Instalada!** Ícono de Chronelia en tu pantalla.

---

### 🔐 PASO 3: PRIMER LOGIN (1 minuto)

1. Abre **Chronelia** en tu móvil
2. Ingresa:
   ```
   Usuario: admin
   Contraseña: chronelia2025
   ```
3. Toca **Iniciar Sesión**

**✅ ¡Dentro!** Ya estás en el panel de administrador.

---

## 🎉 ¡CONFIGURACIÓN COMPLETADA!

Ahora puedes:
- ✅ Crear trabajadores
- ✅ Gestionar reservas
- ✅ Ver estadísticas en tiempo real
- ✅ Recibir notificaciones
- ✅ Ver recomendaciones de IA

---

## 👥 CREAR PRIMER TRABAJADOR

1. En la app, ve a: **☰ Menu** → **Panel Admin** → **Gestión de Trabajadores**
2. Toca **+ Agregar Trabajador**
3. Completa:
   - **Nombre:** Juan Pérez
   - **Username:** juanp (sin espacios)
   - **Email:** juan@chronelia.com
   - **Contraseña:** juan123
4. Toca **Agregar Trabajador**

**✅ Trabajador creado** y guardado en Supabase.

Para que el trabajador use la app:
1. Dale las credenciales: `juanp` / `juan123`
2. Que descargue la app en su móvil
3. Que inicie sesión con su usuario

---

## 📊 CREAR PRIMERA RESERVA

1. En el Dashboard, toca **+ Nueva Reserva**
2. Completa:
   - **Cliente:** María González
   - **Teléfono:** 555-1234
   - **Tiempo:** 30 minutos
3. Toca **Crear Reserva**

**✅ Reserva activa** y guardada en Supabase.

La app:
- ⏰ Mostrará el contador en tiempo real
- 🔔 Notificará 5 minutos antes de terminar
- 📊 Actualizará las estadísticas automáticamente

---

## 🔍 VERIFICAR QUE TODO FUNCIONA

### En la App:
1. ✅ Dashboard muestra reserva activa
2. ✅ Recomendaciones IA aparecen (5 cards deslizables)
3. ✅ Contador de tiempo funciona
4. ✅ Notificación suena a los 5 minutos

### En Supabase:
1. Ve a: **Table Editor** → **reservations**
2. Deberías ver la reserva de María González
3. Ve a: **Table Editor** → **users**
4. Deberías ver: admin + el trabajador que creaste

**Si todo está ahí:** ✅ ¡PERFECTO! Todo funciona.

---

## ⚠️ ¿PROBLEMAS?

### No puedo iniciar sesión
```
❌ "Usuario o contraseña incorrectos"
```
**Solución:**
1. Verifica que ejecutaste el script SQL en Supabase
2. Usa exactamente: `admin` / `chronelia2025` (sin espacios)
3. Verifica conexión a internet en el móvil

---

### Los datos no se guardan
```
❌ Los trabajadores/reservas no aparecen en Supabase
```
**Solución:**
1. Ve a Supabase → **Settings** → **API**
2. Verifica que las credenciales en `.env` coincidan
3. En la app, abre chrome://inspect para ver errores

---

### La app se superpone con la barra
```
⚠️ La barra de Android cubre parte de la app
```
**Solución:**
1. Asegúrate de tener instalada v2.0
2. Desinstala la versión anterior
3. Instala de nuevo desde el archivo .apk

---

## 📁 ARCHIVOS DE REFERENCIA

Si necesitas más información:

| Archivo | Para qué sirve |
|---------|----------------|
| `SETUP_PRODUCCION_SUPABASE.sql` | Script para configurar la base de datos |
| `INSTRUCCIONES_PRODUCCION.md` | Guía detallada completa |
| `CAMBIOS_V2.0_PRODUCCION.md` | Listado de todos los cambios técnicos |
| `INICIO_RAPIDO_PRODUCCION.md` | Esta guía rápida |

---

## 🚀 ¡LISTO PARA PRODUCCIÓN!

Ya tienes todo configurado para comenzar a usar Chronelia con datos reales.

**Recuerda:**
- 🔒 Cambia la contraseña del admin después del primer uso
- 💾 Todos los datos se guardan automáticamente en la nube
- 📊 Revisa las estadísticas cada semana
- 🤖 Las recomendaciones IA mejoran con el uso

---

**¿Listo para comenzar?** 🎉

1. ✅ Supabase configurado
2. ✅ App instalada
3. ✅ Primer login exitoso

**→ ¡Empieza a usar Chronelia! 🚀**


















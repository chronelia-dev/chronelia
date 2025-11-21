# 🌐 Guía de Despliegue - Chronelia Web Admin

Esta guía explica cómo desplegar la versión web administrativa de Chronelia en producción con el dominio **chronelia.online**.

## 🎯 Arquitectura del Sistema

```
┌─────────────────────────────────────────────┐
│         CHRONELIA ECOSYSTEM                  │
├─────────────────────────────────────────────┤
│                                              │
│  🌐 chronelia.online (WEB)                   │
│  └── Solo ADMINISTRADORES                    │
│      ├── Panel de control completo           │
│      ├── Gestión de trabajadores             │
│      ├── Estadísticas avanzadas              │
│      ├── Recomendaciones IA                  │
│      └── Chat IA                             │
│                                              │
│  📱 APK Android (MOBILE)                     │
│  └── Solo TRABAJADORES                       │
│      ├── Dashboard de reservas               │
│      ├── Scanner QR                          │
│      ├── Gestión básica                      │
│      └── Notificaciones                      │
│                                              │
│  ☁️ Supabase (Backend)                       │
│  └── Base de datos compartida                │
└─────────────────────────────────────────────┘
```

## 📋 Requisitos Previos

- ✅ Cuenta en [Vercel](https://vercel.com) (gratis)
- ✅ Repositorio GitHub: `https://github.com/pedromillorconsult-dev/chronelia`
- ✅ Dominio: `chronelia.online` (Hostinger)
- ✅ Supabase configurado y activo

## 🚀 Pasos de Despliegue

### 1️⃣ Desplegar en Vercel

#### Opción A: Desde la Web (Recomendado)

1. **Accede a Vercel:**
   - Ve a: [https://vercel.com/new](https://vercel.com/new)
   - Inicia sesión con GitHub

2. **Importar Repositorio:**
   - Click en "Import Project"
   - Selecciona: `pedromillorconsult-dev/chronelia`
   - Click en "Import"

3. **Configurar Proyecto:**
   - **Project Name:** `chronelia-web-admin`
   - **Framework Preset:** Vite
   - **Root Directory:** `.` (dejar por defecto)
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`

4. **Variables de Entorno:**
   
   Click en "Environment Variables" y agrega:
   
   ```env
   VITE_SUPABASE_URL=https://uzqtqflrhhjkcpkyfjoa.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6cXRxZmxyaGhqa2Nwa3lmam9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4Nzk0OTYsImV4cCI6MjA3NjQ1NTQ5Nn0.tt_wAEnUqOxgaOrNYVgNo77ju64xdbMKyHdgPGG9Bvs
   VITE_APP_MODE=web_admin
   ```

5. **Deploy:**
   - Click en "Deploy"
   - Espera 2-3 minutos ⏳
   - ¡Listo! 🎉

#### Opción B: Desde CLI

```bash
# Instalar Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### 2️⃣ Conectar Dominio Personalizado (chronelia.online)

Una vez desplegado en Vercel:

1. **En Vercel Dashboard:**
   - Ve a tu proyecto `chronelia-web-admin`
   - Click en "Settings" → "Domains"
   - Click en "Add Domain"
   - Ingresa: `chronelia.online`
   - Click en "Add"

2. **Vercel te mostrará los DNS que necesitas configurar:**

   ```
   Tipo: A
   Nombre: @
   Valor: 76.76.21.21
   
   Tipo: CNAME
   Nombre: www
   Valor: cname.vercel-dns.com
   ```

3. **Configurar DNS en Hostinger:**
   
   - Ve a: [https://hpanel.hostinger.com](https://hpanel.hostinger.com)
   - Login con tus credenciales
   - Selecciona el dominio `chronelia.online`
   - Ve a "DNS Zone"
   - Borra los registros A y CNAME existentes
   - Agrega los nuevos registros que te dio Vercel:
     
     **Registro 1:**
     - Type: `A`
     - Name: `@`
     - Points to: `76.76.21.21`
     - TTL: `14400` (4 horas)
     
     **Registro 2:**
     - Type: `CNAME`
     - Name: `www`
     - Points to: `cname.vercel-dns.com`
     - TTL: `14400`

4. **Guardar y Esperar:**
   - Click en "Save" o "Update"
   - La propagación DNS tarda **5 minutos a 48 horas**
   - Normalmente en 10-30 minutos ya funciona

5. **Verificar:**
   - Vuelve a Vercel
   - El dominio debería mostrar "Valid Configuration" ✅
   - Vercel automáticamente generará un certificado SSL (HTTPS)

### 3️⃣ Verificar Despliegue

Una vez completado:

- ✅ **URL Vercel:** `https://chronelia-web-admin.vercel.app`
- ✅ **Dominio:** `https://chronelia.online` (después de propagación DNS)
- ✅ **SSL:** Automático con Vercel
- ✅ **Deploy automático:** Cada push a `main` despliega automáticamente

## 🔐 Credenciales de Prueba

### Para Administradores (Web)

Para crear un usuario admin en Supabase:

```sql
-- Ejecutar en Supabase SQL Editor
INSERT INTO users (username, email, password_hash, full_name, role, active)
VALUES ('admin', 'admin@chronelia.online', 'admin123', 'Administrador', 'admin', true);
```

**Login:**
- Usuario: `admin`
- Contraseña: `admin123`

## 📊 Monitoreo y Análisis

Vercel incluye automáticamente:

- 📈 **Analytics:** Tráfico y rendimiento
- 🐛 **Error Tracking:** Errores en producción
- ⚡ **Performance Insights:** Métricas de velocidad
- 🌍 **CDN Global:** Distribución mundial

Accede desde: Dashboard → Tu Proyecto → Analytics

## 🔄 Actualizar la Aplicación

Cada vez que hagas cambios:

```bash
# 1. Hacer cambios en el código
# 2. Commit
git add .
git commit -m "Descripción del cambio"

# 3. Push a GitHub
git push origin main

# 4. Vercel despliega automáticamente ✨
```

## 🛠️ Comandos Útiles

```bash
# Ver logs de producción
vercel logs

# Revertir a un deploy anterior
vercel rollback

# Ver información del proyecto
vercel project

# Agregar variable de entorno
vercel env add NOMBRE_VARIABLE
```

## 🔧 Troubleshooting

### El dominio no funciona después de 24 horas

1. Verifica los DNS en Hostinger
2. Usa [https://dnschecker.org](https://dnschecker.org) para ver propagación
3. Borra caché del navegador: `Ctrl + Shift + R`

### Error "Build Failed"

1. Verifica que las variables de entorno estén correctas
2. Revisa los logs en Vercel Dashboard
3. Prueba el build localmente: `npm run build`

### No puedo hacer login

1. Verifica que Supabase esté activo
2. Revisa las credenciales en la base de datos
3. Abre la consola del navegador (F12) para ver errores

## 📱 Diferencias entre Web y APK

| Característica | Web (chronelia.online) | APK (Android) |
|---|---|---|
| **Usuarios** | Solo Administradores | Solo Trabajadores |
| **Panel Admin** | ✅ Sí | ❌ No |
| **Gestión Trabajadores** | ✅ Sí | ❌ No |
| **IA y Recomendaciones** | ✅ Sí | ❌ No |
| **Scanner QR** | ✅ Sí | ✅ Sí |
| **Reservas** | ✅ Ver todas | ✅ Solo las propias |
| **Estadísticas** | ✅ Avanzadas | ✅ Básicas |

## 🎯 Próximos Pasos

Después del despliegue:

- [ ] Crear usuarios admin en Supabase
- [ ] Probar login desde chronelia.online
- [ ] Configurar Google Analytics (opcional)
- [ ] Configurar backup automático de Supabase
- [ ] Documentar credenciales de trabajadores

## 📞 Soporte

- **Vercel Docs:** [https://vercel.com/docs](https://vercel.com/docs)
- **Supabase Docs:** [https://supabase.com/docs](https://supabase.com/docs)
- **Hostinger Support:** [https://www.hostinger.com/contact](https://www.hostinger.com/contact)

---

**¡Listo para producción! 🚀**


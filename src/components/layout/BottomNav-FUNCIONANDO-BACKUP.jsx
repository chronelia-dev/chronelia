/**
 * ========================================
 * BACKUP DE CONFIGURACIÓN QUE FUNCIONA
 * ========================================
 * 
 * Fecha: Diciembre 10, 2025
 * Estado: ✅ FUNCIONANDO PERFECTAMENTE EN ANDROID
 * 
 * IMPORTANTE: Este archivo es un BACKUP de seguridad.
 * La configuración en este archivo FUNCIONA correctamente.
 * 
 * Si el BottomNav.jsx original se rompe, RESTAURA desde este archivo.
 * 
 * CARACTERÍSTICAS:
 * - Botón "Escanear" abre cámara nativa directamente en Android/iOS
 * - Usa BarcodeScanner.scan() de ML Kit
 * - Pantalla completa nativa
 * - Sin modales, sin AnimatePresence
 * - Procesa QR y crea reservas automáticamente
 * - En web navega a /scan
 * 
 * NO MODIFICAR ESTE ARCHIVO
 * ========================================
 */

import { NavLink, useNavigate } from 'react-router-dom'
import { QrCode, LayoutDashboard, BarChart3, History, Settings } from 'lucide-react'
import { motion } from 'framer-motion'
import { cn } from '@/lib/utils'
import { BarcodeScanner } from '@capacitor-mlkit/barcode-scanning'
import { Capacitor } from '@capacitor/core'
import useStore from '@/store/useStore'
import { toast } from 'sonner'

const navItems = [
  {
    title: 'Inicio',
    icon: LayoutDashboard,
    path: '/',
  },
  {
    title: 'Stats',
    icon: BarChart3,
    path: '/stats',
  },
  {
    title: 'Historial',
    icon: History,
    path: '/history',
  },
  {
    title: 'Ajustes',
    icon: Settings,
    path: '/settings',
  },
]

export default function BottomNav() {
  const navigate = useNavigate()
  const { addReservation, user } = useStore()

  // Función para escanear QR directamente
  const handleScanQR = async () => {
    const platform = Capacitor.getPlatform()
    const isNative = platform === 'android' || platform === 'ios'

    console.log('🎯 Abriendo escáner QR directo...')
    console.log('📱 Plataforma:', platform, '- Nativa:', isNative)

    if (isNative) {
      // En app nativa: abrir ML Kit directamente (pantalla completa nativa)
      try {
        console.log('📷 Solicitando permisos...')
        const permissionResult = await BarcodeScanner.requestPermissions()
        
        if (permissionResult.camera !== 'granted' && permissionResult.camera !== 'limited') {
          toast.error('Permiso de cámara denegado')
          return
        }

        console.log('📸 Abriendo escáner nativo ML Kit...')
        document.body.classList.add('qr-scanning')
        
        // Esto abre la cámara nativa en pantalla completa
        const result = await BarcodeScanner.scan({
          formats: ['QR_CODE'],
        })
        
        console.log('✅ Resultado:', result)
        
        if (result && result.barcodes && result.barcodes.length > 0) {
          const code = result.barcodes[0].rawValue || result.barcodes[0].displayValue
          console.log('📋 Código QR:', code)
          
          // Procesar el QR
          try {
            const data = JSON.parse(code)
            
            if (!data.clientName || !data.duration) {
              throw new Error('Datos incompletos en el QR')
            }

            addReservation({
              clientName: data.clientName,
              clientEmail: data.clientEmail || 'sin-email@ejemplo.com',
              qrCode: data.code || code,
              totalDuration: data.duration * 60,
              groupSize: data.groupSize || 1,
              worker: user?.user_metadata?.full_name || user?.email || 'Trabajador',
            })

            toast.success('✅ ¡Reserva activada!', {
              description: `${data.clientName} - ${data.duration} minutos`,
            })
          } catch (error) {
            console.error('Error al procesar QR:', error)
            toast.error('Código QR inválido')
          }
        }
        
      } catch (error) {
        console.error('Error en escáner:', error)
        if (error.message?.includes('cancel')) {
          toast.info('Escaneo cancelado')
        } else {
          toast.error('Error al escanear')
        }
      } finally {
        document.body.classList.remove('qr-scanning')
      }
    } else {
      // En web: navegar a la página /scan
      navigate('/scan')
    }
  }

  return (
    <>
      <nav className="fixed bottom-0 left-0 right-0 z-50 md:hidden">
        {/* Fondo con blur */}
        <div className="absolute inset-0 bg-background/80 backdrop-blur-xl border-t shadow-2xl" />
        
        <div className="relative flex items-center justify-center h-20 px-2">
          {/* Botones laterales */}
          <div className="flex items-center justify-around flex-1 max-w-md">
            {/* Lado izquierdo (2 botones) */}
            {navItems.slice(0, 2).map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) =>
                  cn(
                    'flex flex-col items-center justify-center w-16 h-16 transition-all',
                    isActive ? 'text-primary' : 'text-muted-foreground'
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <motion.div
                      whileTap={{ scale: 0.9 }}
                      className="flex flex-col items-center"
                    >
                      <item.icon 
                        className={cn(
                          "h-6 w-6 mb-1 transition-all",
                          isActive ? "scale-110" : ""
                        )} 
                        strokeWidth={isActive ? 2.5 : 2}
                      />
                      <span className={cn(
                        "text-xs font-medium transition-all",
                        isActive ? "scale-105 font-semibold" : ""
                      )}>
                        {item.title}
                      </span>
                    </motion.div>
                  </>
                )}
              </NavLink>
            ))}

            {/* Espacio para el botón central */}
            <div className="w-24" />

            {/* Lado derecho (2 botones) */}
            {navItems.slice(2).map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) =>
                  cn(
                    'flex flex-col items-center justify-center w-16 h-16 transition-all',
                    isActive ? 'text-primary' : 'text-muted-foreground'
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <motion.div
                      whileTap={{ scale: 0.9 }}
                      className="flex flex-col items-center"
                    >
                      <item.icon 
                        className={cn(
                          "h-6 w-6 mb-1 transition-all",
                          isActive ? "scale-110" : ""
                        )} 
                        strokeWidth={isActive ? 2.5 : 2}
                      />
                      <span className={cn(
                        "text-xs font-medium transition-all",
                        isActive ? "scale-105 font-semibold" : ""
                      )}>
                        {item.title}
                      </span>
                    </motion.div>
                  </>
                )}
              </NavLink>
            ))}
          </div>

          {/* Botón central flotante de Escanear - Abre cámara directamente */}
          <button
            onClick={handleScanQR}
            className="absolute left-1/2 -translate-x-1/2 -top-6 flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-pink-500 to-purple-600 text-white shadow-2xl active:scale-95 transition-transform"
            style={{ transformOrigin: 'center center' }}
          >
            <div className="flex flex-col items-center relative z-10">
              <QrCode className="h-8 w-8 mb-1" strokeWidth={2.5} />
              <span className="text-xs font-bold">Escanear</span>
            </div>
            {/* Efecto de pulso */}
            <motion.div
              className="absolute inset-0 rounded-full bg-gradient-to-br from-pink-500 to-purple-600 pointer-events-none"
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.5, 0, 0.5],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
            />
          </button>
        </div>
      </nav>
    </>
  )
}


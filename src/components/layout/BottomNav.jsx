import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import { QrCode, LayoutDashboard, BarChart3, History, Settings } from 'lucide-react'
import { motion } from 'framer-motion'
import { cn } from '@/lib/utils'
import QRScannerModal from '@/components/QRScannerModal'

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
  const [scannerOpen, setScannerOpen] = useState(false)

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

          {/* Botón central flotante de Escanear */}
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => setScannerOpen(true)}
            className="absolute left-1/2 -translate-x-1/2 -top-6 flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-pink-500 to-purple-600 text-white shadow-2xl"
          >
            <div className="flex flex-col items-center">
              <QrCode className="h-8 w-8 mb-1" strokeWidth={2.5} />
              <span className="text-xs font-bold">Escanear</span>
            </div>
            {/* Efecto de pulso */}
            <motion.div
              className="absolute inset-0 rounded-full bg-gradient-to-br from-pink-500 to-purple-600"
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
          </motion.button>
        </div>
      </nav>

      {/* Modal del escáner */}
      <QRScannerModal 
        isOpen={scannerOpen} 
        onClose={() => setScannerOpen(false)} 
      />
    </>
  )
}


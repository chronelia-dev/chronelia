import { NavLink } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  LayoutDashboard,
  BarChart3,
  History,
  Settings,
  QrCode,
  Users,
  Shield,
  Sparkles,
} from 'lucide-react'
import useStore from '@/store/useStore'
import { cn } from '@/lib/utils'

const workerMenuItems = [
  {
    title: 'Dashboard',
    icon: LayoutDashboard,
    path: '/',
  },
  {
    title: 'Escanear QR',
    icon: QrCode,
    path: '/scan',
  },
  {
    title: 'Estadísticas',
    icon: BarChart3,
    path: '/stats',
  },
  {
    title: 'Historial',
    icon: History,
    path: '/history',
  },
  {
    title: 'Configuración',
    icon: Settings,
    path: '/settings',
  },
]

const adminMenuItems = [
  {
    title: 'Dashboard',
    icon: LayoutDashboard,
    path: '/',
  },
  {
    title: 'Recomendaciones IA',
    icon: Sparkles,
    path: '/recommendations',
  },
  {
    title: 'Panel Admin',
    icon: Shield,
    path: '/admin',
  },
  {
    title: 'Trabajadores',
    icon: Users,
    path: '/workers',
  },
  {
    title: 'Estadísticas',
    icon: BarChart3,
    path: '/stats',
  },
  {
    title: 'Historial',
    icon: History,
    path: '/history',
  },
  {
    title: 'Configuración',
    icon: Settings,
    path: '/settings',
  },
]

export default function Sidebar() {
  const { sidebarOpen, user, toggleSidebar } = useStore()
  const isAdmin = user?.user_metadata?.role === 'admin'
  const menuItems = isAdmin ? adminMenuItems : workerMenuItems

  // Función para cerrar el sidebar con un pequeño retraso
  const handleMenuItemClick = () => {
    // Solo cerrar automáticamente en móviles (pantallas menores a 1024px)
    if (window.innerWidth < 1024) {
      setTimeout(() => {
        toggleSidebar()
      }, 300) // Retraso de 300ms para que se vea la selección
    }
  }

  return (
    <AnimatePresence>
      {sidebarOpen && (
        <motion.aside
          initial={{ x: -280 }}
          animate={{ x: 0 }}
          exit={{ x: -280 }}
          transition={{ duration: 0.3, ease: 'easeInOut' }}
          className="fixed left-0 top-16 z-40 h-[calc(100vh-4rem)] w-64 glass-strong border-r border-white/20"
        >
          <nav className="space-y-2 p-4">
            {menuItems.map((item) => (
              <NavLink
                key={item.path}
                to={item.path}
                onClick={handleMenuItemClick}
                className={({ isActive }) =>
                  cn(
                    'flex items-center space-x-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200',
                    isActive
                      ? 'glass-dark text-white shadow-lg scale-105'
                      : 'text-white/80 hover:glass hover:scale-105 hover:text-white'
                  )
                }
              >
                <item.icon className="h-5 w-5" />
                <span>{item.title}</span>
              </NavLink>
            ))}
          </nav>
        </motion.aside>
      )}
    </AnimatePresence>
  )
}


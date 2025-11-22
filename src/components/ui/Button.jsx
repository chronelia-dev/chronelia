import * as React from 'react'
import { cn } from '@/lib/utils'

const Button = React.forwardRef(({ className, variant = 'default', size = 'default', ...props }, ref) => {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-xl text-sm font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-transparent hover:scale-105 active:scale-95',
        {
          'bg-gradient-to-r from-purple-500 to-pink-500 text-white hover:from-purple-600 hover:to-pink-600 shadow-lg': variant === 'default',
          'bg-gradient-to-r from-red-500 to-orange-500 text-white hover:from-red-600 hover:to-orange-600 shadow-lg': variant === 'destructive',
          'glass border border-white/30 text-gray-800 hover:glass-strong': variant === 'outline',
          'hover:glass text-gray-700': variant === 'ghost',
          'glass-strong text-gray-800 hover:shadow-lg': variant === 'secondary',
          'h-10 py-2 px-4': size === 'default',
          'h-9 px-3': size === 'sm',
          'h-11 px-8': size === 'lg',
          'h-9 w-9 p-0': size === 'icon',
        },
        className
      )}
      ref={ref}
      {...props}
    />
  )
})
Button.displayName = 'Button'

export { Button }













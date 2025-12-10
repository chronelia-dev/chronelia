import { useState, useEffect, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X, Zap, Camera } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import jsQR from 'jsqr'
import { BarcodeScanner } from '@capacitor-mlkit/barcode-scanning'
import { Capacitor } from '@capacitor/core'

export default function QRScannerModal({ isOpen, onClose }) {
  const { addReservation, user } = useStore()
  const [scanning, setScanning] = useState(false)
  const [processing, setProcessing] = useState(false)
  const [cameraError, setCameraError] = useState(null)
  const [isNativeApp, setIsNativeApp] = useState(false)
  const [videoReady, setVideoReady] = useState(false)
  const videoRef = useRef(null)
  const canvasRef = useRef(null)
  const streamRef = useRef(null)
  const scanIntervalRef = useRef(null)

  // Detectar si es app nativa
  useEffect(() => {
    const platform = Capacitor.getPlatform()
    const isNative = platform === 'android' || platform === 'ios'
    setIsNativeApp(isNative)
    console.log('📱 QRScanner Modal - Plataforma:', platform, '- Nativa:', isNative)
  }, [])

  useEffect(() => {
    if (isOpen) {
      setProcessing(false)
      setCameraError(null)
      setVideoReady(false)
      
      // Si es app nativa, usar ML Kit directamente (sin mostrar modal)
      if (isNativeApp) {
        startNativeScanner()
      } else {
        // En web, dar tiempo a que el modal se monte completamente
        // antes de intentar acceder al videoRef
        setTimeout(() => {
          startCamera()
        }, 100)
      }
    } else {
      stopCamera()
      // Limpiar ML Kit si se cerró
      if (isNativeApp) {
        document.body.classList.remove('qr-scanning')
      }
    }

    return () => {
      stopCamera()
      if (isNativeApp) {
        document.body.classList.remove('qr-scanning')
      }
    }
  }, [isOpen, isNativeApp])

  const startNativeScanner = async () => {
    console.log('🎯 Iniciando escáner nativo ML Kit...')
    
    try {
      setScanning(true)
      
      // Solicitar permisos
      const permissionResult = await BarcodeScanner.requestPermissions()
      console.log('🔐 Permisos:', permissionResult)
      
      if (permissionResult.camera !== 'granted' && permissionResult.camera !== 'limited') {
        toast.error('Permiso de cámara denegado', {
          description: 'Ve a Ajustes → Apps → chronelia. → Permisos → Cámara'
        })
        setCameraError('Permiso de cámara denegado')
        setScanning(false)
        onClose() // Cerrar modal
        return
      }

      // Preparar UI - NO mostrar toast en Android, ML Kit tiene su propia UI
      document.body.classList.add('qr-scanning')
      
      console.log('📷 Iniciando BarcodeScanner.scan()...')
      
      // Escanear (BLOQUEANTE)
      const result = await BarcodeScanner.scan({
        formats: ['QR_CODE'],
      })
      
      console.log('📷 Resultado:', result)
      
      // Verificar resultado
      if (result && result.barcodes && result.barcodes.length > 0) {
        const barcodeData = result.barcodes[0]
        const code = barcodeData.rawValue || barcodeData.displayValue
        
        console.log('✅ Código escaneado:', code)
        toast.success('¡Código QR escaneado!')
        processQRCode(code)
        // onClose se llamará después de procesar el QR
      } else {
        console.log('⚠️ No se detectaron códigos')
        toast.info('No se detectó código QR')
        onClose() // Cerrar modal
      }
      
    } catch (error) {
      console.error('❌ Error en escáner nativo:', error)
      
      // Manejar diferentes tipos de errores
      if (error.message?.includes('cancel') || error.message?.includes('User')) {
        toast.info('Escaneo cancelado')
      } else if (error.message?.includes('permission')) {
        toast.error('Error de permisos', {
          description: 'Verifica los permisos de cámara en Ajustes'
        })
      } else {
        toast.error('Error al escanear', {
          description: error.message
        })
      }
      
      // Siempre cerrar el modal después de un error
      onClose()
    } finally {
      document.body.classList.remove('qr-scanning')
      setScanning(false)
    }
  }

  const startCamera = async () => {
    console.log('🎥 === INICIANDO CÁMARA ===')
    
    // Verificar que el videoRef existe (crítico)
    if (!videoRef.current) {
      console.error('❌ CRÍTICO: videoRef.current es null')
      console.log('⏳ Esperando 200ms más para que el DOM se monte...')
      
      // Reintentar después de un delay
      setTimeout(() => {
        if (videoRef.current) {
          console.log('✅ videoRef ahora disponible, reintentando...')
          startCamera()
        } else {
          console.error('❌ videoRef sigue siendo null después del delay')
          setCameraError('Error al inicializar el video. Por favor, cierra y vuelve a abrir el escáner.')
          toast.error('Error al inicializar', {
            description: 'Intenta cerrar y reabrir el escáner'
          })
        }
      }, 200)
      return
    }
    
    try {
      // Limpiar estados
      setCameraError(null)
      setVideoReady(false)
      setScanning(false)
      
      console.log('📷 Paso 1: Solicitando getUserMedia...')
      console.log('✅ videoRef.current existe:', !!videoRef.current)
      
      // Configuración simplificada
      const constraints = {
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          facingMode: { ideal: 'environment' }
        },
        audio: false
      }
      
      const stream = await navigator.mediaDevices.getUserMedia(constraints)
      console.log('✅ Stream obtenido exitosamente')
      console.log('📹 Tracks:', stream.getVideoTracks().length)
      
      // Guardar stream
      streamRef.current = stream
      
      // Verificar de nuevo (por si acaso)
      if (!videoRef.current) {
        console.error('❌ videoRef.current se volvió null')
        setCameraError('Elemento de video perdido')
        return
      }
      
      console.log('📺 Asignando stream al elemento video...')
      videoRef.current.srcObject = stream
      
      // Esperar a que el video esté listo
      videoRef.current.onloadedmetadata = async () => {
        console.log('✅ Metadata cargada')
        
        if (videoRef.current) {
          console.log('📐 Dimensiones:', videoRef.current.videoWidth, 'x', videoRef.current.videoHeight)
          
          try {
            // Reproducir video
            await videoRef.current.play()
            console.log('▶️ Video reproduciendo')
            
            // Marcar como listo
            setVideoReady(true)
            setScanning(true)
            
            // Pequeño delay antes de iniciar escaneo
            setTimeout(() => {
              startScanning()
            }, 500)
            
          } catch (playError) {
            console.error('❌ Error al reproducir:', playError)
            setCameraError('No se pudo reproducir el video')
            toast.error('Error al reproducir video')
          }
        }
      }

      // Manejar errores del video
      videoRef.current.onerror = (err) => {
        console.error('❌ Error en elemento video:', err)
        setCameraError('Error en el video')
      }
      
    } catch (error) {
      console.error('❌ Error al acceder a la cámara:', error)
      console.error('Nombre del error:', error.name)
      console.error('Mensaje:', error.message)
      
      setCameraError(error.message)
      
      let errorMessage = 'Por favor, permite el acceso a la cámara'
      
      if (error.name === 'NotAllowedError') {
        errorMessage = 'Permiso de cámara denegado. Permite el acceso en la configuración del navegador.'
      } else if (error.name === 'NotFoundError') {
        errorMessage = 'No se encontró ninguna cámara disponible'
      } else if (error.name === 'NotReadableError') {
        errorMessage = 'La cámara está siendo usada por otra aplicación'
      }
      
      toast.error('Error al acceder a la cámara', {
        description: errorMessage,
      })
    }
  }

  const stopCamera = () => {
    if (scanIntervalRef.current) {
      clearInterval(scanIntervalRef.current)
      scanIntervalRef.current = null
    }
    
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop())
      streamRef.current = null
    }
    
    setScanning(false)
  }

  const startScanning = () => {
    const canvas = canvasRef.current
    const video = videoRef.current
    
    if (!canvas || !video) return

    const ctx = canvas.getContext('2d')
    
    scanIntervalRef.current = setInterval(() => {
      if (video.readyState === video.HAVE_ENOUGH_DATA && !processing) {
        canvas.width = video.videoWidth
        canvas.height = video.videoHeight
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
        
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        const code = jsQR(imageData.data, imageData.width, imageData.height, {
          inversionAttempts: 'dontInvert'
        })
        
        if (code) {
          processQRCode(code.data)
        }
      }
    }, 300)
  }

  const processQRCode = (qrData) => {
    if (processing) return
    
    setProcessing(true)
    
    try {
      const data = JSON.parse(qrData)
      
      if (!data.clientName || !data.duration) {
        throw new Error('Datos incompletos en el QR')
      }

      addReservation({
        clientName: data.clientName,
        clientEmail: data.clientEmail || 'sin-email@ejemplo.com',
        qrCode: data.code || qrData,
        totalDuration: data.duration * 60,
        groupSize: data.groupSize || 1,
        worker: user?.user_metadata?.full_name || user?.email || 'Trabajador',
      })

      toast.success('✅ ¡Reserva activada!', {
        description: `${data.clientName} - ${data.duration} minutos`,
        duration: 4000,
      })

      // Cerrar inmediatamente en app nativa, con delay en web
      if (isNativeApp) {
        stopCamera()
        onClose()
      } else {
        // Pequeño delay para mostrar el feedback antes de cerrar en web
        setTimeout(() => {
          stopCamera()
          onClose()
        }, 800)
      }
    } catch (error) {
      toast.error('❌ Código QR inválido', {
        description: 'El código no tiene el formato correcto. Asegúrate de que el QR contenga un JSON válido.',
        duration: 5000,
      })
      
      // En app nativa, cerrar inmediatamente después del error
      if (isNativeApp) {
        onClose()
      } else {
        setTimeout(() => {
          setProcessing(false)
        }, 2000)
      }
    }
  }

  const handleTestReservation = () => {
    const testData = {
      clientName: 'Cliente Test ' + Math.floor(Math.random() * 100),
      clientEmail: 'test@chronelia.com',
      code: 'TEST' + Date.now(),
      duration: 30,
      groupSize: 2,
    }
    processQRCode(JSON.stringify(testData))
  }

  if (!isOpen) return null

  // En Android, no mostrar modal - ML Kit tiene su propia UI
  if (isNativeApp) {
    return null
  }

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          className="fixed inset-4 md:inset-auto md:top-1/2 md:left-1/2 md:-translate-x-1/2 md:-translate-y-1/2 md:w-full md:max-w-2xl bg-background rounded-3xl shadow-2xl overflow-hidden"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b bg-gradient-to-r from-pink-500 to-purple-600">
            <h2 className="text-2xl font-bold text-white">Escanear QR</h2>
            <Button
              variant="ghost"
              size="icon"
              onClick={onClose}
              className="text-white hover:bg-white/20"
            >
              <X className="h-6 w-6" />
            </Button>
          </div>

          {/* Scanner */}
          <div className="p-6">
            {isNativeApp && scanning ? (
              // En Android, mostrar solo indicador de carga (ML Kit tiene su propia UI)
              <div className="text-center py-12">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                >
                  <Camera className="h-16 w-16 mx-auto mb-4 text-primary" />
                </motion.div>
                <p className="text-lg font-semibold mb-2">Escáner activo</p>
                <p className="text-sm text-muted-foreground">
                  Apunta al código QR con la cámara
                </p>
                <Button 
                  onClick={onClose}
                  className="mt-6"
                  variant="outline"
                >
                  Cancelar
                </Button>
              </div>
            ) : cameraError ? (
              <div className="text-center py-12">
                <Camera className="h-16 w-16 mx-auto mb-4 text-muted-foreground" />
                <p className="text-muted-foreground mb-2">Error al acceder a la cámara</p>
                <p className="text-xs text-muted-foreground mb-4">{cameraError}</p>
                <Button 
                  onClick={isNativeApp ? startNativeScanner : startCamera}
                  className="mt-4"
                  variant="outline"
                >
                  Reintentar
                </Button>
              </div>
            ) : videoReady ? (
              <div className="relative">
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="relative overflow-hidden rounded-2xl border-4 border-primary shadow-lg aspect-video"
                >
                  {/* Video element */}
                  <video
                    ref={videoRef}
                    autoPlay
                    playsInline
                    muted
                    className="w-full h-full object-cover"
                  />
                  
                  {/* Canvas oculto para procesar frames */}
                  <canvas
                    ref={canvasRef}
                    className="hidden"
                  />
                  
                  {/* Overlay de escaneo */}
                  <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <div className="relative w-64 h-64">
                      {/* Esquinas del marco */}
                      <div className="absolute top-0 left-0 w-16 h-16 border-t-4 border-l-4 border-white rounded-tl-lg" />
                      <div className="absolute top-0 right-0 w-16 h-16 border-t-4 border-r-4 border-white rounded-tr-lg" />
                      <div className="absolute bottom-0 left-0 w-16 h-16 border-b-4 border-l-4 border-white rounded-bl-lg" />
                      <div className="absolute bottom-0 right-0 w-16 h-16 border-b-4 border-r-4 border-white rounded-br-lg" />
                      
                      {/* Línea de escaneo animada */}
                      <motion.div
                        className="absolute left-0 right-0 h-1 bg-gradient-to-r from-transparent via-white to-transparent"
                        animate={{
                          top: ['0%', '100%', '0%'],
                        }}
                        transition={{
                          duration: 2,
                          repeat: Infinity,
                          ease: 'linear',
                        }}
                      />
                    </div>
                  </div>
                </motion.div>

                <div className="text-center mt-4">
                  {processing ? (
                    <div className="flex items-center justify-center space-x-2">
                      <motion.div
                        className="w-2 h-2 bg-primary rounded-full"
                        animate={{ scale: [1, 1.5, 1] }}
                        transition={{ duration: 0.6, repeat: Infinity }}
                      />
                      <motion.div
                        className="w-2 h-2 bg-primary rounded-full"
                        animate={{ scale: [1, 1.5, 1] }}
                        transition={{ duration: 0.6, repeat: Infinity, delay: 0.2 }}
                      />
                      <motion.div
                        className="w-2 h-2 bg-primary rounded-full"
                        animate={{ scale: [1, 1.5, 1] }}
                        transition={{ duration: 0.6, repeat: Infinity, delay: 0.4 }}
                      />
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground">
                      Apunta la cámara al código QR
                    </p>
                  )}
                </div>
              </div>
            ) : (
              <div className="text-center py-12">
                <Camera className="h-16 w-16 mx-auto mb-4 text-muted-foreground animate-pulse" />
                <p className="text-muted-foreground">Iniciando cámara...</p>
              </div>
            )}
          </div>

          {/* Footer con botón de prueba - SOLO para admins */}
          {user?.user_metadata?.role === 'admin' && (
            <div className="p-6 border-t bg-muted/30">
              <Button
                onClick={handleTestReservation}
                variant="secondary"
                className="w-full"
                size="lg"
                disabled={processing}
              >
                <Zap className="h-5 w-5 mr-2" />
                Crear Reserva de Prueba (30 min)
              </Button>
              <p className="text-xs text-center text-muted-foreground mt-2">
                Para probar sin código QR
              </p>
            </div>
          )}
        </motion.div>
      </motion.div>
    </AnimatePresence>
  )
}

import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, CheckCircle, Camera, Upload, AlertCircle } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import { BarcodeScanner } from '@capacitor-mlkit/barcode-scanning'
import { Capacitor } from '@capacitor/core'
import jsQR from 'jsqr'

/**
 * QRScanner - Componente principal para escanear códigos QR
 * 
 * ARQUITECTURA SIMPLIFICADA:
 * 1. Escaneo desde foto (jsQR) - Funciona en todos lados
 * 2. Escaneo en tiempo real (ML Kit) - Solo Android/iOS
 * 3. Entrada manual - Fallback universal
 */
export default function QRScanner() {
  // Estado
  const [isNativeApp, setIsNativeApp] = useState(false)
  const [processing, setProcessing] = useState(false)
  const [scanning, setScanning] = useState(false)
  const [manualCode, setManualCode] = useState('')
  const [debugInfo, setDebugInfo] = useState([])
  
  // Referencias
  const fileInputRef = useRef(null)
  
  // Hooks
  const navigate = useNavigate()
  const { addReservation, user } = useStore()

  // Detectar plataforma al montar
  useEffect(() => {
    const platform = Capacitor.getPlatform()
    const isNative = platform === 'android' || platform === 'ios'
    setIsNativeApp(isNative)
    
    addDebugLog(`📱 Plataforma detectada: ${platform}`)
    addDebugLog(`✅ App nativa: ${isNative ? 'Sí' : 'No'}`)
    addDebugLog(`✅ ML Kit disponible: ${isNative ? 'Sí' : 'No'}`)
    addDebugLog(`✅ jsQR disponible: Sí`)
  }, [])

  // Función auxiliar para logs de debug
  const addDebugLog = (message) => {
    const timestamp = new Date().toLocaleTimeString()
    const logEntry = `[${timestamp}] ${message}`
    console.log(logEntry)
    setDebugInfo(prev => [...prev.slice(-9), logEntry]) // Mantener últimos 10
  }

  // ========================================
  // MÉTODO 1: ESCANEO DESDE FOTO (jsQR)
  // ========================================
  const handleFileUpload = async (event) => {
    const file = event.target.files?.[0]
    if (!file) {
      addDebugLog('⚠️ No se seleccionó archivo')
      return
    }

    addDebugLog(`📁 Archivo seleccionado: ${file.name}`)

    if (!file.type.startsWith('image/')) {
      toast.error('Archivo inválido', {
        description: 'Por favor selecciona una imagen (JPG, PNG, etc.)'
      })
      addDebugLog('❌ Tipo de archivo inválido')
      return
    }

    setProcessing(true)
    addDebugLog('🔍 Iniciando procesamiento de imagen...')
    toast.info('🔍 Procesando imagen...')

    try {
      // Leer la imagen
      addDebugLog('📖 Paso 1: Leyendo archivo...')
      const imageData = await readImageFile(file)
      addDebugLog(`📖 Imagen leída: ${imageData.width}x${imageData.height}px`)

      // Escanear con jsQR
      addDebugLog('🔍 Paso 2: Buscando código QR con jsQR...')
      const code = jsQR(imageData.data, imageData.width, imageData.height, {
        inversionAttempts: 'dontInvert',
      })

      if (code && code.data) {
        addDebugLog(`✅ ¡Código QR encontrado!`)
        addDebugLog(`📄 Contenido: ${code.data.substring(0, 50)}...`)
        
        toast.success('¡Código QR detectado en la imagen!')
        processQRCode(code.data)
      } else {
        addDebugLog('❌ No se encontró código QR en la imagen')
        toast.error('No se detectó código QR', {
          description: 'Asegúrate de que la imagen contenga un código QR claro y legible'
        })
      }
    } catch (error) {
      addDebugLog(`❌ Error al procesar imagen: ${error.message}`)
      console.error('Error completo:', error)
      toast.error('Error al procesar la imagen', {
        description: error.message
      })
    } finally {
      setProcessing(false)
      // Limpiar input para permitir seleccionar el mismo archivo
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }
      addDebugLog('🏁 Procesamiento finalizado')
    }
  }

  // Función auxiliar para leer archivo de imagen
  const readImageFile = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        const img = new Image()
        
        img.onload = () => {
          try {
            const canvas = document.createElement('canvas')
            const ctx = canvas.getContext('2d')
            
            canvas.width = img.width
            canvas.height = img.height
            ctx.drawImage(img, 0, 0)
            
            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
            resolve(imageData)
          } catch (error) {
            reject(new Error('Error al procesar imagen en canvas'))
          }
        }
        
        img.onerror = () => reject(new Error('Error al cargar la imagen'))
        img.src = e.target.result
      }
      
      reader.onerror = () => reject(new Error('Error al leer el archivo'))
      reader.readAsDataURL(file)
    })
  }

  // ========================================
  // MÉTODO 2: ESCANEO EN TIEMPO REAL (ML Kit)
  // ========================================
  const startRealtimeScanning = async () => {
    addDebugLog('🎯 === INICIANDO ESCANEO EN TIEMPO REAL ===')
    
    if (!isNativeApp) {
      toast.error('Escáner no disponible', {
        description: 'El escaneo en tiempo real solo funciona en la app de Android/iOS'
      })
      addDebugLog('❌ No es app nativa, abortando')
      return
    }

    try {
      setScanning(true)
      addDebugLog('🔐 Paso 1/3: Solicitando permisos de cámara...')
      
      // Solicitar permisos
      const permissionResult = await BarcodeScanner.requestPermissions()
      addDebugLog(`🔐 Resultado de permisos: ${JSON.stringify(permissionResult)}`)
      
      if (permissionResult.camera !== 'granted' && permissionResult.camera !== 'limited') {
        toast.error('Permiso de cámara denegado', {
          description: 'Ve a Ajustes → Apps → chronelia. → Permisos → Cámara'
        })
        addDebugLog('❌ Permisos denegados')
        setScanning(false)
        return
      }

      addDebugLog('✅ Permisos otorgados')
      addDebugLog('📷 Paso 2/3: Preparando interfaz...')
      
      // Marcar que estamos escaneando (para estilos CSS si es necesario)
      document.body.classList.add('qr-scanning')
      
      toast.info('📷 Cámara abierta - Apunta al código QR', { duration: 3000 })
      
      addDebugLog('📷 Paso 3/3: Iniciando BarcodeScanner.scan()...')
      addDebugLog('⏳ Esperando resultado del escáner...')
      
      // IMPORTANTE: Esta llamada es bloqueante hasta que se escanee algo o se cancele
      const result = await BarcodeScanner.scan({
        formats: ['QR_CODE'], // Solo QR
      })
      
      addDebugLog(`📷 Resultado recibido: ${JSON.stringify(result)}`)
      
      // Verificar si hay códigos de barras
      if (result && result.barcodes && result.barcodes.length > 0) {
        const barcodeData = result.barcodes[0]
        const code = barcodeData.rawValue || barcodeData.displayValue
        
        addDebugLog(`✅ ¡Código escaneado!`)
        addDebugLog(`📄 Formato: ${barcodeData.format}`)
        addDebugLog(`📄 Contenido: ${code.substring(0, 50)}...`)
        
        toast.success('¡Código QR escaneado!')
        processQRCode(code)
      } else {
        addDebugLog('⚠️ No se detectaron códigos de barras en el resultado')
        toast.info('No se detectó código QR')
      }
      
    } catch (error) {
      addDebugLog(`❌ ERROR: ${error.message}`)
      addDebugLog(`❌ Stack: ${error.stack}`)
      console.error('Error completo:', error)
      
      // Manejar diferentes tipos de errores
      if (error.message?.includes('cancel') || error.message?.includes('User')) {
        toast.info('Escaneo cancelado')
        addDebugLog('ℹ️ Usuario canceló el escaneo')
      } else if (error.message?.includes('permission')) {
        toast.error('Error de permisos', {
          description: 'Verifica los permisos de cámara en Ajustes'
        })
        addDebugLog('❌ Error de permisos')
      } else {
        toast.error('Error al escanear', {
          description: error.message
        })
        addDebugLog('❌ Error desconocido')
      }
    } finally {
      // Limpieza
      document.body.classList.remove('qr-scanning')
      setScanning(false)
      addDebugLog('🏁 === ESCANEO FINALIZADO ===')
    }
  }

  // ========================================
  // PROCESAMIENTO DEL CÓDIGO QR
  // ========================================
  const processQRCode = (qrData) => {
    addDebugLog('🔄 Procesando código QR...')
    addDebugLog(`📄 Datos raw: ${qrData}`)
    
    try {
      // Intentar parsear como JSON
      const data = JSON.parse(qrData)
      addDebugLog(`✅ JSON válido parseado`)
      addDebugLog(`📋 Campos: ${Object.keys(data).join(', ')}`)
      
      // Validar campos requeridos
      if (!data.clientName || !data.duration) {
        throw new Error('Faltan campos requeridos: clientName o duration')
      }

      addDebugLog(`✅ Datos válidos: ${data.clientName}, ${data.duration} min`)

      // Crear reserva
      addReservation({
        clientName: data.clientName,
        clientEmail: data.clientEmail || 'sin-email@ejemplo.com',
        qrCode: data.code || qrData.substring(0, 20),
        totalDuration: data.duration * 60, // Convertir a segundos
        groupSize: data.groupSize || 1,
        worker: user?.user_metadata?.full_name || user?.email || 'Trabajador',
      })

      addDebugLog('✅ Reserva creada exitosamente')
      
      toast.success('¡Reserva activada!', {
        description: `${data.clientName} - ${data.duration} minutos`,
        duration: 3000,
      })

      // Navegar al dashboard
      setTimeout(() => {
        navigate('/')
      }, 500)
      
    } catch (error) {
      addDebugLog(`❌ Error al procesar QR: ${error.message}`)
      console.error('Error al procesar QR:', error)
      
      toast.error('Código QR inválido', {
        description: 'El código no tiene el formato correcto de chronelia.',
      })
    }
  }

  // ========================================
  // ENTRADA MANUAL
  // ========================================
  const handleManualSubmit = (e) => {
    e.preventDefault()
    addDebugLog('📝 Procesando entrada manual...')
    
    if (manualCode.trim()) {
      processQRCode(manualCode)
    } else {
      toast.error('Ingresa un código QR válido')
    }
  }

  // ========================================
  // PRUEBA RÁPIDA
  // ========================================
  const handleTestReservation = () => {
    addDebugLog('🧪 Creando reserva de prueba...')
    
    const testData = {
      clientName: 'Cliente Prueba',
      clientEmail: 'test@chronelia.com',
      code: 'TEST-' + Date.now(),
      duration: 45,
      groupSize: 2,
    }
    
    processQRCode(JSON.stringify(testData))
  }

  // ========================================
  // INTERFAZ
  // ========================================
  return (
    <div className="max-w-5xl mx-auto space-y-6 p-4">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <Button variant="ghost" size="icon" onClick={() => navigate('/')}>
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Escanear QR</h1>
          <p className="text-muted-foreground">
            Múltiples métodos para escanear códigos QR
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* MÉTODO 1: Desde Foto */}
        <Card className={processing ? 'border-green-500 border-2' : ''}>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Upload className={`h-5 w-5 ${processing ? 'animate-pulse text-green-500' : ''}`} />
              Método 1: Desde Foto
            </CardTitle>
            <CardDescription>
              Sube una foto del código QR (funciona en todos lados)
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={handleFileUpload}
              className="hidden"
            />
            
            <Button 
              onClick={() => fileInputRef.current?.click()} 
              className="w-full" 
              size="lg"
              disabled={processing || scanning}
            >
              {processing ? (
                <>
                  <Upload className="mr-2 h-5 w-5 animate-spin" />
                  Procesando...
                </>
              ) : (
                <>
                  <Upload className="mr-2 h-5 w-5" />
                  📸 Cargar Foto del QR
                </>
              )}
            </Button>

            <div className="text-xs text-muted-foreground space-y-1 bg-blue-50 p-3 rounded">
              <p className="font-bold">✅ Ventajas:</p>
              <p>• Funciona en web y app</p>
              <p>• Puedes usar fotos existentes</p>
              <p>• Mayor precisión con buena iluminación</p>
            </div>
          </CardContent>
        </Card>

        {/* MÉTODO 2: Tiempo Real */}
        <Card className={scanning ? 'border-purple-500 border-2' : ''}>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Camera className={`h-5 w-5 ${scanning ? 'animate-pulse text-purple-500' : ''}`} />
              Método 2: Tiempo Real
            </CardTitle>
            <CardDescription>
              Escaneo directo con la cámara {!isNativeApp && '(solo app)'}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <Button 
              onClick={startRealtimeScanning} 
              className="w-full" 
              size="lg"
              disabled={!isNativeApp || scanning || processing}
              variant={isNativeApp ? "default" : "secondary"}
            >
              {scanning ? (
                <>
                  <Camera className="mr-2 h-5 w-5 animate-pulse" />
                  Escaneando...
                </>
              ) : (
                <>
                  <Camera className="mr-2 h-5 w-5" />
                  📹 Escanear en Tiempo Real
                </>
              )}
            </Button>

            {!isNativeApp ? (
              <div className="text-xs text-amber-700 bg-amber-50 p-3 rounded flex items-start gap-2">
                <AlertCircle className="h-4 w-4 mt-0.5 flex-shrink-0" />
                <div>
                  <p className="font-bold">⚠️ No disponible en web</p>
                  <p>Instala la app de Android para usar esta función</p>
                </div>
              </div>
            ) : (
              <div className="text-xs text-muted-foreground space-y-1 bg-purple-50 p-3 rounded">
                <p className="font-bold">✅ Ventajas:</p>
                <p>• Escaneo instantáneo</p>
                <p>• No necesitas guardar fotos</p>
                <p>• Usa ML Kit de Google</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* MÉTODO 3: Entrada Manual */}
        <Card>
          <CardHeader>
            <CardTitle>Método 3: Entrada Manual</CardTitle>
            <CardDescription>
              Ingresa el código JSON directamente
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleManualSubmit} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="qrCode" className="text-sm font-medium">
                  Código QR (formato JSON)
                </label>
                <Input
                  id="qrCode"
                  placeholder='{"clientName":"Juan","duration":30,"clientEmail":"juan@email.com"}'
                  value={manualCode}
                  onChange={(e) => setManualCode(e.target.value)}
                  className="font-mono text-xs"
                />
              </div>
              <Button type="submit" className="w-full" disabled={scanning || processing}>
                <CheckCircle className="mr-2 h-4 w-4" />
                Activar Reserva
              </Button>
            </form>

            <div className="mt-4 pt-4 border-t">
              <Button
                variant="secondary"
                onClick={handleTestReservation}
                className="w-full"
                disabled={scanning || processing}
              >
                🧪 Crear Reserva de Prueba
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Panel de Debug */}
        <Card className="bg-slate-50">
          <CardHeader>
            <CardTitle className="text-sm">🐛 Información de Debug</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-1 text-xs font-mono">
              <p className="font-bold mb-2">Estado actual:</p>
              <p>• Plataforma: {Capacitor.getPlatform()}</p>
              <p>• App nativa: {isNativeApp ? '✅ Sí' : '❌ No'}</p>
              <p>• Procesando: {processing ? '🟢' : '⚪'}</p>
              <p>• Escaneando: {scanning ? '🟢' : '⚪'}</p>
              
              <div className="mt-4 pt-4 border-t">
                <p className="font-bold mb-2">Últimos logs:</p>
                <div className="space-y-0.5 max-h-48 overflow-y-auto bg-white p-2 rounded border">
                  {debugInfo.length === 0 ? (
                    <p className="text-gray-400">No hay logs aún...</p>
                  ) : (
                    debugInfo.map((log, i) => (
                      <p key={i} className="text-[10px] leading-relaxed">
                        {log}
                      </p>
                    ))
                  )}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

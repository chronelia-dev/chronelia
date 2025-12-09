import { useState } from 'react'
import { Button } from '@/components/ui/Button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { AlertCircle, CheckCircle2, Loader2, Zap } from 'lucide-react'
import { testOpenAIConnection, verifyConfiguration } from '@/utils/testOpenAI'

export default function OpenAITest() {
  const [testing, setTesting] = useState(false)
  const [result, setResult] = useState(null)
  const [config, setConfig] = useState(null)

  const handleTest = async () => {
    setTesting(true)
    setResult(null)
    
    try {
      const testResult = await testOpenAIConnection()
      setResult(testResult)
    } catch (error) {
      setResult({
        success: false,
        error: 'UNEXPECTED_ERROR',
        message: error.message
      })
    } finally {
      setTesting(false)
    }
  }

  const handleVerifyConfig = () => {
    const configResult = verifyConfiguration()
    setConfig(configResult)
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <Zap className="h-5 w-5 text-yellow-500" />
                Test de Conexión OpenAI
              </CardTitle>
              <CardDescription>
                Verifica que Chronelia puede conectarse correctamente a OpenAI
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Botones de acción */}
          <div className="flex gap-3">
            <Button 
              onClick={handleVerifyConfig}
              variant="outline"
              disabled={testing}
            >
              🔍 Verificar Configuración
            </Button>
            <Button 
              onClick={handleTest}
              disabled={testing}
              className="bg-gradient-to-r from-purple-600 to-pink-600"
            >
              {testing ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Probando...
                </>
              ) : (
                <>
                  <Zap className="mr-2 h-4 w-4" />
                  Hacer Ping a OpenAI
                </>
              )}
            </Button>
          </div>

          {/* Resultado de configuración */}
          {config && (
            <Card className="bg-muted/50">
              <CardHeader>
                <CardTitle className="text-sm">Configuración</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span>API Key presente:</span>
                  <Badge variant={config.hasApiKey ? 'default' : 'destructive'}>
                    {config.hasApiKey ? 'Sí' : 'No'}
                  </Badge>
                </div>
                <div className="flex justify-between">
                  <span>API Key válida:</span>
                  <Badge variant={config.apiKeyValid ? 'default' : 'destructive'}>
                    {config.apiKeyValid ? 'Sí' : 'No'}
                  </Badge>
                </div>
                <div className="flex justify-between">
                  <span>Longitud de key:</span>
                  <span className="font-mono">{config.apiKeyLength} caracteres</span>
                </div>
                <div className="flex justify-between">
                  <span>Modelo:</span>
                  <span className="font-semibold">{config.model}</span>
                </div>
                <div className="flex justify-between items-start">
                  <span>Vista previa:</span>
                  <code className="text-xs bg-black/10 px-2 py-1 rounded">
                    {config.apiKeyPreview}
                  </code>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Resultado del test */}
          {result && (
            <Card className={result.success ? 'border-green-500 bg-green-50 dark:bg-green-950' : 'border-red-500 bg-red-50 dark:bg-red-950'}>
              <CardHeader>
                <CardTitle className="text-sm flex items-center gap-2">
                  {result.success ? (
                    <>
                      <CheckCircle2 className="h-5 w-5 text-green-600" />
                      <span className="text-green-700 dark:text-green-300">Test Exitoso</span>
                    </>
                  ) : (
                    <>
                      <AlertCircle className="h-5 w-5 text-red-600" />
                      <span className="text-red-700 dark:text-red-300">Test Fallido</span>
                    </>
                  )}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {/* Mensaje principal */}
                <div className="text-sm">
                  <strong>Mensaje:</strong>
                  <p className="mt-1">{result.message}</p>
                </div>

                {/* Respuesta de la IA (si es exitoso) */}
                {result.success && result.aiResponse && (
                  <div className="text-sm">
                    <strong>Respuesta de OpenAI:</strong>
                    <div className="mt-2 p-3 bg-white dark:bg-gray-800 rounded border">
                      {result.aiResponse}
                    </div>
                  </div>
                )}

                {/* Código de error (si falló) */}
                {!result.success && result.error && (
                  <div className="text-sm">
                    <strong>Código de error:</strong>
                    <code className="ml-2 px-2 py-1 bg-red-100 dark:bg-red-900 rounded">
                      {result.error}
                    </code>
                  </div>
                )}

                {/* Detalles técnicos */}
                {result.details && (
                  <details className="text-sm">
                    <summary className="cursor-pointer font-semibold">
                      Detalles técnicos
                    </summary>
                    <pre className="mt-2 p-3 bg-black/10 rounded text-xs overflow-auto">
                      {JSON.stringify(result.details, null, 2)}
                    </pre>
                  </details>
                )}

                {/* Métricas (si es exitoso) */}
                {result.success && (
                  <div className="grid grid-cols-2 gap-3 text-sm">
                    <div>
                      <span className="text-muted-foreground">Modelo:</span>
                      <p className="font-semibold">{result.model}</p>
                    </div>
                    <div>
                      <span className="text-muted-foreground">Tiempo:</span>
                      <p className="font-semibold">{result.responseTime}ms</p>
                    </div>
                    {result.usage && (
                      <>
                        <div>
                          <span className="text-muted-foreground">Tokens usados:</span>
                          <p className="font-semibold">{result.usage.total_tokens}</p>
                        </div>
                        <div>
                          <span className="text-muted-foreground">Costo aprox:</span>
                          <p className="font-semibold">
                            ${((result.usage.total_tokens / 1000000) * 0.15).toFixed(6)}
                          </p>
                        </div>
                      </>
                    )}
                  </div>
                )}

                {/* Sugerencias según el error */}
                {!result.success && (
                  <div className="mt-4 p-3 bg-yellow-50 dark:bg-yellow-950 border border-yellow-200 dark:border-yellow-800 rounded">
                    <p className="font-semibold text-sm mb-2">💡 Sugerencias:</p>
                    <ul className="text-sm space-y-1 list-disc list-inside">
                      {result.error === 'NO_API_KEY' && (
                        <li>Crea el archivo .env.local con tu API key</li>
                      )}
                      {result.error === 'INVALID_API_KEY' && (
                        <>
                          <li>Verifica que tu API key sea correcta</li>
                          <li>Genera una nueva en https://platform.openai.com/api-keys</li>
                        </>
                      )}
                      {result.error === 'RATE_LIMIT' && (
                        <>
                          <li>Espera unos minutos antes de volver a intentar</li>
                          <li>Considera actualizar tu plan en OpenAI</li>
                        </>
                      )}
                      {result.error === 'NETWORK_ERROR' && (
                        <>
                          <li>Verifica tu conexión a internet</li>
                          <li>Comprueba que no haya firewall bloqueando la conexión</li>
                        </>
                      )}
                    </ul>
                  </div>
                )}
              </CardContent>
            </Card>
          )}

          {/* Información adicional */}
          <div className="text-xs text-muted-foreground">
            <p>ℹ️ Este test hace una llamada real a OpenAI y consume tokens (aprox. $0.0001 USD)</p>
            <p className="mt-1">💡 También puedes abrir la consola del navegador (F12) para ver logs detallados</p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}




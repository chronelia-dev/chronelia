import { useState, useRef, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X, Send, Sparkles, Loader2, Zap } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import { generateAIResponse, isOpenAIConfigured } from '@/lib/openai'

export default function AIChat({ isOpen, onClose }) {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: '¡Hola! Soy tu asistente IA de chronelia. Puedo ayudarte a analizar las estadísticas de tu negocio, responder preguntas sobre reservas, trabajadores y mucho más. ¿En qué puedo ayudarte?',
      timestamp: new Date()
    }
  ])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef(null)
  const inputRef = useRef(null)

  const store = useStore()
  const aiConfigured = isOpenAIConfigured()

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus()
    }
  }, [isOpen])

  const handleSend = async () => {
    if (!input.trim() || isLoading) return

    const userMessage = input.trim()
    setInput('')
    setIsLoading(true)

    // Agregar mensaje del usuario
    const newUserMessage = {
      role: 'user',
      content: userMessage,
      timestamp: new Date()
    }
    setMessages(prev => [...prev, newUserMessage])

    try {
      // Generar respuesta con OpenAI
      const aiResponse = await generateAIResponse(userMessage, store, messages)

      // Agregar respuesta de IA
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: aiResponse,
        timestamp: new Date()
      }])

    } catch (error) {
      console.error('Error en handleSend:', error)
      toast.error('Error al generar respuesta', {
        description: 'Intenta de nuevo en unos momentos'
      })
      
      // Agregar mensaje de error
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: '❌ Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        timestamp: new Date()
      }])
    } finally {
      setIsLoading(false)
    }
  }

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  // Sugerencias rápidas
  const quickSuggestions = [
    '¿Cuántas reservas tengo?',
    '¿Cuántos trabajadores activos hay?',
    'Estadísticas de hoy',
    'Dame una recomendación',
  ]

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/50 z-40"
          />

          {/* Chat Panel */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed bottom-0 left-0 right-0 z-50 bg-background rounded-t-3xl shadow-2xl border-t-2 border-purple-500/20"
            style={{ 
              maxHeight: '75vh',
              paddingBottom: 'env(safe-area-inset-bottom)'
            }}
          >
            {/* Header */}
            <div className="flex items-center justify-between p-4 pb-2 border-b bg-gradient-to-r from-purple-500/10 to-pink-500/10">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                  <Sparkles className="h-5 w-5 text-white" />
                </div>
                <div>
                  <h3 className="font-semibold flex items-center gap-2">
                    Asistente IA chronelia.
                    {aiConfigured && (
                      <Zap className="h-4 w-4 text-yellow-500" title="OpenAI Activado" />
                    )}
                  </h3>
                  <p className="text-xs text-muted-foreground">
                    {aiConfigured ? 'Potenciado por OpenAI' : 'Modo básico - Configura OpenAI para más funciones'}
                  </p>
                </div>
              </div>
              <Button
                variant="ghost"
                size="icon"
                onClick={onClose}
                className="rounded-full"
              >
                <X className="h-5 w-5" />
              </Button>
            </div>

            {/* Messages */}
            <div className="overflow-y-auto p-4 pb-2 space-y-4" style={{ height: 'calc(70vh - 140px)' }}>
              {messages.map((message, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                      message.role === 'user'
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                        : 'bg-muted'
                    }`}
                  >
                    <p className="text-sm whitespace-pre-line">{message.content}</p>
                    <p className={`text-xs mt-1 ${message.role === 'user' ? 'text-white/70' : 'text-muted-foreground'}`}>
                      {message.timestamp.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                </motion.div>
              ))}

              {isLoading && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="flex justify-start"
                >
                  <div className="bg-muted rounded-2xl px-4 py-3 flex items-center gap-2">
                    <Loader2 className="h-4 w-4 animate-spin" />
                    <span className="text-sm text-muted-foreground">Pensando...</span>
                  </div>
                </motion.div>
              )}

              <div ref={messagesEndRef} />
            </div>

            {/* Quick Suggestions */}
            {messages.length === 1 && (
              <div className="px-4 pb-2">
                <p className="text-xs text-muted-foreground mb-2">Sugerencias:</p>
                <div className="flex gap-2 overflow-x-auto pb-2">
                  {quickSuggestions.map((suggestion, index) => (
                    <Button
                      key={index}
                      variant="outline"
                      size="sm"
                      className="text-xs whitespace-nowrap"
                      onClick={() => {
                        setInput(suggestion)
                        inputRef.current?.focus()
                      }}
                    >
                      {suggestion}
                    </Button>
                  ))}
                </div>
              </div>
            )}

            {/* Input - con espacio para teclado */}
            <div className="p-3 border-t bg-background" style={{ paddingBottom: 'max(env(safe-area-inset-bottom), 0.75rem)' }}>
              <div className="flex gap-2">
                <Input
                  ref={inputRef}
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyPress={handleKeyPress}
                  placeholder="Pregúntame sobre tus estadísticas..."
                  className="flex-1"
                  disabled={isLoading}
                />
                <Button
                  onClick={handleSend}
                  disabled={!input.trim() || isLoading}
                  className="bg-gradient-to-r from-purple-500 to-pink-500"
                >
                  {isLoading ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Send className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}


import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const root = fileURLToPath(new URL('.', import.meta.url))
  const env = loadEnv(mode, root, 'VITE_')
  let localConfig = {}

  if (!env.VITE_GEMINI_API_KEY?.trim() || !env.VITE_GEMINI_MODEL?.trim()) {
    try {
      localConfig = JSON.parse(readFileSync(new URL('../.gemini.local.json', import.meta.url), 'utf8'))
    } catch (error) {
      if (error.code !== 'ENOENT') throw new Error('Could not read .gemini.local.json. Check that it contains valid JSON.')
    }
  }

  return {
    plugins: [react()],
    define: {
      'import.meta.env.VITE_GEMINI_API_KEY': JSON.stringify(
        env.VITE_GEMINI_API_KEY?.trim() || localConfig.GEMINI_API_KEY?.trim() || '',
      ),
      'import.meta.env.VITE_GEMINI_MODEL': JSON.stringify(
        env.VITE_GEMINI_MODEL?.trim() || localConfig.GEMINI_MODEL?.trim() || '',
      ),
    },
  }
})

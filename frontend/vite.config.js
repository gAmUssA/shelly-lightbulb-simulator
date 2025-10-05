import { defineConfig } from 'vite'
import preact from '@preact/preset-vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [preact()],
  server: {
    port: 3000,
    proxy: {
      '/light': 'http://localhost:8080',
      '/color': 'http://localhost:8080',
      '/white': 'http://localhost:8080',
      '/status': 'http://localhost:8080',
      '/rpc': 'http://localhost:8080',
      '/graphql': {
        target: 'http://localhost:8080',
        ws: true
      }
    }
  }
})

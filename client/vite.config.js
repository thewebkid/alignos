import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    // Serve md folder for cover images
    {
      name: 'serve-md-folder',
      configureServer(server) {
        server.middlewares.use('/md', (req, res, next) => {
          const filePath = resolve(__dirname, 'md', req.url.slice(1))
          import('fs').then(fs => {
            if (fs.existsSync(filePath)) {
              const stream = fs.createReadStream(filePath)
              const ext = filePath.split('.').pop().toLowerCase()
              const mimeTypes = {
                jpg: 'image/jpeg',
                jpeg: 'image/jpeg',
                png: 'image/png',
                gif: 'image/gif',
                webp: 'image/webp',
                md: 'text/markdown'
              }
              res.setHeader('Content-Type', mimeTypes[ext] || 'application/octet-stream')
              stream.pipe(res)
            } else {
              next()
            }
          })
        })
      }
    }
  ],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
    fs: {
      // Allow serving files from md directory
      allow: ['..', 'md']
    }
  },
  css: {
    preprocessorOptions: {
      scss: {
        // Silence deprecation warnings from Bootstrap
        // These warnings come from Bootstrap's internal code and will be fixed in Bootstrap 6
        silenceDeprecations: [
          'import',
          'if-function',
          'global-builtin',
          'color-functions'
        ],
      },
    },
  },
})

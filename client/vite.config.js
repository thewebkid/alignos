import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'
import fs from 'fs'

// Read codex lattice to generate all routes for SSG
const latticePath = resolve(__dirname, 'src/generated/codex-lattice.json')
const codexLatticeData = fs.existsSync(latticePath)
  ? JSON.parse(fs.readFileSync(latticePath, 'utf-8'))
  : []

// Generate all codex routes
const codexRoutes = codexLatticeData.map(codex => `/codex/${codex.id}`)

/** Map extensionless /api/* URLs to static JSON under /data (matches vercel.json). */
function rewriteApiToData(req) {
  if (!req.url) return
  const url = req.url.split('?')[0]
  if (url === '/api/health') req.url = '/data/health.json'
  else if (url === '/api/codex-lattice') req.url = '/data/codex-lattice.json'
  else if (url === '/api/codex-lattice-meta') req.url = '/data/codex-lattice-meta.json'
  else {
    const match = url.match(/^\/api\/codex\/([^/]+)\/?$/)
    if (match) req.url = `/data/codex/${match[1]}.json`
  }
}

function apiStaticRewrites() {
  return {
    name: 'api-static-rewrites',
    configureServer(server) {
      server.middlewares.use((req, _res, next) => {
        rewriteApiToData(req)
        next()
      })
    },
    configurePreviewServer(server) {
      server.middlewares.use((req, _res, next) => {
        rewriteApiToData(req)
        next()
      })
    },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    apiStaticRewrites(),
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
    fs: {
      // Allow serving files from md and codex-content directories
      allow: ['..', 'md', 'public/codex-content']
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
  // vite-ssg configuration
  ssgOptions: {
    script: 'async',
    formatting: 'minify',
    crittersOptions: {
      reduceInlineStyles: false,
    },
    includedRoutes(paths, routes) {
      // Generate all 133+ codex routes for production
      console.log(`📝 Generating ${codexRoutes.length} codex pages...`)
      return [
        '/',
        '/search',
        '/faq',
        '/about',
        ...codexRoutes
      ]
    },
  },
})

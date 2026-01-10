import { ViteSSG } from 'vite-ssg'
import { createPinia } from 'pinia'
import { createBootstrap } from 'bootstrap-vue-next'

// Import SCSS with Bootstrap theme customization
import './assets/scss/main.scss'

import App from './App.vue'
import routes from './router'

// Codex Lattice imports
import { CodexRegistry } from './lib/codex-registry.js'
import { BrowserCodex } from './lib/codex-browser.js'
import { createGlossaryFromRegistry } from './lib/glossary.js'
import codexLatticeData from './generated/codex-lattice.json'

// Initialize the Codex Lattice
console.log('🔮 Initializing Codex Lattice...')

const codexRegistry = new CodexRegistry().loadFromData(codexLatticeData, BrowserCodex)
const glossaryManager = createGlossaryFromRegistry(codexRegistry)

console.log(`✨ Loaded ${codexRegistry.size} codexes`)
console.log(`📚 ${codexRegistry.getSeriesNames().length} series detected`)
console.log(`📖 ${glossaryManager.size} glossary terms loaded`)

// Export for vite-ssg
export const createApp = ViteSSG(
  App,
  { routes },
  ({ app, router, routes, isClient, initialState }) => {
    // Setup plugins
    const pinia = createPinia()
    app.use(pinia)
    app.use(createBootstrap())

    // Provide the registry and glossary to all components
    app.provide('codexRegistry', codexRegistry)
    app.provide('glossaryManager', glossaryManager)

    // Also make them available globally for debugging (client-side only)
    if (isClient && typeof window !== 'undefined') {
      window.codexRegistry = codexRegistry
      window.glossaryManager = glossaryManager
    }
  }
)

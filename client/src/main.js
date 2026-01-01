import { createApp } from 'vue'
import { createBootstrap } from 'bootstrap-vue-next'

// Import SCSS with Bootstrap theme customization
import './assets/scss/main.scss'

// Keep your existing custom styles if needed
import './style.css'
import App from './App.vue'

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

// Create Vue app
const app = createApp(App)

// Provide the registry and glossary to all components
app.provide('codexRegistry', codexRegistry)
app.provide('glossaryManager', glossaryManager)

// Also make them available globally for debugging
if (typeof window !== 'undefined') {
  window.codexRegistry = codexRegistry
  window.glossaryManager = glossaryManager
}

app.use(createBootstrap())
app.mount('#app')

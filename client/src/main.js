import { createApp } from 'vue'
import { createBootstrap } from 'bootstrap-vue-next'

// Import SCSS with Bootstrap theme customization
import './assets/scss/main.scss'

// Keep your existing custom styles if needed
import './style.css'
import App from './App.vue'

const app = createApp(App)
app.use(createBootstrap())
app.mount('#app')

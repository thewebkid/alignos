import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'browse',
    component: () => import('../views/BrowseView.vue'),
    meta: { title: 'Codex Lattice' }
  },
  {
    path: '/codex/:id',
    name: 'reader',
    component: () => import('../views/ReaderView.vue'),
    meta: { title: 'Reading' }
  },
  {
    path: '/search',
    name: 'search',
    component: () => import('../views/SearchView.vue'),
    meta: { title: 'Search' }
  },
  {
    path: '/faq',
    name: 'faq',
    component: () => import('../views/FaqView.vue'),
    meta: { title: 'FAQ' }
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('../views/AboutView.vue'),
    meta: { title: 'About' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Update document title on navigation
router.beforeEach((to, from, next) => {
  const baseTitle = 'Align OS'
  document.title = to.meta.title ? `${to.meta.title} | ${baseTitle}` : baseTitle
  next()
})

// Handle scroll behavior manually since the scroll container is .main-content, not window
router.afterEach((to, from) => {
  // Get the scrollable container
  const container = document.querySelector('.main-content')
  if (!container) return
  
  // Reader view and browse view handle their own scroll restoration
  // Only reset scroll for other views (search, about, faq, etc.)
  if (to.name === 'reader' || to.name === 'browse') {
    return
  }
  
  // For all other routes, reset scroll to top
  setTimeout(() => {
    container.scrollTo({ top: 0, behavior: 'instant' })
  }, 0)
})

export default router

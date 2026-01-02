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
  routes,
  scrollBehavior(to, from, savedPosition) {
    // Let the reader view handle its own scroll restoration
    if (to.name === 'reader') {
      return false
    }
    if (savedPosition) {
      return savedPosition
    }
    return { top: 0 }
  }
})

// Update document title on navigation
router.beforeEach((to, from, next) => {
  const baseTitle = 'Align OS'
  document.title = to.meta.title ? `${to.meta.title} | ${baseTitle}` : baseTitle
  next()
})

export default router

<script setup>
import { ref, computed, inject, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReadingProgressStore } from '../stores/readingProgress'

const route = useRoute()
const router = useRouter()
const codexRegistry = inject('codexRegistry')
const glossaryManager = inject('glossaryManager')
const progressStore = useReadingProgressStore()

// Current codex
const codex = computed(() => {
  if (!codexRegistry) return null
  return codexRegistry.codexes.get(route.params.id)
})

// Rendered HTML content
const htmlContent = computed(() => {
  if (!codex.value) return ''
  // Use toHtmlWithGlossary if available, otherwise basic toHtml
  if (codex.value.toHtmlWithGlossary && glossaryManager) {
    return codex.value.toHtmlWithGlossary(glossaryManager)
  }
  return codex.value.toHtml()
})

// Scroll tracking
const contentRef = ref(null)
const scrollPercent = ref(0)
const showCopied = ref(false)

// Update document title
watch(codex, (newCodex) => {
  if (newCodex) {
    document.title = `${newCodex.title} | Align OS`
  }
}, { immediate: true })

// Scroll handler
const handleScroll = () => {
  if (!contentRef.value) return
  
  const element = document.documentElement
  const scrollTop = window.scrollY
  const scrollHeight = element.scrollHeight - element.clientHeight
  
  if (scrollHeight > 0) {
    scrollPercent.value = Math.round((scrollTop / scrollHeight) * 100)
    
    // Throttled progress update
    if (codex.value) {
      progressStore.updateProgress(codex.value.id, scrollPercent.value, scrollTop)
    }
  }
}

// Restore scroll position on mount
onMounted(async () => {
  if (codex.value) {
    const savedPosition = progressStore.getScrollPosition(codex.value.id)
    if (savedPosition > 0) {
      await nextTick()
      // Small delay to ensure content is rendered
      setTimeout(() => {
        window.scrollTo({ top: savedPosition, behavior: 'instant' })
      }, 100)
    }
  }
  
  window.addEventListener('scroll', handleScroll, { passive: true })
  handleScroll() // Initial calculation
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

// Copy markdown to clipboard
const copyMarkdown = async () => {
  if (!codex.value) return
  
  try {
    await navigator.clipboard.writeText(codex.value.markdown)
    showCopied.value = true
    setTimeout(() => {
      showCopied.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy:', err)
  }
}

// Navigation
const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

// Series navigation
const prevCodex = computed(() => {
  if (!codex.value?.siblingIds?.length) return null
  const siblings = codex.value.siblingIds
  const currentIndex = siblings.indexOf(codex.value.id)
  if (currentIndex > 0) {
    return codexRegistry?.codexes.get(siblings[currentIndex - 1])
  }
  return null
})

const nextCodex = computed(() => {
  if (!codex.value?.siblingIds?.length) return null
  const siblings = codex.value.siblingIds
  const currentIndex = siblings.indexOf(codex.value.id)
  if (currentIndex < siblings.length - 1) {
    return codexRegistry?.codexes.get(siblings[currentIndex + 1])
  }
  return null
})
</script>

<template>
  <div class="reader-view" ref="contentRef">
    <!-- Progress bar -->
    <div class="progress-bar-container">
      <div 
        class="progress-bar-fill" 
        :style="{ width: scrollPercent + '%' }"
      ></div>
    </div>
    
    <!-- Header -->
    <header class="reader-header">
      <div class="container">
        <div class="header-content">
          <button class="btn-back" @click="goBack" title="Back to browse">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            <span class="d-none d-sm-inline">Back</span>
          </button>
          
          <h1 class="reader-title" v-if="codex">{{ codex.title }}</h1>
          
          <button 
            class="btn-copy" 
            @click="copyMarkdown" 
            :title="showCopied ? 'Copied!' : 'Copy markdown to clipboard'"
          >
            <svg v-if="!showCopied" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
            </svg>
            <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
            <span class="d-none d-sm-inline">{{ showCopied ? 'Copied!' : 'Copy' }}</span>
          </button>
        </div>
      </div>
    </header>
    
    <!-- Content -->
    <article class="reader-content" v-if="codex">
      <div class="container">
        <div class="content-wrapper">
          <div 
            class="codex-content" 
            v-html="htmlContent"
          ></div>
          
          <!-- Series navigation -->
          <nav class="series-nav" v-if="prevCodex || nextCodex">
            <RouterLink 
              v-if="prevCodex" 
              :to="{ name: 'reader', params: { id: prevCodex.id } }"
              class="series-link prev"
            >
              <span class="series-label">Previous</span>
              <span class="series-title">{{ prevCodex.title }}</span>
            </RouterLink>
            
            <RouterLink 
              v-if="nextCodex" 
              :to="{ name: 'reader', params: { id: nextCodex.id } }"
              class="series-link next"
            >
              <span class="series-label">Next</span>
              <span class="series-title">{{ nextCodex.title }}</span>
            </RouterLink>
          </nav>
          
          <!-- Back to browse -->
          <div class="end-actions">
            <RouterLink to="/" class="btn-browse">
              Return to Codex Lattice
            </RouterLink>
          </div>
        </div>
      </div>
    </article>
    
    <!-- Not found -->
    <div v-else class="not-found">
      <div class="container text-center py-5">
        <h2>Codex not found</h2>
        <p>The codex you're looking for doesn't exist.</p>
        <RouterLink to="/" class="btn btn-primary">Browse Codexes</RouterLink>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.reader-view {
  min-height: 100vh;
  background: var(--cl-reader-bg);
}

.progress-bar-container {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--cl-progress-track);
  z-index: 1100;
}

.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--cl-primary), var(--cl-accent));
  transition: width 0.1s ease-out;
}

.reader-header {
  position: sticky;
  top: 0;
  background: var(--cl-reader-bg);
  border-bottom: 1px solid var(--cl-border-light);
  z-index: 1000;
  padding: 0.75rem 0;
  
  @supports (backdrop-filter: blur(10px)) {
    background: rgba(255, 253, 249, 0.9);
    backdrop-filter: blur(10px);
    
    @media (prefers-color-scheme: dark) {
      background: rgba(37, 42, 61, 0.9);
    }
  }
}

.header-content {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.reader-title {
  flex: 1;
  font-family: var(--bs-font-serif);
  font-size: 1rem;
  font-weight: 500;
  color: var(--cl-text-heading);
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: center;
  
  @media (min-width: 768px) {
    font-size: 1.125rem;
  }
}

.btn-back,
.btn-copy {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--cl-border-light);
  border-radius: var(--bs-border-radius);
  background: var(--cl-surface);
  color: var(--cl-text-muted);
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s ease;
  
  &:hover {
    background: var(--cl-surface-hover);
    color: var(--cl-text);
    border-color: var(--cl-border);
  }
}

.reader-content {
  padding: 2rem 0 4rem;
}

.content-wrapper {
  max-width: 720px;
  margin: 0 auto;
}

.series-nav {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 4rem;
  padding-top: 2rem;
  border-top: 1px solid var(--cl-border-light);
}

.series-link {
  display: flex;
  flex-direction: column;
  padding: 1rem;
  background: var(--cl-surface);
  border-radius: var(--bs-border-radius-lg);
  text-decoration: none;
  transition: all 0.2s ease;
  
  &:hover {
    background: var(--cl-surface-hover);
    transform: translateY(-2px);
  }
  
  &.next {
    text-align: right;
    grid-column: 2;
  }
  
  &.prev {
    grid-column: 1;
  }
}

.series-label {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--cl-text-muted);
  margin-bottom: 0.25rem;
}

.series-title {
  font-family: var(--bs-font-serif);
  font-size: 1rem;
  color: var(--cl-primary);
  font-weight: 500;
}

.end-actions {
  text-align: center;
  margin-top: 3rem;
}

.btn-browse {
  display: inline-flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  background: var(--cl-primary);
  color: white;
  border-radius: var(--bs-border-radius);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
  
  &:hover {
    background: var(--cl-primary-hover);
    color: white;
  }
}

.not-found {
  padding: 4rem 0;
  
  h2 {
    color: var(--cl-text-heading);
    margin-bottom: 1rem;
  }
  
  p {
    color: var(--cl-text-muted);
  }
}
</style>

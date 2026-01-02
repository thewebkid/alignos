<script setup>
import { ref, computed, watch, inject, nextTick } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  show: Boolean
})

const emit = defineEmits(['close'])

const router = useRouter()
const codexRegistry = inject('codexRegistry')

const searchInput = ref(null)
const query = ref('')
const results = ref([])
const selectedIndex = ref(0)

// Focus input when overlay opens
watch(() => props.show, async (newShow) => {
  if (newShow) {
    await nextTick()
    searchInput.value?.focus()
    query.value = ''
    results.value = []
    selectedIndex.value = 0
  }
})

// Search as user types
watch(query, (newQuery) => {
  if (!newQuery.trim()) {
    results.value = []
    return
  }
  
  if (codexRegistry) {
    const searchResults = codexRegistry.search(newQuery, { limit: 10 })
    results.value = searchResults.map(result => {
      // search returns { codex, score, match, snippet }
      return {
        id: result.codex.id,
        codex: result.codex,
        score: result.score,
        match: result.match,
        snippet: result.snippet || getSnippet(result.codex, newQuery)
      }
    })
    selectedIndex.value = 0
  }
})

// Get text snippet with match
const getSnippet = (codex, searchQuery) => {
  if (!codex) return ''
  const snippet = codex.getSnippet(searchQuery, 120)
  if (!snippet) return ''
  
  // Highlight matching text
  const regex = new RegExp(`(${escapeRegex(searchQuery)})`, 'gi')
  return snippet.replace(regex, '<mark>$1</mark>')
}

const escapeRegex = (string) => {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

// Keyboard navigation
const handleKeydown = (e) => {
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    selectedIndex.value = Math.min(selectedIndex.value + 1, results.value.length - 1)
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    selectedIndex.value = Math.max(selectedIndex.value - 1, 0)
  } else if (e.key === 'Enter' && results.value.length > 0) {
    e.preventDefault()
    selectResult(results.value[selectedIndex.value])
  } else if (e.key === 'Escape') {
    emit('close')
  }
}

// Select a result
const selectResult = (result) => {
  if (result?.codex) {
    router.push({ name: 'reader', params: { id: result.codex.id } })
    emit('close')
  }
}

// Close on backdrop click
const handleBackdropClick = (e) => {
  if (e.target === e.currentTarget) {
    emit('close')
  }
}
</script>

<template>
  <Teleport to="body">
    <Transition name="overlay">
      <div 
        v-if="show" 
        class="search-overlay"
        @click="handleBackdropClick"
        @keydown="handleKeydown"
      >
        <div class="search-modal">
          <!-- Search input -->
          <div class="search-input-wrapper">
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"/>
              <path d="m21 21-4.35-4.35"/>
            </svg>
            <input
              ref="searchInput"
              v-model="query"
              type="text"
              class="search-input"
              placeholder="Search codexes..."
              autocomplete="off"
            />
            <kbd class="search-hint">ESC</kbd>
          </div>
          
          <!-- Results -->
          <div class="search-results" v-if="results.length > 0">
            <button
              v-for="(result, index) in results"
              :key="result.id"
              class="search-result"
              :class="{ selected: index === selectedIndex }"
              @click="selectResult(result)"
              @mouseenter="selectedIndex = index"
            >
              <div class="result-cover" v-if="result.codex?.coverImage">
                <img 
                  :src="`/md/${result.codex.coverImage}`" 
                  :alt="result.codex.title"
                  loading="lazy"
                />
              </div>
              <div class="result-content">
                <div class="result-title">{{ result.codex?.title }}</div>
                <div 
                  class="result-snippet" 
                  v-if="result.snippet"
                  v-html="result.snippet"
                ></div>
              </div>
            </button>
          </div>
          
          <!-- Empty state -->
          <div class="search-empty" v-else-if="query.trim()">
            <p>No codexes found for "{{ query }}"</p>
          </div>
          
          <!-- Initial state -->
          <div class="search-initial" v-else>
            <p>Start typing to search through all codexes...</p>
          </div>
          
          <!-- Footer hints -->
          <div class="search-footer">
            <span class="hint"><kbd>↑↓</kbd> Navigate</span>
            <span class="hint"><kbd>↵</kbd> Select</span>
            <span class="hint"><kbd>ESC</kbd> Close</span>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style lang="scss" scoped>
.search-overlay {
  position: fixed;
  inset: 0;
  background: var(--cl-overlay);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 10vh 1rem;
  z-index: 2000;
  backdrop-filter: blur(4px);
}

.search-modal {
  width: 100%;
  max-width: 600px;
  background: var(--cl-surface);
  border-radius: var(--bs-border-radius-lg);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  overflow: hidden;
}

.search-input-wrapper {
  display: flex;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid var(--cl-border-light);
  gap: 0.75rem;
}

.search-icon {
  color: var(--cl-text-muted);
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 1.125rem;
  color: var(--cl-text);
  outline: none;
  
  &::placeholder {
    color: var(--cl-text-muted);
  }
}

.search-hint {
  background: var(--cl-surface-hover);
  border: 1px solid var(--cl-border-light);
  border-radius: 4px;
  padding: 0.125rem 0.5rem;
  font-size: 0.75rem;
  color: var(--cl-text-muted);
}

.search-results {
  max-height: 400px;
  overflow-y: auto;
}

.search-result {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem;
  width: 100%;
  text-align: left;
  border: none;
  background: transparent;
  cursor: pointer;
  transition: background-color 0.1s ease;
  
  &:hover,
  &.selected {
    background: var(--cl-surface-hover);
  }
  
  & + & {
    border-top: 1px solid var(--cl-border-light);
  }
}

.result-cover {
  width: 48px;
  height: 64px;
  border-radius: var(--bs-border-radius-sm);
  overflow: hidden;
  flex-shrink: 0;
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.result-content {
  flex: 1;
  min-width: 0;
}

.result-title {
  font-family: var(--bs-font-serif);
  font-weight: 500;
  color: var(--cl-text-heading);
  margin-bottom: 0.25rem;
}

.result-snippet {
  font-size: 0.875rem;
  color: var(--cl-text-muted);
  line-height: 1.5;
  
  :deep(mark) {
    background: var(--cl-accent);
    color: white;
    padding: 0 0.125rem;
    border-radius: 2px;
  }
}

.search-empty,
.search-initial {
  padding: 2rem;
  text-align: center;
  color: var(--cl-text-muted);
  
  p {
    margin: 0;
  }
}

.search-footer {
  display: flex;
  gap: 1rem;
  justify-content: center;
  padding: 0.75rem;
  background: var(--cl-surface-hover);
  border-top: 1px solid var(--cl-border-light);
  
  .hint {
    font-size: 0.75rem;
    color: var(--cl-text-muted);
    
    kbd {
      background: var(--cl-surface);
      border: 1px solid var(--cl-border-light);
      border-radius: 3px;
      padding: 0.0625rem 0.375rem;
      margin-right: 0.25rem;
    }
  }
}

// Transition
.overlay-enter-active,
.overlay-leave-active {
  transition: opacity 0.2s ease;
  
  .search-modal {
    transition: transform 0.2s ease, opacity 0.2s ease;
  }
}

.overlay-enter-from,
.overlay-leave-to {
  opacity: 0;
  
  .search-modal {
    transform: scale(0.95) translateY(-10px);
    opacity: 0;
  }
}
</style>

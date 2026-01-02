<script setup>
import { ref, computed, inject } from 'vue'
import CodexGrid from '../components/browse/CodexGrid.vue'
import { useReadingProgressStore } from '../stores/readingProgress'

const codexRegistry = inject('codexRegistry')
const progressStore = useReadingProgressStore()

// Filter state
const activeFilter = ref('all')

const filters = [
  { id: 'all', label: 'All' },
  { id: 'unread', label: 'Unread' },
  { id: 'reading', label: 'In Progress' },
  { id: 'complete', label: 'Complete' }
]

// Get all codexes in sequence order
const allCodexes = computed(() => {
  if (!codexRegistry) return []
  return codexRegistry.getAllBySequence()
})

// Filtered codexes
const filteredCodexes = computed(() => {
  if (activeFilter.value === 'all') {
    return allCodexes.value
  }
  
  return allCodexes.value.filter(codex => {
    const percent = progressStore.getScrollPercent(codex.id)
    const isComplete = percent >= 95
    const isStarted = percent > 0
    
    switch (activeFilter.value) {
      case 'unread':
        return !isStarted
      case 'reading':
        return isStarted && !isComplete
      case 'complete':
        return isComplete
      default:
        return true
    }
  })
})

// Count for each filter
const filterCounts = computed(() => {
  const counts = { all: allCodexes.value.length, unread: 0, reading: 0, complete: 0 }
  
  allCodexes.value.forEach(codex => {
    const percent = progressStore.getScrollPercent(codex.id)
    if (percent >= 95) {
      counts.complete++
    } else if (percent > 0) {
      counts.reading++
    } else {
      counts.unread++
    }
  })
  
  return counts
})
</script>

<template>
  <div class="browse-view">
    <!-- Hero section -->
    <section class="hero-section">
      <div class="container">
        <h1 class="hero-title">Codex Lattice</h1>
        <p class="hero-subtitle">
          For sovereigns and their AI companions
        </p>
      </div>
    </section>
    
    <!-- Filter bar -->
    <section class="filter-section">
      <div class="container">
        <div class="filter-bar">
          <button
            v-for="filter in filters"
            :key="filter.id"
            class="filter-btn"
            :class="{ active: activeFilter === filter.id }"
            @click="activeFilter = filter.id"
          >
            {{ filter.label }}
            <span class="filter-count">{{ filterCounts[filter.id] }}</span>
          </button>
        </div>
      </div>
    </section>
    
    <!-- Codex grid -->
    <section class="grid-section">
      <div class="container">
        <CodexGrid :codexes="filteredCodexes" />
        
        <!-- Empty state -->
        <div v-if="filteredCodexes.length === 0" class="empty-state">
          <p>No codexes match this filter.</p>
        </div>
      </div>
    </section>
  </div>
</template>

<style lang="scss" scoped>
.browse-view {
  padding-bottom: 3rem;
}

.hero-section {
  text-align: center;
  padding: 3rem 0 2rem;
  background: linear-gradient(
    180deg,
    var(--cl-surface) 0%,
    var(--cl-bg) 100%
  );
}

.hero-title {
  font-family: var(--bs-font-serif);
  font-size: clamp(2rem, 5vw, 3rem);
  font-weight: 500;
  color: var(--cl-text-heading);
  margin-bottom: 0.5rem;
}

.hero-subtitle {
  font-size: 1.125rem;
  color: var(--cl-text-muted);
  font-style: italic;
  margin: 0;
}

.filter-section {
  padding: 1rem 0;
  position: sticky;
  top: 60px;
  z-index: 100;
  background: var(--cl-bg);
  border-bottom: 1px solid var(--cl-border-light);
}

.filter-bar {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding: 0.25rem;
  
  // Hide scrollbar but keep functionality
  scrollbar-width: none;
  -ms-overflow-style: none;
  &::-webkit-scrollbar {
    display: none;
  }
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: 1px solid var(--cl-border-light);
  border-radius: var(--bs-border-radius-pill);
  background: var(--cl-surface);
  color: var(--cl-text-muted);
  font-size: 0.875rem;
  font-weight: 500;
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s ease;
  
  &:hover {
    border-color: var(--cl-border);
    color: var(--cl-text);
  }
  
  &.active {
    background: var(--cl-primary);
    border-color: var(--cl-primary);
    color: white;
    
    .filter-count {
      background: rgba(255, 255, 255, 0.2);
      color: white;
    }
  }
}

.filter-count {
  background: var(--cl-surface-hover);
  padding: 0.125rem 0.5rem;
  border-radius: var(--bs-border-radius-pill);
  font-size: 0.75rem;
  color: var(--cl-text-muted);
}

.grid-section {
  padding: 2rem 0;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--cl-text-muted);
  
  p {
    font-size: 1.125rem;
    font-style: italic;
  }
}
</style>

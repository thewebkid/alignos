<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useReadingProgressStore } from '../../stores/readingProgress'
import ProgressRing from './ProgressRing.vue'

const props = defineProps({
  codex: {
    type: Object,
    required: true
  }
})

const progressStore = useReadingProgressStore()

const scrollPercent = computed(() => {
  return progressStore.getScrollPercent(props.codex.id)
})

const isComplete = computed(() => scrollPercent.value >= 95)
const isStarted = computed(() => scrollPercent.value > 0)

// Build cover image path
const coverSrc = computed(() => {
  if (!props.codex.coverImage) return null
  // The coverImage is relative to md folder, we need to adjust for the public path
  return `/md/${props.codex.coverImage}`
})

// Truncate title if too long
const displayTitle = computed(() => {
  const title = props.codex.title
  if (title.length > 60) {
    return title.substring(0, 57) + '...'
  }
  return title
})

// Series badge
const seriesBadge = computed(() => {
  if (!props.codex.series) return null
  return props.codex.series.name
})
</script>

<template>
  <RouterLink 
    :to="{ name: 'reader', params: { id: codex.id } }" 
    class="codex-card"
    :class="{ 
      'is-complete': isComplete, 
      'is-started': isStarted && !isComplete,
      'is-unread': !isStarted 
    }"
  >
    <!-- Cover image -->
    <div class="card-cover">
      <img 
        v-if="coverSrc" 
        :src="coverSrc" 
        :alt="codex.title"
        loading="lazy"
        class="cover-image"
      />
      <div v-else class="cover-placeholder">
        <span>{{ codex.title.charAt(0) }}</span>
      </div>
      
      <!-- Progress indicator -->
      <div class="progress-indicator" v-if="isStarted">
        <ProgressRing 
          :percent="scrollPercent" 
          :size="36"
          :stroke-width="3"
        />
      </div>
      
      <!-- Complete checkmark -->
      <div class="complete-badge" v-if="isComplete">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/>
        </svg>
      </div>
    </div>
    
    <!-- Card content -->
    <div class="card-content">
      <h3 class="card-title">{{ displayTitle }}</h3>
      
      <div class="card-meta" v-if="seriesBadge">
        <span class="series-badge">{{ seriesBadge }}</span>
      </div>
    </div>
  </RouterLink>
</template>

<style lang="scss" scoped>
.codex-card {
  display: flex;
  flex-direction: column;
  background: var(--cl-surface);
  border-radius: var(--bs-border-radius-lg);
  overflow: hidden;
  text-decoration: none;
  color: inherit;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  box-shadow: 0 2px 8px var(--cl-shadow);
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px var(--cl-shadow-lg);
  }
  
  &.is-unread {
    opacity: var(--cl-card-unread-opacity);
    
    &:hover {
      opacity: 1;
    }
  }
  
  &.is-complete {
    .card-cover::after {
      content: '';
      position: absolute;
      inset: 0;
      border: 2px solid var(--cl-card-complete-glow);
      border-radius: inherit;
      pointer-events: none;
    }
  }
}

.card-cover {
  position: relative;
  aspect-ratio: 3 / 4;
  overflow: hidden;
  background: var(--cl-surface-hover);
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
  
  .codex-card:hover & {
    transform: scale(1.03);
  }
}

.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--cl-primary), var(--cl-accent));
  color: white;
  font-family: var(--bs-font-serif);
  font-size: 3rem;
  font-weight: 500;
}

.progress-indicator {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  background: var(--cl-surface);
  border-radius: 50%;
  padding: 2px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.complete-badge {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  width: 28px;
  height: 28px;
  background: var(--cl-accent);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.card-content {
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-title {
  font-family: var(--bs-font-serif);
  font-size: 1rem;
  font-weight: 500;
  color: var(--cl-text-heading);
  margin: 0;
  line-height: 1.4;
  flex: 1;
}

.card-meta {
  margin-top: 0.5rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.series-badge {
  font-size: 0.75rem;
  padding: 0.125rem 0.5rem;
  background: var(--cl-surface-hover);
  border-radius: var(--bs-border-radius-pill);
  color: var(--cl-text-muted);
}
</style>

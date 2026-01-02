<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useReadingProgressStore } from '../../stores/readingProgress'

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
      
      <!-- Reading progress bar -->
      <div class="progress-bar-container" v-if="isStarted">
        <div class="progress-bar" :style="{ width: scrollPercent + '%' }"></div>
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
}

.card-cover {
  position: relative;
  aspect-ratio: 2 / 3;
  overflow: hidden;
  background: var(--cl-surface-hover);
  
  @media (min-width: 640px) {
    aspect-ratio: 3 / 4;
  }
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

.progress-bar-container {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: transparent;
}

.progress-bar {
  height: 100%;
  background: #10b981;
  transition: width 0.3s ease;
}

.card-content {
  padding: 0.75rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  
  @media (min-width: 640px) {
    padding: 1rem;
  }
}

.card-title {
  font-family: var(--bs-font-serif);
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--cl-text-heading);
  margin: 0;
  line-height: 1.4;
  flex: 1;
  
  @media (min-width: 640px) {
    font-size: 1rem;
  }
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

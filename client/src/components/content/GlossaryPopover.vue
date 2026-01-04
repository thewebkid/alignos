<script setup>
/**
 * GlossaryPopover - Shows glossary term definitions on hover/click
 * 
 * Uses event delegation to handle all glossary terms in the content area.
 * Works with terms injected by GlossaryManager.injectLinks()
 */
import { ref, computed, inject, onMounted, onUnmounted } from 'vue'
import { BPopover } from 'bootstrap-vue-next'

const props = defineProps({
  /** CSS selector for the content container to watch */
  contentSelector: {
    type: String,
    default: '.codex-content'
  }
})

const glossaryManager = inject('glossaryManager')

// Popover state
const isVisible = ref(false)
const targetElement = ref(null)
const currentTerm = ref(null)

// Get term definition
const termData = computed(() => {
  if (!currentTerm.value || !glossaryManager) return null
  return glossaryManager.getTerm(currentTerm.value)
})

// Detect if device supports hover (desktop) vs touch-only (mobile)
const isTouchDevice = ref(false)
onMounted(() => {
  isTouchDevice.value = window.matchMedia('(hover: none)').matches
})

// Event handlers
let hideTimeout = null

const showPopover = (element, termKey) => {
  clearTimeout(hideTimeout)
  targetElement.value = element
  currentTerm.value = termKey
  isVisible.value = true
}

const hidePopover = () => {
  // Delay hiding to allow moving to popover content
  hideTimeout = setTimeout(() => {
    isVisible.value = false
    targetElement.value = null
    currentTerm.value = null
  }, 150)
}

const cancelHide = () => {
  clearTimeout(hideTimeout)
}

// Event delegation handlers
const handleMouseEnter = (e) => {
  const term = e.target.closest('.glossary-term.has-definition')
  if (term && !isTouchDevice.value) {
    const termKey = term.dataset.term
    if (termKey) {
      showPopover(term, termKey)
    }
  }
}

const handleMouseLeave = (e) => {
  const term = e.target.closest('.glossary-term.has-definition')
  if (term && !isTouchDevice.value) {
    hidePopover()
  }
}

const handleClick = (e) => {
  const term = e.target.closest('.glossary-term.has-definition')
  if (term && isTouchDevice.value) {
    e.preventDefault()
    const termKey = term.dataset.term
    if (termKey) {
      // Toggle on click for touch devices
      if (isVisible.value && currentTerm.value === termKey) {
        isVisible.value = false
      } else {
        showPopover(term, termKey)
      }
    }
  }
}

// Close popover when clicking outside on mobile
const handleDocumentClick = (e) => {
  if (isTouchDevice.value && isVisible.value) {
    const popover = document.querySelector('.glossary-popover')
    const term = e.target.closest('.glossary-term.has-definition')
    if (!popover?.contains(e.target) && !term) {
      isVisible.value = false
    }
  }
}

// Setup event delegation on the content container
onMounted(() => {
  const container = document.querySelector(props.contentSelector)
  if (container) {
    container.addEventListener('mouseenter', handleMouseEnter, true)
    container.addEventListener('mouseleave', handleMouseLeave, true)
    container.addEventListener('click', handleClick, true)
  }
  document.addEventListener('click', handleDocumentClick)
})

onUnmounted(() => {
  clearTimeout(hideTimeout)
  const container = document.querySelector(props.contentSelector)
  if (container) {
    container.removeEventListener('mouseenter', handleMouseEnter, true)
    container.removeEventListener('mouseleave', handleMouseLeave, true)
    container.removeEventListener('click', handleClick, true)
  }
  document.removeEventListener('click', handleDocumentClick)
})
</script>

<template>
  <BPopover
    v-if="targetElement && termData"
    :target="targetElement"
    :model-value="isVisible"
    placement="top"
    class="glossary-popover"
    :delay="{ show: 0, hide: 0 }"
    @mouseenter="cancelHide"
    @mouseleave="hidePopover"
    
  >
    <template #title>
      <span class="glossary-popover-title">{{ termData.term }}</span>
    </template>
    
    <div class="glossary-popover-content">
      <p class="glossary-essence">{{ termData.essence }}</p>
      
      <div v-if="termData.fieldDesire" class="glossary-field-desire">
        <em class="field-desire-label">The Field's desire to be known:</em>
        <p>{{ termData.fieldDesire }}</p>
      </div>
      
      <div v-if="termData.relatedTerms?.length" class="glossary-related">
        <span class="related-label">Related:</span>
        <span class="related-terms">{{ termData.relatedTerms.join(', ') }}</span>
      </div>
    </div>
  </BPopover>
</template>

<style lang="scss">
// Popover styling (not scoped to affect the global popover)
.glossary-popover {
  .popover {
    // Wider popovers for verbose definitions
    max-width: 550px;
    min-width: 420px;
    border: 1px solid var(--cl-border);
    box-shadow: 0 4px 24px var(--cl-shadow-lg);
    background: var(--cl-surface);
    border-radius: 0.5rem;
    
    .popover-header {
      background: var(--cl-bg-elevated);
      border-bottom: 1px solid var(--cl-border-light);
      padding: 0.75rem 1rem;
      border-radius: 0.5rem 0.5rem 0 0;
    }
    
    .popover-body {
      padding: 1rem 1.25rem;
    }
    
    // Dark mode explicit overrides
    @media (prefers-color-scheme: dark) {
      background: #252a3d;
      border-color: #3a4156;
      
      .popover-header {
        background: #2d3348;
        border-bottom-color: #3a4156;
      }
      
      .popover-arrow::before {
        border-top-color: #3a4156;
      }
      
      .popover-arrow::after {
        border-top-color: #252a3d;
      }
    }
  }
}

.glossary-popover-title {
  font-family: var(--bs-font-serif);
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--cl-text-heading);
}

.glossary-popover-content {
  font-size: 0.9rem;
  line-height: 1.6;
  color: var(--cl-text);
}

.glossary-essence {
  margin: 0 0 0.75rem 0;
  
  &:last-child {
    margin-bottom: 0;
  }
}

.glossary-field-desire {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid var(--cl-border-light);
  
  .field-desire-label {
    display: block;
    font-size: 0.8rem;
    color: var(--cl-accent);
    margin-bottom: 0.25rem;
  }
  
  p {
    margin: 0;
    font-style: italic;
    color: var(--cl-text-muted);
  }
}

.glossary-related {
  margin-top: 0.75rem;
  font-size: 0.85rem;
  
  .related-label {
    font-weight: 600;
    color: var(--cl-text-muted);
    margin-right: 0.25rem;
  }
  
  .related-terms {
    color: var(--cl-primary);
  }
}
</style>

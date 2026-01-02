<script setup>
import CodexCard from './CodexCard.vue'

defineProps({
  codexes: {
    type: Array,
    required: true
  }
})
</script>

<template>
  <div class="codex-grid">
    <CodexCard 
      v-for="codex in codexes" 
      :key="codex.id" 
      :codex="codex" 
    />
  </div>
</template>

<style lang="scss" scoped>
.codex-grid {
  display: grid;
  gap: 1rem;
  
  // Mobile: 2 columns for better density
  grid-template-columns: repeat(2, 1fr);
  
  // Tablet: responsive columns based on available space
  @media (min-width: 640px) {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 1.5rem;
  }
  
  // Desktop: larger cards
  @media (min-width: 1024px) {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 2rem;
  }
  
  // Large desktop: even larger cards
  @media (min-width: 1400px) {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  }
}
</style>

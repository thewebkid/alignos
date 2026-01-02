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
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1.5rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 2rem;
  }
  
  @media (min-width: 1200px) {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  }
}
</style>

<script setup>
import { ref, computed, inject, watch } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import CodexCard from '../components/browse/CodexCard.vue'

const route = useRoute()
const codexRegistry = inject('codexRegistry')

const query = computed(() => route.query.q || '')

const results = computed(() => {
  if (!query.value.trim() || !codexRegistry) return []
  
  const searchResults = codexRegistry.search(query.value, { limit: 50 })
  return searchResults.map(result => codexRegistry.getById(result.id)).filter(Boolean)
})
</script>

<template>
  <div class="search-view">
    <div class="container">
      <header class="search-header">
        <h1>Search Results</h1>
        <p v-if="query">
          {{ results.length }} result{{ results.length !== 1 ? 's' : '' }} for "{{ query }}"
        </p>
      </header>
      
      <div class="search-results" v-if="results.length > 0">
        <div class="codex-grid">
          <CodexCard 
            v-for="codex in results" 
            :key="codex.id" 
            :codex="codex" 
          />
        </div>
      </div>
      
      <div class="no-results" v-else-if="query">
        <p>No codexes found matching your search.</p>
        <RouterLink to="/" class="btn btn-primary">Browse All Codexes</RouterLink>
      </div>
      
      <div class="no-query" v-else>
        <p>Enter a search term to find codexes.</p>
        <RouterLink to="/" class="btn btn-primary">Browse All Codexes</RouterLink>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.search-view {
  padding: 2rem 0 4rem;
}

.search-header {
  text-align: center;
  margin-bottom: 2rem;
  
  h1 {
    font-family: var(--bs-font-serif);
    color: var(--cl-text-heading);
    margin-bottom: 0.5rem;
  }
  
  p {
    color: var(--cl-text-muted);
  }
}

.codex-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1.5rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 2rem;
  }
}

.no-results,
.no-query {
  text-align: center;
  padding: 4rem 2rem;
  
  p {
    color: var(--cl-text-muted);
    margin-bottom: 1.5rem;
  }
}
</style>

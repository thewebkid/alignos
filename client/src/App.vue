<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <div class="container mt-5">
    <h1>AlignOS Setup Complete</h1>
    <p>Vue 3 + BootstrapVueNext + Express + MongoDB</p>
    
    <BCard title="Card Title" style="max-width: 20rem;" class="mb-2">
      <BCardText>
        Some quick example text to build on the card title and make up the bulk of the card's content.
      </BCardText>
      <BButton href="#" variant="primary" @click="count++">Count is {{ count }}</BButton>
    </BCard>

    <BAlert :model-value="true" variant="success" class="mt-3">
      BootstrapVueNext is working!
    </BAlert>
  </div>
</template>

<style scoped>
</style>

<script setup>
// Invites readers to carry their progress to alignos.io: a dialog on the first visit, then a banner
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { BModal } from 'bootstrap-vue-next'
import { useReadingProgressStore } from '../stores/readingProgress.js'
import { ALIGNOS_ORIGIN, HANDOFF_MODE, handoffLink, readStats } from '../lib/handoff.js'
import { track } from '../lib/tracker.js'

const PROMPTED_KEY = 'alignos-handoff-prompted'
const BANNER_HIDDEN_KEY = 'alignos-handoff-banner-hidden'

const route = useRoute()
const progressStore = useReadingProgressStore()

// Client-only: the reader is prerendered, and storage decides everything shown here
const ready = ref(false)
const link = ref('')
const stats = ref({ read: 0, completed: 0 })
const dialogOpen = ref(false)
const bannerHidden = ref(false)

const host = new URL(ALIGNOS_ORIGIN).host
const showBanner = computed(() => ready.value && link.value && !dialogOpen.value && !bannerHidden.value)

let timer = null
const rebuild = async () => {
  stats.value = readStats()
  link.value = await handoffLink(route.fullPath)
}
const rebuildSoon = () => {
  clearTimeout(timer)
  timer = setTimeout(rebuild, 300)
}

onMounted(async () => {
  if (HANDOFF_MODE !== 'prompt') return
  bannerHidden.value = sessionStorage.getItem(BANNER_HIDDEN_KEY) !== null
  await rebuild()
  ready.value = true

  if (localStorage.getItem(PROMPTED_KEY) === null) {
    localStorage.setItem(PROMPTED_KEY, new Date().toISOString())
    dialogOpen.value = true
    track('handoffPrompt', stats.value)
  }

  // The link is a plain href, so it must already hold the latest progress when tapped
  watch(() => route.fullPath, rebuild)
  watch(() => progressStore.progress, rebuildSoon, { deep: true })
})

onBeforeUnmount(() => clearTimeout(timer))

const hideBanner = () => {
  bannerHidden.value = true
  sessionStorage.setItem(BANNER_HIDDEN_KEY, '1')
}

const decline = () => {
  dialogOpen.value = false
  hideBanner()
  track('handoffDeclined', stats.value)
}

// Closing by ×, Escape, or the backdrop counts as "Not now"
const onHidden = () => {
  if (!bannerHidden.value) decline()
}

const accepted = (from) => track('handoffAccepted', { from, ...stats.value })

const codices = (n) => `${n} ${n === 1 ? 'codex' : 'codices'}`
</script>

<template>
  <template v-if="ready">
    <BModal
      v-model="dialogOpen"
      title="Alignos has a new home"
      centered
      no-footer
      content-class="handoff-modal"
      @hidden="onHidden"
    >
      <p v-if="stats.read">
        You’ve read {{ codices(stats.read) }} here<template v-if="stats.completed">, {{ stats.completed }} to the end</template>.
        Take your reading to {{ host }} and pick up right where you left off. Your place in every codex comes with you.
      </p>
      <p v-else>
        The Codex Lattice now lives at {{ host }}, with the same codices in a new reader.
      </p>
      <div class="handoff-actions">
        <a v-if="link" :href="link" class="handoff-button" @click="accepted('dialog')">
          {{ stats.read ? `Take my reading to ${host}` : `Go to ${host}` }}
        </a>
        <button type="button" class="handoff-quiet" @click="decline">Not now</button>
      </div>
    </BModal>

    <aside v-if="showBanner" class="handoff-banner" aria-label="Alignos has moved">
      <span>Alignos has moved to {{ host }}.</span>
      <a :href="link" @click="accepted('banner')">
        {{ stats.read ? 'Take my reading there' : `Visit ${host}` }} →
      </a>
      <button type="button" class="handoff-close" aria-label="Hide for now" @click="hideBanner">×</button>
    </aside>
  </template>
</template>

<style lang="scss">
.handoff-modal {
  background: var(--cl-bg-elevated);
  color: var(--cl-text);
  border: 1px solid var(--cl-border);

  .modal-header {
    border-bottom-color: var(--cl-border-light);
  }

  .modal-title {
    font-family: var(--bs-font-serif);
    font-weight: 500;
    color: var(--cl-text-heading);
  }

  p {
    line-height: 1.6;
  }

  .handoff-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.75rem;
    margin-top: 1.25rem;
  }

  .handoff-button {
    padding: 0.625rem 1.25rem;
    border-radius: var(--bs-border-radius-lg);
    background: var(--cl-primary);
    color: white;
    font-weight: 500;
    text-decoration: none;

    &:hover {
      background: var(--cl-primary-hover);
      color: white;
    }
  }

  .handoff-quiet {
    padding: 0.625rem 1rem;
    border: 0;
    background: transparent;
    color: var(--cl-text-muted);

    &:hover {
      color: var(--cl-text);
    }
  }
}

.handoff-banner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 0.25rem 0.75rem;
  padding: 0.625rem 3rem 0.625rem 1rem;
  position: relative;
  background: var(--cl-bg-elevated);
  border-bottom: 1px solid var(--cl-border);
  font-size: 0.9375rem;

  a {
    color: var(--cl-primary);
    font-weight: 600;
    text-decoration: none;

    &:hover {
      color: var(--cl-primary-hover);
    }
  }

  .handoff-close {
    position: absolute;
    right: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    width: 2rem;
    height: 2rem;
    border: 0;
    background: transparent;
    color: var(--cl-text-muted);
    font-size: 1.25rem;
    line-height: 1;

    &:hover {
      color: var(--cl-text);
    }
  }
}
</style>

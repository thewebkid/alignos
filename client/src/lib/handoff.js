// Builds the link that carries this reader's progress to alignos.io/import. Encoding half of
// alignos.io's client/src/lib/handoff/envelope.js; the wire format is pinned by fixtures there.
// Reads localStorage directly so forward mode can run before Pinia exists.

export const ALIGNOS_ORIGIN = (import.meta.env.VITE_ALIGNOS_ORIGIN || 'https://alignos.io').replace(/\/+$/, '')

const MODES = ['off', 'prompt', 'forward']
export const HANDOFF_MODE = MODES.includes(import.meta.env.VITE_HANDOFF_MODE) ? import.meta.env.VITE_HANDOFF_MODE : 'prompt'

const PROGRESS_KEY = 'codex-reading-progress'
const THEME_KEY = 'alignos-theme'
const THEMES = ['light', 'dark', 'system']

const readJson = (key) => {
  try {
    return JSON.parse(localStorage.getItem(key) || '{}') || {}
  } catch {
    return {}
  }
}

// { [id]: { scrollPercent, scrollPosition (px), lastRead } } -> tuples [furthest, null, lastRead seconds].
// Pixel positions mean nothing on another device, so position always travels as null (= furthest).
export function readProgress() {
  const tuples = {}
  for (const [id, entry] of Object.entries(readJson(PROGRESS_KEY))) {
    const seconds = Math.floor(Date.parse(entry?.lastRead) / 1000)
    const percent = Number(entry?.scrollPercent)
    if (!Number.isFinite(seconds) || seconds <= 0 || !Number.isFinite(percent)) continue
    tuples[id] = [Math.round(Math.min(1, Math.max(0, percent / 100)) * 10000) / 10000, null, seconds]
  }
  return tuples
}

export function readStats() {
  const entries = Object.values(readJson(PROGRESS_KEY))
  return { read: entries.length, completed: entries.filter((e) => Number(e?.scrollPercent) >= 95).length }
}

export function buildDocument(to) {
  const doc = { kind: 'alignos-progress', v: 1, src: 'reader', lattice: 'reader', exportedAt: Math.floor(Date.now() / 1000) }
  const theme = localStorage.getItem(THEME_KEY)
  if (THEMES.includes(theme)) doc.theme = theme
  if (to) doc.to = to
  doc.progress = readProgress()
  return doc
}

const toBase64Url = (bytes) => {
  let binary = ''
  for (const b of bytes) binary += String.fromCharCode(b)
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

const deflate = async (bytes) => {
  const stream = new Blob([bytes]).stream().pipeThrough(new CompressionStream('deflate-raw'))
  return new Uint8Array(await new Response(stream).arrayBuffer())
}

export async function encodeDocument(doc) {
  const bytes = new TextEncoder().encode(JSON.stringify(doc))
  if (typeof CompressionStream === 'function') {
    try {
      return `z=${toBase64Url(await deflate(bytes))}`
    } catch {
      // Older engines may know CompressionStream but not 'deflate-raw'
    }
  }
  return `j=${toBase64Url(bytes)}`
}

// `to` is the reader path the visitor is on; alignos.io maps it (and retired codex ids) to its own pages
export async function handoffLink(to) {
  return `${ALIGNOS_ORIGIN}/import#${await encodeDocument(buildDocument(to))}`
}

# AlignOS - Reader

A reading companion for AlignOS.io  
[https://alignos.cosmiccreation.net](https://alignos.cosmiccreation.net)

## Features

- **Codex Browser**: Navigate through the Codex Lattice
- **Full-Text Search**: Lunr.js client-side search
- **Markdown Rendering**: Marked + DOMPurify
- **Prerendered pages**: Vite SSG for SEO / LLM-friendly HTML
- **Public JSON API**: Static `/api/*` endpoints for discovery (see `/llms.json`)
- **Analytics**: Vercel Web Analytics + custom events (opt out via `/notrack`)

## Architecture

Static **Vue 3 + Vite SSG** site deployed on **Vercel**. No application server or database.

| Layer | Stack |
|---|---|
| Frontend | Vue 3, Vite, vite-ssg, Pinia, Vue Router, Bootstrap 5 |
| Content | Markdown → `build-lattice.js` → JSON + prerendered HTML |
| Hosting | Vercel (root directory: `client`) |
| Media CDN | Azure Blob (`astrotiles`) |
| Analytics | `@vercel/analytics` |

## Quick start

```powershell
git clone https://github.com/thewebkid/alignos.git
cd alignos\client
npm install
npm run dev
```

Dev server: http://localhost:5555

```powershell
npm run build
npm run preview
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md). Summary:

1. Vercel project with **Root Directory** = `client`
2. Enable Web Analytics
3. Add domain `alignos.cosmiccreation.net`
4. Point Azure DNS `alignos` CNAME at Vercel

## Project structure

```
alignos/
├── client/                 # Vercel root
│   ├── vercel.json         # cleanUrls + /api rewrites
│   ├── scripts/            # build-lattice.js
│   ├── public/
│   │   ├── md/             # Codex markdown source
│   │   ├── codex-content/  # Per-codex content JSON
│   │   ├── data/           # Generated /api mirrors (gitignored)
│   │   └── llms.json
│   ├── src/
│   │   ├── generated/      # Lattice JSON for the app
│   │   └── ...
│   └── dist/               # SSG output
├── package.json
└── DEPLOYMENT.md
```

## Scripts (`client/`)

- `npm run dev` — lattice build + Vite dev server
- `npm run build` — lattice + vite-ssg production build
- `npm run preview` — preview `dist/`
- `npm run build:lattice` — regenerate lattice / API JSON only

## Public API

| URL | Description |
|---|---|
| `/api/health` | Health check |
| `/api/codex-lattice-meta` | Lightweight index (~128 KB) |
| `/api/codex-lattice` | Full corpus JSON |
| `/api/codex/:id` | Single codex |

## Content

Markdown lives in `client/public/md/`. `build-lattice.js` indexes it into `src/generated/` and `public/data/`.

## License

This project is open and you are welcome here.

## Links

- **Repository**: https://github.com/thewebkid/alignos
- **Live**: https://alignos.cosmiccreation.net

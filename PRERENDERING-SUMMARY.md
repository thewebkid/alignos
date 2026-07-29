# Pre-rendering (vite-ssg)

AlignOS uses **vite-ssg** so codex pages ship as full HTML for bots and search engines.

## Build

```powershell
cd client
npm run build   # build:lattice + vite-ssg build
```

Typical output under `client/dist/`:

- Home, search, FAQ, about
- One HTML file per codex (`/codex/{id}.html`, served as `/codex/{id}` via Vercel `cleanUrls`)
- Static JSON under `/data/*` (rewritten to `/api/*`)

## Hosting

Deployed as a static site on Vercel (`client` as root). See [DEPLOYMENT.md](./DEPLOYMENT.md).

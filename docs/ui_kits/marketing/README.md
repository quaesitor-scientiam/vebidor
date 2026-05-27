# Vebidor Marketing — UI Kit

A high-fidelity landing page for Vebidor, modeled on the structure and voice of the source `README.md`: short hero, code snippet as the hero visual, feature grid, browser support matrix, comparison table, and a "Phase history" timeline that doubles as social proof.

## Build

The page ships **pre-bundled** so it has no runtime CDN or in-browser Babel
dependency (important for offline use and for serving from GitHub Pages):

- `vendor/react.production.min.js`, `vendor/react-dom.production.min.js` —
  vendored React 18.3.1 UMD globals.
- `app.bundle.js` — the components + `app.jsx` compiled JSX → plain JS.

The `.jsx` files are the **editable source**. After changing them, rebuild:

```pwsh
pwsh -NoProfile -File build.ps1
```

(Requires Node/npx on PATH; esbuild is fetched on demand via `npx -y`.)

## What's in here

- `index.html` — live landing page demo
- `components/MarketingNav.jsx` — slimmer top nav (no search, links + GitHub stars + primary CTA)
- `components/Hero.jsx` — headline + lede + dual CTAs + hero code block
- `components/FeatureGrid.jsx` — 6-up feature grid with icons, mapped to README's "What's New" sections
- `components/BrowserMatrix.jsx` — the 4-browser support cards
- `components/PhasesTimeline.jsx` — Phase 1 → Phase 8 → 100% parity narrative arc
- `components/MarketingFooter.jsx` — links, license, version

## Out of scope

- No real signup form (CTAs link to `#`)
- No mobile breakpoint (would add at <768px)
- No animated number counters or scroll-spy effects — Vebidor's voice is "honest and technical", not "marketing flash"

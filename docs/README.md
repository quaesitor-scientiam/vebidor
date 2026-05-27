# Vebidor Design System

A design system + docs / marketing site for **Vebidor** — a V-language implementation of the W3C WebDriver + WebDriver-BiDi protocols with a Playwright-style ergonomic API.

> **Live:** [`https://quaesitor-scientiam.github.io/vebidor/`](https://quaesitor-scientiam.github.io/vebidor/) → redirects to `/ui_kits/marketing/index.html`
>
> **Docs deep links:** `/ui_kits/docs/index.html#quick-start` · `#modern-api` · `#bidi` · `#mobile` · `#comparison` · `#changelog`

> ⚠️ **Vebidor has no source visual brand.** The library shipped without a marketing site, app UI, icon set, brand colors, fonts, or logo. **Every visual decision here was inferred** from the README's tone, CLI output, code-block density, comparison-table style, and emoji-rich changelog. Treat this as a *proposed* identity. The **logo** is the only thing canonical — the maintainer supplied the PNG mark.

---

## What is Vebidor?

| | |
|---|---|
| **Type** | Developer library (V programming language, MIT licensed) |
| **Version** | 4.2.0 — 2026-05-26 |
| **Repo** | `github.com/quaesitor-scientiam/vebidor` |
| **Module** | `vebidor.webdriver` |
| **Transports** | W3C WebDriver-Classic (HTTP) + W3C WebDriver-BiDi (WebSocket) |
| **Drivers** | msedgedriver · chromedriver · geckodriver · safaridriver |
| **API style** | Playwright-style: `launch()`, lazy auto-waiting `Locator`s, `get_by_role` / `get_by_text` / `get_by_label`, `expect(loc).to_be_visible()` |
| **Claims** | 100% Selenium feature parity (since v3.0.0) · Playwright-style ergonomics + BiDi (since v4.0.0) · mobile-web emulation (since v4.2.0) · W3C-standards transport, not Chromium-only CDP |
| **Audience** | V-language developers writing browser tests, scrapers, automation scripts. Cross-browser, cross-platform |

### Live surfaces

| URL | What it is | Build mode |
|---|---|---|
| `/` | Redirect to marketing | static html |
| `/ui_kits/marketing/index.html` | Landing page (hero, features, browser matrix, phases timeline, footer) | **Production bundle** — vendored React + pre-compiled `app.bundle.js` |
| `/ui_kits/docs/index.html` | Docs site with deep-link hash routing | **Dev mode** — unpkg React + in-browser Babel transpilation of JSX |

---

## CONTENT FUNDAMENTALS

### Voice & tone

Vebidor's prose is **technical, achievement-oriented, and quietly proud**. It reads like a maintainer who has just shipped something they're excited about and wants you to know exactly what changed.

- **Achievement-driven framing.** Every changelog entry leads with what was *unlocked*, not what was *built*. "100% feature parity with Selenium achieved!" Version bumps are framed as **milestones** with named **Phases** (1 → 8 for Selenium catch-up, then 0 → 5 for Playwright ergonomics).
- **Comparison-first.** Almost every feature is described relative to Playwright or Selenium: tables of "Playwright → Vebidor" API maps, "Where vebidor stays ahead", "Genuinely not implemented (deferred)".
- **Honest about limits.** When something can't be done it gets a dedicated callout (`⚠️ Not implemented (protocol limit)` for real touch-event dispatch). This honesty is part of the voice.
- **Pronouns:** rarely uses "you" or "we". Mostly third-person imperative ("`launch()` locates the matching driver…"). Code is the subject.

### Casing & punctuation

- **Sentence case** for most headings.
- **lowercase product name** in body prose (`vebidor`); **Vebidor** at the start of sentences and in marketing headers.
- **Backticks** for API names. Never italics for code.
- **W3C / BiDi / CDP** stay all-caps. **`v` / `v.mod` / `v test`** stay lowercase.

### Emoji vocabulary — load-bearing, not decorative

| Emoji | Meaning |
|---|---|
| ✅ | Feature complete / implemented / passing |
| ⚠️ | Limitation, caveat, "not implemented because…" |
| 🐛 | Bug fix |
| ✨ | New feature in this release |
| 🎉 / 🎊 | Milestone |
| 🏆 | Major achievement |
| ⚡ | Performance / speed claim |
| 🚀 | Quick start / launch section |
| 📦 | Installation |
| 📖 / 📚 | Documentation |
| 🎯 | Feature coverage / goals |
| 🌐 | Multi-browser support |
| 🎭 | Playwright reference (Playwright's mascot is a theater mask) |
| 📱 | Mobile / device emulation |
| ✓ | Inline checkmark in CLI output (plain unicode, not emoji) |

**Rule:** lean into these in marketing/docs. They are *the* brand voice. Strip them only in production-app UI (which Vebidor doesn't have anyway).

### Vibe summary

If Vebidor were a person, it would be a backend engineer who built something they're proud of, writes their own docs, runs their own tests, and lists every limitation so you don't get burned at 2am. Confident, technical, generous with detail, slightly ASCII-banner-nostalgic.

---

## VISUAL FOUNDATIONS

All values tokenized in `colors_and_type.css`.

### Color

- **Primary — Vebidor Blue.** Deep, V-language-adjacent (`#3E63DD` core, `#1E3A8A` deep). Flat and confident — buttons, links, code-keyword tokens, wordmark. The cyan-blue in the canonical logo ties to this scale.
- **Surface — Slate neutrals.** 12-step scale, `#FFFFFF` → `#0B1220` (terminal-near-black). Docs are light-mode by default; **terminal/code surfaces are always dark**.
- **Semantic / status — mapped to emoji vocabulary:**
  - Success / ✅ → `#1E9F5E`
  - Warning / ⚠️ → `#D97706`
  - Bug-fix / 🐛 → `#DC2626`
  - New / ✨ → primary blue (re-use)
  - Milestone / 🎉🏆 → `#D4A017` warm gold — used sparingly
- **Browser-brand accents:** Edge `#0F6CBD` · Chrome `#1A73E8` · Firefox `#FF7139` · Safari `#0FB5EE`
- **Code-token palette** (Tokyo-Night-adjacent): keyword `#7AA2F7` · string `#9ECE6A` · number `#FF9E64` · function `#E0AF68` · type `#BB9AF7` · comment `#565F89` · plain `#C0CAF5`

### Type

- **Display & body:** **Geist** (Google Fonts CDN) ⚠️ flagged substitution
- **Mono:** **JetBrains Mono** with ligatures (reads well for V's `!`, `!=`, `->`)
- **Scale:** 12 / 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48 / 60 / 72 px
- **Tracking:** `-0.02em` on headings, default on body

### Spacing, radii, shadows

- **4px base unit.** Tokens `--space-1` (4) through `--space-16` (64)
- **Radii:** buttons/inputs/chips `6px`, code blocks `8px`, cards `10px`, feature cards `14px`, pills `9999px`
- **Shadows:** one resting (`--shadow-card`), one elevated (`--shadow-pop`). Sparing.

### Background, motion, interaction

- **No gradient backgrounds** except a subtle radial-glow behind the marketing hero. Flat surfaces + meaningful borders.
- **No illustrations, no patterns, no photography.** The brand's imagery is *code blocks* and *comparison tables*.
- **Animations are minimal** — `120ms cubic-bezier(0.4, 0, 0.2, 1)` hover. No bounces, no spring physics, no page-load reveals.
- **Hover:** ~6% darken on primary; `--surface-2` fill on secondary/ghost
- **Focus:** 2px outline in lighter blue, offset 2px. Always visible
- **Borders carry most of the visual structure.** `1px solid var(--border-1)` is the workhorse

---

## ICONOGRAPHY

- **Logo:** `assets/logo-vebidor.png` — canonical 256×256 mark (stylized V with inset browser window + reticle/crosshair, cyan-blue on near-black). Use square (small `border-radius` in UI chrome) or paired with the `vebidor` wordmark in Geist 800 for a horizontal lockup.
- **UI chrome icons:** **Lucide** via CDN ⚠️ substitution
- **Browser glyphs:** monochrome SVGs for Edge / Chrome / Firefox / Safari, colorized via `currentColor`. Trademarked logos used for identification only.
- **Status icons:** native emoji rendered with the system color-emoji fallback stack

### `assets/`

- `logo-vebidor.png` — **canonical 256×256 PNG**
- `logo-vebidor.svg`, `logo-vebidor-mark.svg` — legacy placeholders (kept for reference)
- `browser-edge.svg`, `browser-chrome.svg`, `browser-firefox.svg`, `browser-safari.svg`

---

## Index — what lives in this folder

```
docs/                              ← GitHub Pages serves from here
├── README.md                      ← you are here
├── SKILL.md                       ← Agent-Skills entry point for Claude
├── colors_and_type.css            ← all design tokens + base type styles
├── index.html                     ← redirect → ui_kits/marketing/index.html
├── fonts/
│   └── README.md                  ← font sourcing notes
├── assets/                        ← canonical PNG logo + legacy SVGs + browser glyphs
├── preview/                       ← 19 design-system specimen cards
│   ├── colors-primary.html
│   ├── colors-neutrals.html
│   ├── colors-semantic.html
│   ├── colors-browser-accents.html
│   ├── colors-code-tokens.html
│   ├── type-display.html · type-body.html · type-mono.html
│   ├── spacing-scale.html · radii.html · shadows.html
│   ├── buttons.html · inputs.html · chips-status.html
│   ├── code-block.html · comparison-table.html
│   ├── emoji-vocabulary.html · browser-matrix.html
│   └── logo-placeholders.html
└── ui_kits/
    ├── docs/                      ← Docs-site UI kit · dev mode (Babel in-browser)
    │   ├── README.md
    │   ├── index.html             ← loads unpkg React + Babel + JSX components
    │   ├── app.jsx                ← hash-routed page navigation
    │   └── components/
    │       ├── TopNav.jsx · Sidebar.jsx · TocPanel.jsx
    │       ├── DocsPage.jsx       ← all 6 page components + Changelog data
    │       ├── CodeBlock.jsx · Callout.jsx
    │       ├── ComparisonTable.jsx · ApiSignature.jsx
    └── marketing/                 ← Landing-page UI kit · production bundle
        ├── README.md
        ├── index.html             ← loads vendor React + app.bundle.js
        ├── app.bundle.js          ← compiled output of app.jsx + components
        ├── app.jsx                ← editable source (compile to update bundle)
        ├── vendor/
        │   ├── react.production.min.js
        │   └── react-dom.production.min.js
        └── components/
            ├── MarketingNav.jsx · Hero.jsx · FeatureGrid.jsx
            ├── BrowserMatrix.jsx · PhasesTimeline.jsx · MarketingFooter.jsx
```

### Build asymmetry

The two UI kits use **different build strategies** — important to know when editing:

- **Marketing (`ui_kits/marketing/`)** is a **production bundle.** Vendored `react.production.min.js` + `react-dom.production.min.js` (no CDN, no Babel-standalone in browser) + a pre-compiled `app.bundle.js`. The `.jsx` files in `components/` and `app.jsx` are the editable source — when you change them, you must **rebuild `app.bundle.js`**. The marketing `index.html` references a `build.ps1` PowerShell script in its source comment, but the build script itself isn't checked into the repo.
- **Docs (`ui_kits/docs/`)** still loads React + ReactDOM + Babel from unpkg and transpiles JSX in the browser at page-load. Editable in place — change a `.jsx`, refresh the page, see it. ~200 KB of CDN deps + a brief first-paint delay. Fine for an internal docs site, less ideal for a heavily-trafficked public page.

### Docs pages currently shipped

| Hash | Page | Status |
|---|---|---|
| `#quick-start` | Quick start | live |
| `#modern-api` | Modern API (Locators, actions, assertions) | live |
| `#bidi` | WebDriver-BiDi (network mocking, contexts) | live |
| `#mobile` | Mobile (preview) — design sketch for a no-Appium backend | live, ⚠️ proposal only |
| `#comparison` | Comparison — vs Playwright + Phase history | live |
| `#changelog` | Changelog — 15 releases on a timeline | live |

Sidebar entries `install`, `config`, `locators`, `selectors`, `assertions` are stubs that currently fall back to Quick Start — flagged below.

---

## Caveats

1. **Marketing kit needs a build step.** Editing a `.jsx` won't update the live page until `app.bundle.js` is regenerated. The `build.ps1` referenced in `index.html` isn't in the repo — either add it, or document whatever toolchain (esbuild / Bun / Babel CLI) was actually used to produce the current bundle.
2. **Docs kit uses in-browser Babel.** Adds ~200 KB of CDN deps and a first-paint delay. Acceptable for internal docs; consider building it the same way as marketing if traffic grows.
3. **Sidebar stubs that don't exist yet.** `Installation`, `Configuration`, `Locators`, `Selector engines`, `Assertions` silently fall back to Quick Start. Build them out, point them at GitHub source files, or remove them.
4. **Font substitution.** Geist + JetBrains Mono loaded from Google Fonts CDN. No `.ttf` files in `fonts/`.
5. **Browser logos.** Monochrome glyphs used for identification under nominative fair-use — not official trademark assets.
6. **No slide template, no mobile-app UI in source** → no `slides/` or device-frame artifacts.
7. **Cache.** GitHub Pages serves files with default cache headers. After a deploy, end-users may see stale content until they hard-refresh. Consider cache-busting JS/CSS imports with a `?v=4.2.0` query string per release.

---

## Recently shipped (since the initial design system)

- **Canonical PNG logo** in nav, footer, and the design-system preview card
- **Mobile (preview) docs page** — architecture diagram + comparison vs. Espresso / EarlGrey / Detox / Maestro / Appium, MVP plan for a no-Appium backend
- **Changelog docs page** — 15 releases on a timeline with sectioned ✨ / 🐛 / ⚠️ / 🏆 groups, link out to the full `CHANGELOG.md` on GitHub
- **Hash routing** in the docs site — pages now have shareable URLs (`#mobile`, `#changelog`, etc.)
- **Link audit** — 22 dead `href="#"` links replaced with real targets (GitHub URLs, docs deep-links, smooth-scroll handlers)
- **Changelog references** updated — top nav + marketing footer now link to the in-site Changelog page instead of the GitHub raw file
- **Marketing kit production bundle** — vendored React + compiled `app.bundle.js` replacing in-browser Babel

## Asks for the maintainer

- **Build script** — what produced `app.bundle.js`? Check the build tool into the repo so future edits stay reproducible.
- **Apply same build to docs?** Or leave docs in dev mode since it's iterated more often?
- **Sidebar stubs** — build out as real pages, or trim?
- **Primary blue** (`#3E63DD` / `#1E3A8A`) — right direction, or shift?
- **Geist + JetBrains Mono** — keep, or swap?
- **Custom domain** (e.g. `vebidor.dev`)? Easy add — needs a `CNAME` file + DNS records.

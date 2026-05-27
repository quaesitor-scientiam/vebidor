# Vebidor Design System

A design system + docs/marketing site for **Vebidor** — a V-language implementation of the W3C WebDriver + WebDriver-BiDi protocols with a Playwright-style ergonomic API.

> Live at: **https://quaesitor-scientiam.github.io/vebidor/**
> (root redirects to `/ui_kits/marketing/index.html`)

> ⚠️ **Vebidor has no source visual brand.** It is a developer library distributed via `v.mod`/GitHub — no marketing site, app UI, icon set, brand colors, fonts, or logo existed in the source repo. Every visual decision here was **inferred** from the README's tone, CLI output, code-block density, comparison-table style, and emoji-rich changelog. Treat this as a *proposed* identity; ask for validation before treating any color/typeface as canonical. The **logo** is now a real PNG mark provided by the maintainer.

---

## What is Vebidor?

- **Type:** Developer library (V programming language, MIT licensed)
- **Version:** 4.2.0 (released 2026-05-26)
- **Repo:** `github.com/quaesitor-scientiam/vebidor`
- **Module:** `vebidor.webdriver`
- **What it does:** Browser automation. Talks W3C WebDriver-Classic (HTTP) **and** W3C WebDriver-BiDi (WebSocket) to msedgedriver / chromedriver / geckodriver / safaridriver. Wraps the raw W3C protocol in a Playwright-style API: `launch()`, lazy auto-waiting `Locator`s, semantic selector engines (`get_by_role`, `get_by_text`, …), and retrying web-first assertions (`expect(loc).to_be_visible()`).
- **Positioning:** Claims **100% Selenium feature parity** (since v3.0.0) + **Playwright-style ergonomics** (since v4.0.0) + WebDriver-BiDi (network interception/mocking, isolated contexts, mobile-web emulation since v4.2.0) — all on a **W3C-standards** transport, not Chromium-only CDP.
- **Audience:** V-language developers writing browser tests, scrapers, automation scripts. Cross-browser (Edge / Chrome / Firefox / Safari), cross-platform.

### Live surfaces

| URL | What it is |
|---|---|
| `/` → `/ui_kits/marketing/index.html` | Marketing landing page (hero, features, browser matrix, phases timeline, footer) |
| `/ui_kits/docs/index.html` | Docs site with deep-link hash routing (`#quick-start`, `#modern-api`, `#bidi`, `#mobile`, `#comparison`, `#changelog`) |

---

## Sources

Material consulted to build this design system:

- **Codebase:** `quaesitor-scientiam/vebidor` (read directly from GitHub once connected)
  - `README.md` — primary tonal source
  - `CHANGELOG.md` (~50 KB, ~1300 lines) — voice + milestone framing
  - `COMPARISON_WITH_PLAYWRIGHT.md`, `COMPARISON_WITH_SELENIUM.md` — table style
  - `TESTING.md`, `TEST_ENVIRONMENT_SETUP.md` — instructional voice
  - `examples/*.v`, `webdriver/*.v` — V source style, CLI output style
  - `v.mod` — package metadata

No Figma file or pre-existing design system was provided.

---

## CONTENT FUNDAMENTALS

### Voice & tone

Vebidor's prose is **technical, achievement-oriented, and quietly proud**. It reads like a maintainer who has just shipped something they're excited about and wants you to know exactly what changed.

- **Achievement-driven framing.** Every changelog entry leads with what was *unlocked*, not what was *built*. "100% feature parity with Selenium achieved!" "Playwright-parity roadmap (Phases 0–5) is implemented." Version bumps are framed as **milestones** with named **Phases** (1 through 8) — a narrative arc rather than a flat list.
- **Comparison-first.** Almost every feature is described relative to Playwright or Selenium: tables of "Playwright → Vebidor" API maps, "Where vebidor stays ahead", "Genuinely not implemented (deferred)". The brand defines itself by what it matches and what it deliberately *doesn't* match.
- **Honest about limits.** When something can't be done it gets a dedicated callout (`⚠️ Not implemented (protocol limit)` for real touch-event dispatch). This honesty is part of the voice.
- **Pronouns:** rarely uses "you" or "we". Mostly third-person imperative ("`launch()` locates the matching driver…"). Code is the subject.

### Casing & punctuation

- **Sentence case** for most headings.
- **lowercase product name:** the project styles itself `vebidor` in body prose (lowercase) but `Vebidor` at the start of sentences and in marketing headers. Be flexible.
- **Backticks everywhere** for API names. Never italics for code.
- **W3C / BiDi / CDP** stay all-caps. **`v` / `v.mod` / `v test`** stay lowercase.

### Emoji vocabulary — load-bearing, not decorative

The README and changelog use emoji as **section markers and status flags**. The vocabulary is small and deliberate:

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
| ✓ | Inline checkmark in CLI output (plain unicode) |

**Rule:** in marketing/docs designs, lean into these. They are *the* brand voice. Strip them only in production-app UI (which Vebidor doesn't have anyway).

### Vibe summary

If Vebidor were a person, it would be a backend engineer who built something they're proud of, writes their own docs, runs their own tests, and lists every limitation so you don't get burned at 2am. Confident, technical, generous with detail, slightly ASCII-banner-nostalgic.

---

## VISUAL FOUNDATIONS

All values are tokenized in `colors_and_type.css`.

### Color

- **Primary — Vebidor Blue.** A V-language-adjacent deep blue (`#3E63DD` core, `#1E3A8A` deep). Flat and confident, used on buttons, links, code-keyword tokens, and the wordmark. The cyan-blue in the canonical logo ties to this scale.
- **Surface — Slate neutrals.** A 12-step slate scale from white (`#FFFFFF`) through to terminal-near-black (`#0B1220`). Docs are light-mode by default; the **terminal/code surface is always dark**.
- **Semantic / status — mapped to emoji vocabulary.**
  - Success / ✅ → `#1E9F5E`
  - Warning / ⚠️ → `#D97706`
  - Bug-fix / 🐛 → `#DC2626`
  - New feature / ✨ → primary blue (re-use)
  - Milestone / 🎉🏆 → `#D4A017` warm gold — used sparingly
- **Browser-brand accents:** Edge `#0F6CBD`, Chrome `#1A73E8`, Firefox `#FF7139`, Safari `#0FB5EE`
- **Code-token palette** (Tokyo-Night-adjacent): keyword `#7AA2F7` · string `#9ECE6A` · number `#FF9E64` · function `#E0AF68` · type `#BB9AF7` · comment `#565F89` · plain `#C0CAF5`

### Type

- **Display & body:** **Geist** (Google Fonts CDN). ⚠️ flagged substitution.
- **Mono:** **JetBrains Mono** with ligatures. Reads well for V's `!`, `!=`, `->`.
- **Scale:** 12 / 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48 / 60 / 72px. `-0.02em` tracking on headings.

### Spacing, radii, shadows

- **4px base unit.** Tokens `--space-1` (4) through `--space-16` (64).
- **Radii:** buttons/inputs/chips `6px`, code blocks `8px`, cards `10px`, feature cards `14px`, pills `9999px`.
- **Shadows:** one resting state (`--shadow-card`), one elevated (`--shadow-pop`). Sparing.

### Background, motion, interaction

- **No gradient backgrounds** except one optional subtle radial-glow behind the marketing hero. Flat surfaces + meaningful borders.
- **No illustrations, no patterns, no photography.** The brand's imagery is *code blocks* and *comparison tables*.
- **Animations are minimal** — `120ms cubic-bezier(0.4, 0, 0.2, 1)` hover transitions. No bounces, no spring physics, no page-load reveals.
- **Hover:** ~6% darken on primary; `--surface-2` fill on secondary/ghost.
- **Focus:** 2px outline in lighter blue, offset 2px. Always visible.
- **Borders carry most of the visual structure.** `1px solid var(--border-1)` is the workhorse.

### Imagery vibe

- **Imagery is code.** Dark code blocks are the brand's "photography".

---

## ICONOGRAPHY

- **Logo / wordmark:** `assets/logo-vebidor.png` — the canonical 256×256 mark provided by the maintainer (stylized V with inset browser window + reticle/crosshair, cyan-blue on near-black). Use it as a square mark (small `border-radius` in UI chrome) or paired with the "vebidor" wordmark in Geist 800 for a horizontal lockup.
- **UI chrome icons:** **Lucide** via CDN. ⚠️ substitution.
- **Browser glyphs:** monochrome SVGs for Edge / Chrome / Firefox / Safari, colorized via `currentColor`. Trademarked logos used for identification only.
- **Status icons:** native emoji rendered with the system color-emoji fallback stack.

### Files in `assets/`

- `logo-vebidor.png` — **canonical logo** (256×256 PNG)
- `logo-vebidor.svg`, `logo-vebidor-mark.svg` — legacy placeholders, kept for reference
- `browser-edge.svg`, `browser-chrome.svg`, `browser-firefox.svg`, `browser-safari.svg`

---

## Index — what lives in this folder

```
docs/                          ← GitHub Pages serves from here
├── index.html                 ← redirect → ui_kits/marketing/index.html
├── README.md                  ← you are here
├── SKILL.md                   ← Agent-Skills-compatible entry point for Claude
├── colors_and_type.css        ← all design tokens + base type styles
├── fonts/
│   └── README.md              ← font sourcing notes
├── assets/                    ← canonical PNG logo + legacy SVGs + browser glyphs
├── preview/                   ← 19 design-system specimen cards
│   ├── colors-primary.html
│   ├── colors-neutrals.html
│   ├── colors-semantic.html
│   ├── colors-browser-accents.html
│   ├── colors-code-tokens.html
│   ├── type-display.html / type-body.html / type-mono.html
│   ├── spacing-scale.html / radii.html / shadows.html
│   ├── buttons.html / inputs.html / chips-status.html
│   ├── code-block.html / comparison-table.html
│   ├── emoji-vocabulary.html / browser-matrix.html
│   └── logo-placeholders.html
└── ui_kits/
    ├── docs/                  ← Docs-site UI kit (live)
    │   ├── README.md
    │   ├── index.html
    │   ├── app.jsx            ← hash-routed page navigation
    │   └── components/
    │       ├── TopNav.jsx
    │       ├── Sidebar.jsx
    │       ├── TocPanel.jsx
    │       ├── DocsPage.jsx   ← all 6 page components + Changelog data
    │       ├── CodeBlock.jsx
    │       ├── Callout.jsx
    │       ├── ComparisonTable.jsx
    │       └── ApiSignature.jsx
    └── marketing/             ← Landing-page UI kit (live)
        ├── README.md
        ├── index.html
        ├── app.jsx
        └── components/
            ├── MarketingNav.jsx
            ├── Hero.jsx
            ├── FeatureGrid.jsx
            ├── BrowserMatrix.jsx
            ├── PhasesTimeline.jsx
            └── MarketingFooter.jsx
```

### Docs pages currently shipped

| Hash | Page | Status |
|---|---|---|
| `#quick-start` | Quick start | live |
| `#modern-api` | Modern API (Locators, actions, assertions) | live |
| `#bidi` | WebDriver-BiDi (network mocking, contexts) | live |
| `#mobile` | Mobile (preview) — design sketch for a no-Appium backend | live, ⚠️ proposal only |
| `#comparison` | Comparison — vs Playwright + Phase history | live |
| `#changelog` | Changelog — 15 releases on a timeline, deep-link to GitHub | live |

Sidebar entries `install`, `config`, `locators`, `selectors`, `assertions` are stubs that currently fall back to Quick Start — flagged in caveats below.

---

## Caveats (read me)

1. **Sidebar stubs that don't exist yet.** `Installation`, `Configuration`, `Locators`, `Selector engines`, `Assertions` in the sidebar all silently fall back to Quick Start. Either build them out, point them at GitHub source files, or remove them.
2. **Font substitution.** Geist + JetBrains Mono loaded from Google Fonts CDN. No `.ttf` files in `fonts/`. If you want self-hosted fonts, drop them in and rewrite the `@import` in `colors_and_type.css` as `@font-face`.
3. **Browser logos.** Used for identification under nominative fair-use; bundled as monochrome glyphs, not official trademark assets.
4. **No slide template** in source → no `slides/` directory generated.
5. **No mobile-app UI** in source — this is a CLI/library — so no iOS/Android frames in the UI kits.
6. **Cache:** GitHub Pages serves JSX with default cache headers. After a deploy, end-users may see stale content until they hard-refresh. Consider cache-busting JSX imports with a `?v=4.2.0` query string on each release.
7. **JSX compiled in-browser via Babel-standalone.** Fine for a docs/marketing site, but adds ~200 KB of CDN deps and a brief first-paint delay. Switch to a build step if performance matters.

## Recently shipped

- **Canonical PNG logo** — replaced SVG placeholders in nav, footer, and the design-system preview card.
- **Mobile (preview) docs page** — architecture diagram + comparison vs. Espresso / EarlGrey / Detox / Maestro / Appium, MVP plan for a no-Appium backend.
- **Changelog docs page** — 15 releases on a timeline with sectioned ✨ / 🐛 / ⚠️ / 🏆 groups, link out to the full `CHANGELOG.md` on GitHub.
- **Hash routing** in the docs site — pages now have shareable URLs (`#mobile`, `#changelog`, etc.).
- **Link audit** — 22 dead `href="#"` links replaced with real targets (GitHub URLs, docs deep-links, smooth-scroll handlers).

## Asks for the maintainer

- Is the primary blue (`#3E63DD` core, `#1E3A8A` deep) right, or should it lean another way?
- Are Geist + JetBrains Mono the right pairing, or do you have a brand typeface preference?
- Should the sidebar stubs (Installation / Configuration / Locators / Selector engines / Assertions) be built out as real pages, or trimmed?
- Want a custom domain (e.g. `vebidor.dev`)? Easy add — needs a `CNAME` file + DNS records.

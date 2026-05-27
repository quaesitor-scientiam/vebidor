# Vebidor Design System

A design system for **Vebidor** — a V-language implementation of the W3C WebDriver + WebDriver-BiDi protocols with a Playwright-style ergonomic API.

> ⚠️ **Source has no existing visual brand.** Vebidor is a developer library distributed via `v.mod`/GitHub. There is no marketing site, app UI, icon set, brand colors, fonts, or logo in the source repo. **Every visual decision below is inferred** from the README's tone, CLI output, code-block density, comparison-table style, and emoji-rich changelog. Treat this as a *proposed* visual identity for "if Vebidor had a docs site and landing page" — and ask the user to validate or steer before treating any specific color/typeface/logo as canonical.

---

## What is Vebidor?

- **Type:** Developer library (V programming language, MIT licensed)
- **Version:** 4.2.0 (released 2026-05-26)
- **Repo:** `github.com/quaesitor-scientiam/vebidor`
- **Module:** `vebidor.webdriver`
- **What it does:** Browser automation. Talks W3C WebDriver-Classic (HTTP) **and** W3C WebDriver-BiDi (WebSocket) to msedgedriver / chromedriver / geckodriver / safaridriver. Wraps the raw W3C protocol in a Playwright-style API: `launch()`, lazy auto-waiting `Locator`s, semantic selector engines (`get_by_role`, `get_by_text`, …), and retrying web-first assertions (`expect(loc).to_be_visible()`).
- **Positioning:** Claims **100% Selenium feature parity** + **Playwright-style ergonomics** + WebDriver-BiDi (network interception/mocking, isolated contexts, mobile emulation) — all on a **W3C-standards** transport, not Chromium-only CDP.
- **Audience:** V-language developers writing browser tests, scrapers, automation scripts. Cross-browser (Edge / Chrome / Firefox / Safari), cross-platform.

### Products / surfaces represented

Vebidor has **no visual product**. It is a library. The natural design surfaces are:

1. **Docs site** — API reference, getting-started, comparison pages (vs Selenium, vs Playwright). Heavy on code blocks, tables, and "phase" callouts.
2. **Marketing / landing page** — hero ("Playwright-style API for V"), feature grid, code snippet, browser support matrix.
3. **Terminal / CLI output** — example programs print ASCII rules (`========`), `✓` checkmarks, `✅` / `🎉` / `🐛` emoji status, phase headings.

These are the three surfaces this design system targets.

---

## Sources

The only material consulted was the read-only attached codebase:

- **Codebase:** `vebidor/` (mounted via File System Access API as `vebidor/...`)
  - `README.md` — 798 lines, primary tonal source
  - `CHANGELOG.md` — 1363 lines, voice + version-milestone framing
  - `COMPARISON_WITH_PLAYWRIGHT.md`, `COMPARISON_WITH_SELENIUM.md` — feature-mapping table style
  - `TESTING.md`, `TEST_ENVIRONMENT_SETUP.md` — instructional docs voice
  - `examples/*.v`, `webdriver/*.v` — V source code style, CLI output style
  - `v.mod` — package metadata

No Figma file, no design system file, no logo asset, no marketing site, no app screens were provided. **If the user has any of those, ask them to attach.**

---

## CONTENT FUNDAMENTALS

### Voice & tone

Vebidor's prose is **technical, achievement-oriented, and quietly proud**. It reads like a maintainer who has just shipped something they're excited about and wants you to know exactly what changed.

- **Achievement-driven framing.** Every changelog entry leads with what was *unlocked*, not what was *built*. "100% feature parity with Selenium achieved!" "Playwright-parity roadmap (Phases 0–5) is implemented." Version bumps are framed as **milestones** with named **Phases** (1 through 8) — a narrative arc rather than a flat list.
- **Comparison-first.** Almost every feature is described relative to Playwright or Selenium: tables of "Playwright → Vebidor" API maps, "Where vebidor stays ahead", "Genuinely not implemented (deferred)". The brand defines itself by what it matches and what it deliberately *doesn't* match.
- **Honest about limits.** When something can't be done it gets a dedicated callout (`⚠️ Not implemented (protocol limit)` for real touch-event dispatch). This honesty is part of the voice.
- **Pronouns:** rarely uses "you" or "we". Mostly third-person imperative ("`launch()` locates the matching driver…"). Code is the subject.

### Casing & punctuation

- **Sentence case** for most headings: "Quick Start", "What's New in v4.2.0".
- **lowercase product name:** the project styles itself `vebidor` in body prose (lowercase) but `Vebidor` at the start of sentences and in marketing headers. Be flexible.
- **Backticks everywhere** for API names: `launch()`, `get_by_role`, `expect(loc).to_be_visible()`. Never italics for code.
- **W3C / BiDi / CDP** stay all-caps. **`v` / `v.mod` / `v test`** stay lowercase.
- Emoji headers are common (see below).

### Emoji usage — yes, heavily, with a system

The README and changelog use emoji as **section markers and status flags**, not decoration. This is intentional and brand-consistent. The vocabulary is small and load-bearing:

| Emoji | Meaning in Vebidor docs |
|---|---|
| ✅ | Feature complete / implemented / passing |
| ⚠️ | Limitation, caveat, "not implemented because…" |
| 🐛 | Bug fix |
| ✨ | New feature in this release |
| 🎉 / 🎊 | Milestone (e.g. "100% parity achieved") |
| 🏆 | Major achievement |
| ⚡ | Performance / speed claim |
| 🚀 | Quick start / launch section |
| 📦 | Installation |
| 📖 / 📚 | Documentation |
| 🎯 | Feature coverage / goals |
| 🌐 | Multi-browser support |
| 🤝 | Contributing |
| 📄 | License |
| 🎭 | Playwright reference (Playwright's mascot is a theater mask) |
| 📱 | Mobile / device emulation |
| ✓ | Inline checkmark in CLI output (plain unicode, not emoji ✅) |

**Rule:** in marketing/docs designs, lean into these. They are *the* brand voice. Strip them only in production-app UI (which Vebidor doesn't have anyway).

### Copy examples (lifted verbatim from source)

- Tagline / one-liner: *"A V language implementation of the W3C WebDriver protocol for browser automation."*
- Positioning line: *"Playwright-style API + WebDriver-BiDi + mobile emulation | 100% Selenium parity | Production Ready"*
- Pride line: *"🏆 100% FEATURE PARITY ACHIEVED! 🏆"*
- Honest-limits line: *"Real touch-*event* dispatch needs a CDP/`mobileEmulation` capability BiDi doesn't expose…"*
- Feature-grid voice: *"Lazy auto-waiting `Locator`s, selector engines, web-first assertions, one-call `launch()`, and network interception/mocking."*
- CLI banner style:
  ```
  ========================================
  v-webdriver v2.0.0 - Feature Showcase
  85% Selenium Feature Parity
  ========================================
  ```

### Vibe summary

If Vebidor were a person, it would be a backend engineer who built something they're proud of, writes their own docs, runs their own tests, and lists every limitation so you don't get burned at 2am. Confident, technical, generous with detail, slightly ASCII-banner-nostalgic.

---

## VISUAL FOUNDATIONS

Because there is no existing brand to follow, this section proposes a coherent foundation that matches the **tone** above. All values are tokenized in `colors_and_type.css`.

### Color

- **Primary — Vebidor Blue.** A V-language-adjacent deep blue (`#3E63DD` core, `#1E3A8A` deep). Not the bluish-purple gradient cliché; flat, confident, used on buttons, links, code-keyword tokens, and the wordmark.
- **Surface — Slate neutrals.** A 10-step slate scale from near-white (`#F8FAFC`) to near-black (`#0B1220`). Docs are light-mode by default; the **terminal/code surface is always dark** regardless of theme (this matches how every code example in the README is dark-themed in your mental model).
- **Semantic / status — mapped to emoji vocabulary.**
  - Success / "feature complete" / ✅ → `#1E9F5E` (a confident green, not pastel)
  - Warning / "limitation" / ⚠️ → `#D97706` (amber, not yellow)
  - Bug-fix / "regression" / 🐛 → `#DC2626` (red)
  - "New feature" / ✨ → primary blue (re-use)
  - Milestone / 🎉🏆 → a warm gold `#D4A017` — used sparingly, never as a background
- **Browser-brand accents** (functional, not decorative — used in browser-support matrices and device-emulation chips):
  - Edge `#0F6CBD`, Chrome `#1A73E8`, Firefox `#FF7139`, Safari `#0FB5EE`
- **Code-token palette** (for syntax highlighting on dark surface):
  - keyword `#7AA2F7` · string `#9ECE6A` · number `#FF9E64` · function `#E0AF68` · comment `#565F89` · plain `#C0CAF5` (a Tokyo-Night-adjacent scheme — chosen because Vebidor itself shows almost no UI, but every README example is a V code block and the syntax matters more than the chrome).

### Type

- **Display / headings:** **Geist Sans** (Vercel's open-source geometric humanist sans). Picked because Inter / Roboto are over-used per project guidelines, Geist has a quietly modern dev-tool register, and it's Google-Fonts-available. ⚠️ flagged: the source has no font preference — confirm with user.
- **Body:** Geist Sans, same family, 16px base, 1.6 line-height.
- **Mono:** **JetBrains Mono** for all code (inline and block). Ligatures **on** (Vebidor uses `!`, `!=`, `->` heavily and ligatures read well there).
- **Scale:** 12 / 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48 / 60 / 72px. Tight-ish letterspacing on headings (`-0.02em`), default on body.

### Spacing & layout

- **4px base unit.** Tokens: `--space-1` (4) … `--space-16` (64). Generous vertical rhythm — Vebidor's README is a long-form doc and the design should reward scanning.
- **Container widths:** docs body `720px`, docs-with-sidebar `1200px`, marketing hero up to `1280px`. Wide tables can go full bleed.
- **Layout grid:** docs use a fixed left sidebar (260px) + content (~720px) + on-page TOC (200px). Marketing is a centered single column with full-bleed accent bands.

### Backgrounds

- **No gradient backgrounds** anywhere except a single optional radial-glow behind the marketing hero (very subtle, primary-blue at ~6% opacity). The dev-tool aesthetic is **flat surfaces + meaningful borders**.
- **No hand-drawn illustrations, no patterns, no textures, no photography.** The brand's imagery is *code blocks* and *comparison tables*.
- **Full-bleed dark code blocks** are the most visually distinctive element. Treat them as imagery.

### Animation & interaction

- **Animations are minimal and functional.** Hover transitions on links/buttons at `120ms cubic-bezier(0.4, 0, 0.2, 1)`. No bounces. No spring physics. No page-load reveals.
- **Hover state:** primary buttons darken by ~6% on the primary color; secondary/ghost buttons get a `--surface-2` background fill; links underline (or thicken if already underlined).
- **Press state:** `scale(0.98)` + color darken by ~10%. 80ms.
- **Focus state:** 2px outline in `--accent-focus` (a lighter primary tint) offset 2px. Always visible — this is a dev tool, keyboard users matter.
- **Disabled state:** 0.4 opacity, `cursor: not-allowed`. No layout shift.

### Borders & shadows

- **Borders carry most of the visual structure.** `1px solid var(--border-1)` is the workhorse. Use color, not weight, to differentiate.
- **Corner radii:** small UI `6px` (buttons, inputs, chips), cards `10px`, code blocks `8px`, full-bleed dark sections `0`. Pills (`9999px`) only for status chips.
- **Shadows are sparing.** A single elevation step (`--shadow-card`: `0 1px 3px rgba(11,18,32,0.06), 0 1px 2px rgba(11,18,32,0.04)`) for floating menus and hover-on-cards. No drop-shadow stacks, no neon glows, no inner shadows.
- **No "left-border-accent + rounded-corner-card" pattern.** That is on the avoid-list.

### Transparency & blur

- Used only for **overlays and the on-page TOC**: `backdrop-filter: blur(8px)` + `rgba(255,255,255,0.75)` background on sticky doc headers. Nothing decorative.

### Imagery vibe

- **Imagery is code.** Treat dark code blocks as the brand's "photography". When the marketing site needs a hero visual, it's a code block — not an illustration.
- For the rare case where a real image is needed (e.g. an OG image / social card), use a flat dark-blue field with the wordmark and a single line of code in JetBrains Mono. No gradients, no 3D, no shapes.

### Card anatomy

- White (or `--surface-1`) background
- `1px solid var(--border-1)` border
- `10px` radius
- `20–24px` padding
- Title row (icon optional, label, optional status pill)
- Body
- Optional code block (dark) inline
- No drop shadow at rest; subtle shadow on hover

### Fixed elements

- **Docs site:** sticky top nav (56px), sticky left sidebar, sticky right on-page TOC. All have `backdrop-filter: blur(8px)` + translucent surface.
- **Marketing:** sticky top nav only.

### Use of color across the surface

- Docs are predominantly **light surface, dark text, blue accents, dark code**. Color is rationed — it's mostly black-on-white with one blue link color and the semantic-status chips.
- Marketing has slightly more color — a primary-blue hero CTA, a "100% parity" milestone badge in gold, browser-support chips in their brand colors.

---

## ICONOGRAPHY

Vebidor has **no first-party icon system**. The README uses emoji (see Content Fundamentals) and CLI plain-unicode `✓`. There is no SVG icon set, no icon font, no PNG sprites in the source repo.

### Decisions

- **For UI chrome icons** (search, copy-to-clipboard, external link, menu, close, theme toggle, chevrons): **Lucide** via CDN. Reasoning: Lucide is the closest match in stroke weight (1.5px), corner style (rounded), and dev-tool register to what this brand wants. ⚠️ flagged: this is a substitution; no source preference exists.
- **For browser logos** (Edge / Chrome / Firefox / Safari, used in the support matrix and device-emulation chips): linked from Simple Icons CDN as monochrome SVGs, colorized via `currentColor` to the brand-color tokens above. ⚠️ flagged: trademarked logos used for identification only.
- **For status icons** (✅ ⚠️ 🐛 ✨ 🎉 etc.): **native emoji**. This is genuinely part of Vebidor's voice and should not be replaced with SVGs. Render with `font-family: 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'` fallback.
- **For the Vebidor wordmark / logo:** there is no existing logo. `assets/logo-vebidor.svg` is a **placeholder wordmark** I created — a simple `vebidor` set in Geist Sans 700 with a small "→" glyph standing in for the WebDriver "navigate" metaphor. ⚠️ flagged — please replace with the real logo or tell me to iterate.

### Files in `assets/`

- `logo-vebidor.svg` — placeholder wordmark (flagged)
- `logo-vebidor-mark.svg` — placeholder monogram "V→" (flagged)
- `browser-edge.svg`, `browser-chrome.svg`, `browser-firefox.svg`, `browser-safari.svg` — monochrome browser glyphs (placeholder; recommend Simple Icons in production)

---

## Index — what lives in this design system

```
/
├── README.md                  ← you are here
├── SKILL.md                   ← Agent-Skills-compatible entry point
├── colors_and_type.css        ← all design tokens + base type styles
├── fonts/                     ← (Geist Sans + JetBrains Mono via Google Fonts; flagged)
│   └── README.md              ← font sourcing notes + substitution flags
├── assets/                    ← logos + browser glyphs (placeholders, flagged)
├── preview/                   ← design-system cards rendered into the DS tab
│   ├── colors-primary.html
│   ├── colors-neutrals.html
│   ├── colors-semantic.html
│   ├── colors-browser-accents.html
│   ├── colors-code-tokens.html
│   ├── type-display.html
│   ├── type-body.html
│   ├── type-mono.html
│   ├── spacing-scale.html
│   ├── radii.html
│   ├── shadows.html
│   ├── buttons.html
│   ├── inputs.html
│   ├── chips-status.html
│   ├── browser-matrix.html
│   ├── code-block.html
│   ├── comparison-table.html
│   ├── emoji-vocabulary.html
│   └── logo-placeholders.html
└── ui_kits/
    ├── docs/                  ← Docs-site UI kit (sidebar + content + TOC + code blocks)
    │   ├── README.md
    │   ├── index.html         ← live demo of a docs page
    │   └── components/*.jsx
    └── marketing/             ← Landing-page UI kit (hero + features + matrix + CTA)
        ├── README.md
        ├── index.html         ← live demo of the landing page
        └── components/*.jsx
```

There is no `slides/` directory because no slide template was provided in the source.

---

## Caveats (read me)

1. **No source brand.** Logo, colors, fonts, motion: all inferred. Push back.
2. **Font substitution.** Geist + JetBrains Mono loaded from Google Fonts CDN. No `.ttf` files copied. If you want self-hosted fonts, point me at them.
3. **Browser logos.** Used for identification under nominative fair-use; we don't bundle the trademark assets, we render monochrome glyphs.
4. **No slide template** in source → no `slides/` directory was generated. Ask if you want one.
5. **No mobile-app UI** in source — this is a CLI/library — so no iOS/Android frames are in the UI kits.

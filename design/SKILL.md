---
name: vebidor-design
description: Use this skill to generate well-branded interfaces and assets for Vebidor — a V-language WebDriver + WebDriver-BiDi library with a Playwright-style API — either for production or for throwaway prototypes, docs pages, marketing mocks, comparison tables, and code-block-heavy visuals. Contains brand voice, color and type tokens, emoji vocabulary, code-token palette, and React UI kits for a docs site and a marketing landing page.
user-invocable: true
---

Read the `README.md` file within this skill first — it contains:

- **What Vebidor is** (a V-language W3C WebDriver + WebDriver-BiDi client) and what it is *not* (no app, no website, no logo in source — every visual is a proposed identity, flagged).
- **CONTENT FUNDAMENTALS** — the voice (technical, achievement-oriented, comparison-first), the casing rules, and the **load-bearing emoji vocabulary** (✅ ⚠️ 🐛 ✨ 🎉 🏆 ⚡ 🚀 📦 📖 🎯 🌐 🎭 📱). Emoji are part of this brand; keep them in docs and marketing surfaces.
- **VISUAL FOUNDATIONS** — palette, type, spacing, motion, surface, card anatomy.
- **ICONOGRAPHY** — emoji for status; Lucide for UI chrome (flagged substitution); monochrome SVG glyphs for browser logos.
- **Index** — what lives where.

Then explore the other files:

- `colors_and_type.css` — all design tokens (`--vb-blue-500`, `--slate-950`, `--code-keyword`, `--font-mono`, `--space-*`, `--radius-*`, `--shadow-*`, `--motion-*`) plus base type styles and `.chip` classes. Drop this `<link rel="stylesheet">` into anything new — it's the foundation.
- `preview/` — 19 standalone design-system cards (colors, type, spacing, components, brand) you can crib markup from.
- `assets/` — placeholder logos (flagged) and browser glyphs.
- `ui_kits/docs/` — high-fidelity React docs-site recreation (TopNav, Sidebar, TocPanel, DocsPage, CodeBlock, Callout, ComparisonTable, ApiSignature). Component scope: each file attaches its exports to `window` so other `<script type="text/babel">` files can use them. To extend, copy components, add the `<script type="text/babel" src="…">` tag in `index.html`, and follow the same `window.X = X` pattern.
- `ui_kits/marketing/` — landing page recreation (MarketingNav, Hero, FeatureGrid, BrowserMatrix, PhasesTimeline, MarketingFooter). Same component-scoping pattern.
- `fonts/README.md` — fonts loaded via Google Fonts CDN (Geist + JetBrains Mono). Substitution is flagged; swap if the user has different brand fonts.

## When you're invoked

If the user invokes this skill without other guidance, ask what they want to build (docs page? landing section? CLI-output mockup? release-notes graphic? comparison table? terminal screenshot?). Ask which **surface** (docs, marketing, terminal) and which **slice of the API** they want to feature. Then act as an expert designer who outputs HTML artifacts — *or* production code if they're working on the real repo.

## When creating visual artifacts (slides, mocks, throwaway prototypes)

1. Copy the assets you need from `assets/` and any preview cards you want to lift markup from.
2. Create a static HTML file in the current project. Link `colors_and_type.css` (relative path).
3. Use the foundations: `--vb-blue-500` for accents, `--code-bg`/`--code-fg` and token classes for code, `.chip chip--success` etc for status, `--font-sans` + `--font-mono`.
4. Keep emoji where the brand uses them. ✅ ⚠️ ✨ 🏆 are *load-bearing*, not decoration.
5. Don't invent gradients or rounded-left-border cards. Use flat surfaces, borders, and one elevation step.

## When working on production code

Read this skill as brand reference. Lift values (hex codes, font stacks, radii, motion timings) from `colors_and_type.css` rather than approximating from screenshots. Component patterns in `ui_kits/` are cosmetic recreations, not production code — port the styling, not the JSX wiring.

## Caveats to flag

If the user asks you to ship a real logo, real fonts, real iconography — pause and confirm. Everything here is inferred from the source repo's prose (which has no visual identity). Push back on canonization.

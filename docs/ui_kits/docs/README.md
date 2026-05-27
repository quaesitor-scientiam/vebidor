# Vebidor Docs — UI Kit

A high-fidelity recreation of what a Vebidor documentation site would look like, using the foundations in `colors_and_type.css`. Modeled on the structure of the source `README.md` (Quick Start → API reference → Comparison tables → Examples → Phase history).

## What's in here

- `index.html` — live docs page demo. Click sidebar entries to switch pages. Click headings in the right TOC to scroll. Toggle the theme switcher in the top nav.
- `components/TopNav.jsx` — sticky top navigation with logo, search field, GitHub link, theme toggle
- `components/Sidebar.jsx` — left sidebar with section groupings and active-state highlighting
- `components/TocPanel.jsx` — right on-page table of contents
- `components/DocsPage.jsx` — prose page renderer (h1/h2/h3, paragraphs, lists, code blocks, callouts, comparison tables, API signatures)
- `components/Callout.jsx` — `✅` / `⚠️` / `🐛` / `✨` / `🎉` callout boxes
- `components/CodeBlock.jsx` — dark code block with header, lang label, copy button, optional line numbers
- `components/ComparisonTable.jsx` — feature comparison rows with status chips
- `components/ApiSignature.jsx` — function signature block (return type, params, description)

## Pages included

Four pages reachable from the sidebar:

1. **Quick Start** — install + first `launch_edge()` script
2. **Modern API** — Locators, selectors, web-first assertions (the brand's "flagship" content)
3. **WebDriver-BiDi** — network interception, isolated contexts
4. **Comparison** — the signature comparison table page

## What's intentionally not here

- No real search backend (the input is decorative + opens a fake palette on focus)
- No real routing (page state is React `useState`)
- No mobile breakpoint (the marketing kit has one)

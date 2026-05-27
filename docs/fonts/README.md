# Fonts

> ⚠️ **All fonts here are substitutions.** The Vebidor source repo declares no
> font preference — it's a CLI library with no UI. The two families chosen
> match the developer-tool register the brand voice suggests, but if you want
> a different pairing, swap freely.

## Substitutions

| Use | Family | Source | Why |
|---|---|---|---|
| Display, headings, body | **Geist** | Google Fonts | Modern geometric humanist sans. Open-source, ships from Vercel. Avoided Inter / Roboto per project guidelines on over-used families. |
| Monospace (code blocks) | **JetBrains Mono** | Google Fonts | The de-facto dev-tool monospace, with ligatures that read well for V's `!`, `!=`, `->` syntax. |

## How they're loaded

Loaded via Google Fonts CDN inside `colors_and_type.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700;800&family=JetBrains+Mono:ital,wght@0,400;0,500;0,700;1,400&display=swap');
```

## Self-hosting

No `.ttf` / `.woff2` files are checked into this folder. If you want to
self-host (for offline rendering, GDPR, etc.), download from:

- Geist — https://github.com/vercel/geist-font (OFL, Vercel)
- JetBrains Mono — https://github.com/JetBrains/JetBrainsMono (OFL, JetBrains)

…drop the `.woff2` files into this folder, and replace the `@import` in
`colors_and_type.css` with `@font-face` declarations.

## Ask

If Vebidor has (or should have) a different brand typeface — say so and I'll
re-thread it through the token file, preview cards, and UI kits.

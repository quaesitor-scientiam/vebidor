/* global React */
function BrowserMatrix() {
  return (
    <section id="browsers" className="mk-section mk-section--alt">
      <div className="mk-container">
        <div style={bmStyles.head}>
          <div style={bmStyles.eyebrow}>Cross-browser, cross-platform</div>
          <h2 style={bmStyles.h2}>Four browsers, one W3C-standard API.</h2>
          <p style={bmStyles.sub}>Talks to any conformant WebDriver — including Safari's <code style={bmStyles.code}>safaridriver</code> — not a Chromium-only protocol.</p>
        </div>
        <div style={bmStyles.grid}>
          {BROWSERS.map((b, i) => (
            <div key={i} style={{ ...bmStyles.card, "--accent": b.color }}>
              <div style={{ ...bmStyles.iconWrap, color: b.color, background: b.bg }}>
                <svg viewBox={b.viewBox} width="28" height="28" fill="currentColor">
                  <path d={b.path} />
                </svg>
              </div>
              <div style={bmStyles.name}>{b.name}</div>
              <div style={bmStyles.meta}><span style={bmStyles.metaLabel}>Driver</span><span>{b.driver}</span></div>
              <div style={bmStyles.meta}><span style={bmStyles.metaLabel}>Port</span><code style={bmStyles.port}>{b.port}</code></div>
              <div style={bmStyles.meta}><span style={bmStyles.metaLabel}>Platforms</span><span>{b.platforms}</span></div>
              <div style={bmStyles.statusRow}>
                <span className="chip chip--success"><span className="emoji">✅</span> Production-ready</span>
              </div>
            </div>
          ))}
        </div>
        <div style={bmStyles.footnote}>
          All four verified live. v3.1.1 fixed the multi-browser compile path; <code style={bmStyles.code}>new_*_driver()</code> calls share the same session helper.
        </div>
      </div>
    </section>
  );
}

const BROWSERS = [
  { name: "Edge",    color: "#0F6CBD", bg: "rgba(15,108,189,0.08)",  driver: "EdgeDriver",    port: "9515", platforms: "Win · macOS · Linux", viewBox: "0 0 24 24", path: "M21.86 17.86q.14 0 .25.12.1.13.1.25 0 .24-.4.79-.4.54-1.22 1.15-.83.6-2.16 1.06-1.34.45-3.12.45-1.7 0-3.27-.6-1.55-.59-2.72-1.65-1.17-1.07-1.86-2.55-.68-1.48-.68-3.27 0-1.43.43-2.65.43-1.22 1.13-2.18.7-.96 1.61-1.66.92-.7 1.91-1.13.99-.43 2-.65 1.01-.22 1.93-.22.83 0 1.76.27.94.27 1.74.85.8.59 1.39 1.55.59.95.71 2.34l-.05.13q-.6.16-1.18.4t-1.13.62q-.55.4-1 .94l-.27.32q-.27.32-.45.65l-.46.84q-.18.4-.24 1.04l-.05 1.21q.04.61.21 1.34.18.73.62 1.4.43.66 1.19 1.12.76.47 1.95.47.51 0 1.05-.11.55-.11 1.05-.27.51-.16.92-.32t.59-.24q.08-.04.16-.04Z" },
  { name: "Chrome",  color: "#1A73E8", bg: "rgba(26,115,232,0.08)",  driver: "ChromeDriver",  port: "9515", platforms: "Win · macOS · Linux", viewBox: "0 0 24 24", path: "M12 0a12 12 0 0 1 10.39 6h-9.43a6 6 0 0 0-5.46 3.56L3.65 4.36A12 12 0 0 1 12 0Zm-6.94 5.6L9.5 13.21A6 6 0 0 0 17.4 16l-3.96 6.87A12 12 0 0 1 5.06 5.6ZM23.4 7.06A12 12 0 0 1 14.95 23.9l4.59-7.95a6 6 0 0 0 .55-7.21ZM7.98 11.98A4.02 4.02 0 0 1 16.02 12 4.02 4.02 0 0 1 7.98 12Z" },
  { name: "Firefox", color: "#FF7139", bg: "rgba(255,113,57,0.10)",  driver: "GeckoDriver",   port: "4444", platforms: "Win · macOS · Linux", viewBox: "0 0 24 24", path: "M12 2.5a9.5 9.5 0 1 0 9.5 9.5 9.5 9.5 0 0 0-9.5-9.5Zm0 16.5a7 7 0 1 1 7-7 7 7 0 0 1-7 7Z" },
  { name: "Safari",  color: "#0FB5EE", bg: "rgba(15,181,238,0.10)",  driver: "SafariDriver",  port: "4445", platforms: "macOS only",          viewBox: "0 0 24 24", path: "M12 2.5a9.5 9.5 0 1 0 9.5 9.5 9.5 9.5 0 0 0-9.5-9.5Zm0 17a7.5 7.5 0 1 1 7.5-7.5 7.5 7.5 0 0 1-7.5 7.5Zm1.4-9.4 4.3-6.5a.5.5 0 0 1 .77.6l-3.4 7.2a2 2 0 1 1-1.67-1.3Z" },
];

const bmStyles = {
  head: { textAlign: "left", maxWidth: 720, marginBottom: 36 },
  eyebrow: { fontFamily: "var(--font-sans)", fontSize: 12, fontWeight: 600, color: "var(--vb-blue-600)", textTransform: "uppercase", letterSpacing: "0.08em", marginBottom: 10 },
  h2: { fontFamily: "var(--font-sans)", fontWeight: 700, fontSize: 36, lineHeight: 1.15, letterSpacing: "-0.025em", margin: "0 0 12px", color: "var(--fg-1)" },
  sub: { fontFamily: "var(--font-sans)", fontSize: 17, lineHeight: 1.55, color: "var(--fg-2)", margin: 0 },
  code: { fontFamily: "var(--font-mono)", fontSize: "0.9em", color: "var(--fg-1)", background: "var(--surface-2)", padding: "0.08em 0.4em", borderRadius: 4, border: "1px solid var(--border-1)" },
  grid: { display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 16 },
  card: { background: "#fff", border: "1px solid var(--border-1)", borderRadius: "var(--radius-lg)", padding: 22, display: "flex", flexDirection: "column", gap: 8 },
  iconWrap: { width: 48, height: 48, borderRadius: "var(--radius-md)", display: "inline-flex", alignItems: "center", justifyContent: "center", marginBottom: 8 },
  name: { fontFamily: "var(--font-sans)", fontSize: 20, fontWeight: 700, letterSpacing: "-0.02em", color: "var(--fg-1)", marginBottom: 6 },
  meta: { display: "flex", justifyContent: "space-between", fontFamily: "var(--font-sans)", fontSize: 12.5, color: "var(--fg-2)", padding: "4px 0", borderTop: "1px solid var(--border-1)" },
  metaLabel: { color: "var(--fg-3)", textTransform: "uppercase", fontSize: 10.5, letterSpacing: "0.06em", fontWeight: 600 },
  port: { fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--fg-1)" },
  statusRow: { marginTop: 10 },
  footnote: { marginTop: 28, fontFamily: "var(--font-sans)", fontSize: 13, color: "var(--fg-3)" },
};

window.BrowserMatrix = BrowserMatrix;

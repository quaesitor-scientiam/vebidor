/* global React */
function MarketingFooter() {
  return (
    <footer style={fStyles.footer}>
      <div className="mk-container" style={fStyles.inner}>
        <div style={fStyles.brandCol}>
          <div style={fStyles.brandRow}>
            <img src="../../assets/logo-vebidor.png" width="32" height="32" alt="vebidor" style={{ borderRadius: 7, display: "block" }} />
            <span style={fStyles.wm}>vebidor</span>
          </div>
          <p style={fStyles.tagline}>A V language implementation of the W3C WebDriver protocol for browser automation.</p>
          <div style={fStyles.metaRow}>
            <span style={fStyles.metaChip}>MIT</span>
            <span style={fStyles.metaChip}>v4.2.0</span>
            <span style={fStyles.metaChip}>0 deps</span>
          </div>
        </div>
        <div style={fStyles.cols}>
          <FooterCol label="Docs" links={["Quick start", "Modern API", "Selectors", "Assertions", "WebDriver-BiDi"]} />
          <FooterCol label="Reference" links={["Changelog", "vs Selenium", "vs Playwright", "License", "Examples"]} />
          <FooterCol label="Project" links={["GitHub", "Issues", "v.mod", "Contributing", "Sponsors"]} />
        </div>
      </div>
      <div style={fStyles.bottom}>
        <div className="mk-container" style={fStyles.bottomInner}>
          <div style={fStyles.bottomLeft}>
            <span className="emoji">🏆</span> 100% Selenium feature parity · verified live against headless Edge
          </div>
          <div style={fStyles.bottomRight}>© 2026 quaesitor-scientiam · MIT</div>
        </div>
      </div>
    </footer>
  );
}

function FooterCol({ label, links }) {
  return (
    <div style={fStyles.col}>
      <div style={fStyles.colLabel}>{label}</div>
      <ul style={fStyles.list}>
        {links.map((l, i) => (
          <li key={i}><a href="#" style={fStyles.link}>{l}</a></li>
        ))}
      </ul>
    </div>
  );
}

const fStyles = {
  footer: { borderTop: "1px solid var(--border-1)", background: "var(--surface-0)", marginTop: 40 },
  inner: { display: "grid", gridTemplateColumns: "1.2fr 2fr", gap: 56, padding: "56px 32px 36px" },
  brandCol: { maxWidth: 320 },
  brandRow: { display: "flex", alignItems: "center", gap: 10, marginBottom: 14 },
  wm: { fontFamily: "var(--font-sans)", fontWeight: 800, fontSize: 22, letterSpacing: "-0.03em", color: "var(--vb-blue-800)" },
  tagline: { fontFamily: "var(--font-sans)", fontSize: 14, lineHeight: 1.55, color: "var(--fg-2)", margin: "0 0 16px" },
  metaRow: { display: "flex", gap: 8 },
  metaChip: { fontFamily: "var(--font-mono)", fontSize: 11, padding: "3px 8px", background: "var(--surface-2)", color: "var(--fg-2)", borderRadius: "var(--radius-pill)", border: "1px solid var(--border-1)" },
  cols: { display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 24 },
  col: {},
  colLabel: { fontFamily: "var(--font-sans)", fontSize: 12, fontWeight: 600, color: "var(--fg-1)", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 12 },
  list: { listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: 8 },
  link: { fontFamily: "var(--font-sans)", fontSize: 13.5, color: "var(--fg-2)", border: 0 },
  bottom: { borderTop: "1px solid var(--border-1)", background: "var(--surface-1)" },
  bottomInner: { display: "flex", alignItems: "center", justifyContent: "space-between", padding: "16px 32px", fontFamily: "var(--font-sans)", fontSize: 12.5, color: "var(--fg-3)" },
  bottomLeft: { display: "flex", alignItems: "center", gap: 8 },
  bottomRight: { fontFamily: "var(--font-mono)" },
};

window.MarketingFooter = MarketingFooter;

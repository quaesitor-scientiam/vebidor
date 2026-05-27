/* global React */
function MarketingNav() {
  return (
    <div style={mnStyles.bar}>
      <div style={mnStyles.inner}>
        <div style={mnStyles.left}>
          <a href="index.html" style={mnStyles.brand}>
            <img src="../../assets/logo-vebidor-mark.svg" width="24" height="24" alt="" />
            <span style={mnStyles.wm}>vebidor</span>
          </a>
          <nav style={mnStyles.nav}>
            <a style={mnStyles.link} href="#features">Features</a>
            <a style={mnStyles.link} href="#browsers">Browsers</a>
            <a style={mnStyles.link} href="#phases">Phases</a>
            <a style={mnStyles.link} href="../docs/index.html">Docs</a>
          </nav>
        </div>
        <div style={mnStyles.right}>
          <a href="https://github.com/quaesitor-scientiam/vebidor" style={mnStyles.star}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M12 .5C5.65.5.5 5.65.5 12c0 5.08 3.29 9.39 7.86 10.91.58.1.79-.25.79-.56v-1.98c-3.2.7-3.87-1.54-3.87-1.54-.52-1.34-1.28-1.7-1.28-1.7-1.05-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.71 1.26 3.37.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.68 0-1.26.45-2.28 1.19-3.08-.12-.29-.51-1.46.11-3.05 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.79 0c2.21-1.49 3.18-1.18 3.18-1.18.62 1.59.23 2.76.11 3.05.74.8 1.19 1.82 1.19 3.08 0 4.41-2.69 5.38-5.26 5.67.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.55 4.56-1.53 7.85-5.83 7.85-10.91C23.5 5.65 18.35.5 12 .5Z"/></svg>
            <span>quaesitor-scientiam/vebidor</span>
            <span style={mnStyles.starCount}>★ 1.2k</span>
          </a>
          <a href="../docs/index.html" style={mnStyles.cta}>Get started</a>
        </div>
      </div>
    </div>
  );
}

const mnStyles = {
  bar: { position: "sticky", top: 0, background: "rgba(255,255,255,0.82)", backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)", borderBottom: "1px solid var(--border-1)", zIndex: 50 },
  inner: { maxWidth: "var(--container-wide)", margin: "0 auto", padding: "0 32px", height: 64, display: "flex", alignItems: "center", justifyContent: "space-between", gap: 24 },
  left: { display: "flex", alignItems: "center", gap: 36 },
  brand: { display: "flex", alignItems: "center", gap: 8, color: "var(--fg-1)", border: 0 },
  wm: { fontFamily: "var(--font-sans)", fontWeight: 800, fontSize: 19, letterSpacing: "-0.03em", color: "var(--vb-blue-800)" },
  nav: { display: "flex", gap: 24 },
  link: { fontFamily: "var(--font-sans)", fontSize: 14, color: "var(--fg-2)", border: 0, fontWeight: 500 },
  right: { display: "flex", alignItems: "center", gap: 12 },
  star: { display: "inline-flex", alignItems: "center", gap: 8, padding: "6px 12px", background: "var(--surface-1)", border: "1px solid var(--border-1)", borderRadius: "var(--radius-sm)", fontFamily: "var(--font-mono)", fontSize: 12, color: "var(--fg-1)" },
  starCount: { fontFamily: "var(--font-sans)", fontWeight: 600, color: "var(--milestone-fg)", marginLeft: 4 },
  cta: { background: "var(--vb-blue-500)", color: "#fff", padding: "8px 14px", borderRadius: "var(--radius-sm)", fontFamily: "var(--font-sans)", fontWeight: 600, fontSize: 13.5, border: 0 },
};

window.MarketingNav = MarketingNav;

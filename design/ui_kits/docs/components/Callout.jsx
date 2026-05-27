/* global React */
function Callout({ kind = "info", title, children }) {
  const config = {
    success:   { em: "✅", bg: "var(--success-bg)",   fg: "var(--success-fg)",   line: "var(--success-line)" },
    warning:   { em: "⚠️", bg: "var(--warning-bg)",   fg: "var(--warning-fg)",   line: "var(--warning-line)" },
    danger:    { em: "🐛", bg: "var(--danger-bg)",    fg: "var(--danger-fg)",    line: "var(--danger-line)" },
    info:      { em: "✨", bg: "var(--info-bg)",      fg: "var(--info-fg)",      line: "var(--info-line)" },
    milestone: { em: "🏆", bg: "var(--milestone-bg)", fg: "var(--milestone-fg)", line: "var(--milestone-line)" },
  }[kind];

  return (
    <div style={{
      background: config.bg,
      borderLeft: `3px solid ${config.line}`,
      borderRadius: "var(--radius-md)",
      padding: "14px 16px",
      margin: "16px 0",
      display: "flex",
      gap: 12,
    }}>
      <span style={{ fontFamily: "var(--font-emoji)", fontSize: 18, lineHeight: 1.4, flexShrink: 0 }}>{config.em}</span>
      <div style={{ flex: 1, color: "var(--fg-1)", fontSize: 14, lineHeight: 1.55 }}>
        {title && <div style={{ fontWeight: 600, color: config.fg, marginBottom: 4 }}>{title}</div>}
        {children}
      </div>
    </div>
  );
}

window.Callout = Callout;

/* global React */
function TocPanel({ items }) {
  return (
    <aside style={tocStyles.aside}>
      <div style={tocStyles.label}>On this page</div>
      <ul style={tocStyles.list}>
        {items.map((it, i) => (
          <li key={i}>
            <a
              href={`#${it.id}`}
              style={{
                ...tocStyles.link,
                ...(it.depth === 2 ? tocStyles.linkSub : {}),
              }}
            >
              {it.label}
            </a>
          </li>
        ))}
      </ul>
      <div style={tocStyles.divider} />
      <a href="https://github.com/quaesitor-scientiam/vebidor" style={tocStyles.editLink}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: 6 }}>
          <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5Z"/>
        </svg>
        Edit on GitHub
      </a>
    </aside>
  );
}

const tocStyles = {
  aside: {
    position: "sticky",
    top: "var(--topnav-height)",
    alignSelf: "start",
    padding: "36px 24px 32px 16px",
    maxHeight: "calc(100vh - var(--topnav-height))",
    overflowY: "auto",
  },
  label: {
    fontFamily: "var(--font-sans)",
    fontSize: 11,
    fontWeight: 600,
    color: "var(--fg-3)",
    textTransform: "uppercase",
    letterSpacing: "0.06em",
    marginBottom: 10,
  },
  list: { listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: 4, borderLeft: "1px solid var(--border-1)", paddingLeft: 0 },
  link: {
    display: "block",
    fontFamily: "var(--font-sans)",
    fontSize: 13,
    color: "var(--fg-2)",
    textDecoration: "none",
    padding: "3px 12px",
    borderLeft: "2px solid transparent",
    marginLeft: -1,
    lineHeight: 1.45,
    border: 0,
    borderLeftStyle: "solid",
    borderLeftColor: "transparent",
    borderLeftWidth: 2,
  },
  linkSub: { paddingLeft: 24, color: "var(--fg-3)", fontSize: 12.5 },
  divider: { height: 1, background: "var(--border-1)", margin: "16px 0" },
  editLink: { fontFamily: "var(--font-sans)", fontSize: 12, color: "var(--fg-3)", display: "inline-flex", alignItems: "center", border: 0 },
};

window.TocPanel = TocPanel;

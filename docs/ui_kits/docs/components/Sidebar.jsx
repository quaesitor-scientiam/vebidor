/* global React */
function Sidebar({ pages, activeId, onSelect }) {
  // Group pages by section
  const groups = pages.reduce((acc, p) => {
    (acc[p.section] = acc[p.section] || []).push(p);
    return acc;
  }, {});
  return (
    <aside style={sbStyles.aside}>
      {Object.entries(groups).map(([section, items]) => (
        <div key={section} style={sbStyles.group}>
          <div style={sbStyles.groupLabel}>{section}</div>
          <ul style={sbStyles.list}>
            {items.map((p) => {
              const active = p.id === activeId;
              return (
                <li key={p.id}>
                  <a
                    href="#"
                    onClick={(e) => { e.preventDefault(); onSelect(p.id); }}
                    style={{
                      ...sbStyles.link,
                      ...(active ? sbStyles.linkActive : {}),
                    }}
                  >
                    {p.title}
                    {p.chip && (
                      <span style={{ ...sbStyles.chip, ...(p.chip === "new" || p.chip === "preview" ? sbStyles.chipNew : sbStyles.chipNeutral) }}>
                        {p.chip}
                      </span>
                    )}
                  </a>
                </li>
              );
            })}
          </ul>
        </div>
      ))}
    </aside>
  );
}

const sbStyles = {
  aside: {
    position: "sticky",
    top: "var(--topnav-height)",
    alignSelf: "start",
    padding: "32px 16px 32px 24px",
    maxHeight: "calc(100vh - var(--topnav-height))",
    overflowY: "auto",
    borderRight: "1px solid var(--border-1)",
  },
  group: { marginBottom: 22 },
  groupLabel: {
    fontFamily: "var(--font-sans)",
    fontSize: 11,
    fontWeight: 600,
    color: "var(--fg-3)",
    textTransform: "uppercase",
    letterSpacing: "0.06em",
    marginBottom: 8,
    padding: "0 8px",
  },
  list: { listStyle: "none", margin: 0, padding: 0, display: "flex", flexDirection: "column", gap: 1 },
  link: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    fontFamily: "var(--font-sans)",
    fontSize: 13.5,
    color: "var(--fg-2)",
    textDecoration: "none",
    padding: "5px 8px",
    borderRadius: 5,
    border: 0,
    lineHeight: 1.4,
  },
  linkActive: {
    color: "var(--vb-blue-700)",
    background: "var(--vb-blue-50)",
    fontWeight: 600,
  },
  chip: {
    fontFamily: "var(--font-sans)",
    fontSize: 10,
    padding: "1px 6px",
    borderRadius: 4,
    fontWeight: 600,
    textTransform: "uppercase",
    letterSpacing: "0.04em",
  },
  chipNew: { background: "var(--info-bg)", color: "var(--info-fg)" },
  chipNeutral: { background: "var(--surface-2)", color: "var(--fg-3)" },
};

window.Sidebar = Sidebar;

/* global React */
function StatusChip({ kind, children }) {
  const cls = {
    success: "chip chip--success",
    warning: "chip chip--warning",
    danger: "chip chip--danger",
    info: "chip chip--info",
    milestone: "chip chip--milestone",
    neutral: "chip chip--neutral",
  }[kind] || "chip chip--neutral";
  return <span className={cls}>{children}</span>;
}

function ComparisonTable({ columns, rows }) {
  return (
    <div style={ctStyles.wrap}>
      <table style={ctStyles.tbl}>
        <thead>
          <tr>
            {columns.map((c, i) => (
              <th key={i} style={{ ...ctStyles.th, width: c.width }}>{c.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={i}>
              {row.map((cell, j) => (
                <td key={j} style={ctStyles.td}>
                  {typeof cell === "object" && cell !== null && cell.chip ? (
                    <StatusChip kind={cell.kind}>
                      <span className="emoji">{cell.em}</span> {cell.chip}
                    </StatusChip>
                  ) : (
                    cell
                  )}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

const ctStyles = {
  wrap: {
    border: "1px solid var(--border-1)",
    borderRadius: "var(--radius-lg)",
    overflow: "hidden",
    margin: "20px 0",
  },
  tbl: { width: "100%", borderCollapse: "collapse", fontFamily: "var(--font-sans)", fontSize: 13.5 },
  th: {
    textAlign: "left",
    padding: "10px 14px",
    background: "var(--surface-1)",
    color: "var(--fg-2)",
    fontWeight: 600,
    fontSize: 12,
    textTransform: "uppercase",
    letterSpacing: "0.04em",
    borderBottom: "1px solid var(--border-2)",
  },
  td: {
    padding: "12px 14px",
    borderBottom: "1px solid var(--border-1)",
    color: "var(--fg-1)",
    verticalAlign: "top",
  },
};

window.ComparisonTable = ComparisonTable;
window.StatusChip = StatusChip;

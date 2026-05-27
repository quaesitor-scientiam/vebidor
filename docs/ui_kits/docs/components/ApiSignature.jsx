/* global React */
function ApiSignature({ name, params = [], returns, description }) {
  return (
    <div style={apiStyles.frame}>
      <div style={apiStyles.signature}>
        <span style={apiStyles.kw}>pub fn</span>{" "}
        <span style={apiStyles.name}>{name}</span>
        <span style={apiStyles.paren}>(</span>
        {params.map((p, i) => (
          <React.Fragment key={i}>
            {i > 0 && <span style={apiStyles.comma}>, </span>}
            <span style={apiStyles.paramName}>{p.name}</span>
            <span style={apiStyles.colon}> </span>
            <span style={apiStyles.paramType}>{p.type}</span>
          </React.Fragment>
        ))}
        <span style={apiStyles.paren}>)</span>
        {returns && (
          <>
            <span style={apiStyles.arrow}> ! </span>
            <span style={apiStyles.returns}>{returns}</span>
          </>
        )}
      </div>
      {description && <div style={apiStyles.desc}>{description}</div>}
      {params.length > 0 && (
        <div style={apiStyles.paramList}>
          {params.map((p, i) => (
            <div key={i} style={apiStyles.paramRow}>
              <code style={apiStyles.paramKey}>{p.name}</code>
              <span style={apiStyles.paramTypeIn}>{p.type}</span>
              {p.note && <span style={apiStyles.paramNote}>— {p.note}</span>}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

const apiStyles = {
  frame: {
    border: "1px solid var(--border-1)",
    borderRadius: "var(--radius-lg)",
    padding: 18,
    margin: "20px 0",
    background: "var(--surface-0)",
  },
  signature: {
    fontFamily: "var(--font-mono)",
    fontSize: 14,
    color: "var(--fg-1)",
    letterSpacing: "-0.01em",
    paddingBottom: 12,
    borderBottom: "1px solid var(--border-1)",
    marginBottom: 12,
  },
  kw: { color: "var(--code-keyword)", fontWeight: 500 },
  name: { color: "var(--code-function)", fontWeight: 600 },
  paren: { color: "var(--fg-3)" },
  comma: { color: "var(--fg-3)" },
  paramName: { color: "var(--fg-1)" },
  colon: { color: "var(--fg-3)" },
  paramType: { color: "var(--code-type)" },
  arrow: { color: "var(--fg-3)" },
  returns: { color: "var(--code-type)" },
  desc: { fontFamily: "var(--font-sans)", fontSize: 14, color: "var(--fg-2)", lineHeight: 1.55, marginBottom: 12 },
  paramList: { display: "flex", flexDirection: "column", gap: 6 },
  paramRow: { display: "flex", gap: 8, alignItems: "baseline", fontSize: 12.5, fontFamily: "var(--font-sans)" },
  paramKey: { fontFamily: "var(--font-mono)", color: "var(--fg-1)", background: "var(--surface-2)", padding: "1px 6px", borderRadius: 4, border: "1px solid var(--border-1)" },
  paramTypeIn: { fontFamily: "var(--font-mono)", color: "var(--code-type)", fontSize: 12 },
  paramNote: { color: "var(--fg-3)" },
};

window.ApiSignature = ApiSignature;

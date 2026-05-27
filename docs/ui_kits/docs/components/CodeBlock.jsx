/* global React */
const { useState, useRef } = React;

function CodeBlock({ lang = "v", filename, lines, showLineNumbers = false }) {
  const [copied, setCopied] = useState(false);
  const onCopy = () => {
    const text = lines.map((l) => l.map((tok) => tok.t).join("")).join("\n");
    if (navigator.clipboard) {
      navigator.clipboard.writeText(text).catch(() => {});
    }
    setCopied(true);
    setTimeout(() => setCopied(false), 1200);
  };

  return (
    <div style={cbStyles.frame}>
      <div style={cbStyles.head}>
        <span style={cbStyles.lang}>{filename ? `${lang} · ${filename}` : lang}</span>
        <button style={cbStyles.copy} onClick={onCopy}>
          {copied ? "Copied" : "Copy"}
        </button>
      </div>
      <pre style={cbStyles.pre}>
        <code>
          {lines.map((toks, i) => (
            <div key={i}>
              {showLineNumbers && <span style={cbStyles.ln}>{i + 1}</span>}
              {toks.map((tok, j) => (
                <span key={j} style={tok.k ? cbStyles[tok.k] : null}>{tok.t}</span>
              ))}
            </div>
          ))}
        </code>
      </pre>
    </div>
  );
}

const cbStyles = {
  frame: {
    background: "var(--code-bg)",
    borderRadius: "var(--radius-md)",
    overflow: "hidden",
    border: "1px solid var(--slate-800)",
    margin: "16px 0",
  },
  head: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "8px 14px",
    background: "var(--slate-900)",
    borderBottom: "1px solid var(--slate-800)",
  },
  lang: { fontFamily: "var(--font-mono)", fontSize: 11.5, color: "var(--slate-400)" },
  copy: {
    fontFamily: "var(--font-sans)",
    fontSize: 11.5,
    color: "var(--slate-300)",
    background: "var(--slate-800)",
    padding: "4px 10px",
    borderRadius: 5,
    border: 0,
    cursor: "pointer",
  },
  pre: {
    margin: 0,
    padding: "14px 16px",
    fontFamily: "var(--font-mono)",
    fontSize: 13,
    lineHeight: 1.6,
    color: "var(--code-fg)",
    letterSpacing: "-0.01em",
    overflowX: "auto",
  },
  ln: {
    display: "inline-block",
    width: 22,
    color: "var(--slate-600)",
    userSelect: "none",
    textAlign: "right",
    paddingRight: 12,
  },
  keyword: { color: "var(--code-keyword)" },
  string: { color: "var(--code-string)" },
  number: { color: "var(--code-number)" },
  function: { color: "var(--code-function)" },
  type: { color: "var(--code-type)" },
  comment: { color: "var(--code-comment)", fontStyle: "italic" },
};

window.CodeBlock = CodeBlock;

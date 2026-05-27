/* global React, CodeBlock, Callout, ComparisonTable, ApiSignature */
const { useState: usDS } = React;

const dpStyles = {
  page: { maxWidth: 760, margin: 0 },
  breadcrumb: { fontFamily: "var(--font-sans)", fontSize: 12.5, color: "var(--fg-3)", marginBottom: 14 },
  breadcrumb_b: { color: "var(--fg-2)" },
  h1: { fontFamily: "var(--font-sans)", fontWeight: 800, fontSize: 40, lineHeight: 1.1, letterSpacing: "-0.025em", margin: "0 0 12px", color: "var(--fg-1)" },
  lede: { fontFamily: "var(--font-sans)", fontSize: 19, lineHeight: 1.5, color: "var(--fg-2)", margin: "0 0 32px" },
  h2: { fontFamily: "var(--font-sans)", fontWeight: 700, fontSize: 26, lineHeight: 1.25, letterSpacing: "-0.02em", margin: "44px 0 12px", color: "var(--fg-1)" },
  h3: { fontFamily: "var(--font-sans)", fontWeight: 600, fontSize: 19, lineHeight: 1.3, margin: "30px 0 8px", color: "var(--fg-1)" },
  p: { fontFamily: "var(--font-sans)", fontSize: 16, lineHeight: 1.65, color: "var(--fg-1)", margin: "0 0 16px", textWrap: "pretty" },
  ul: { margin: "0 0 16px", paddingLeft: 22, fontFamily: "var(--font-sans)", fontSize: 16, lineHeight: 1.65, color: "var(--fg-1)" },
  li: { marginBottom: 4 },
  footer: { display: "flex", justifyContent: "space-between", gap: 12, marginTop: 64, paddingTop: 24, borderTop: "1px solid var(--border-1)" },
  fbtn: { flex: 1, padding: "14px 16px", border: "1px solid var(--border-1)", borderRadius: "var(--radius-lg)", background: "#fff", color: "var(--fg-1)", textDecoration: "none", fontFamily: "var(--font-sans)", fontSize: 14, cursor: "pointer" },
  fbtn_label: { fontSize: 11, color: "var(--fg-3)", textTransform: "uppercase", letterSpacing: "0.04em", display: "block", marginBottom: 4 },
  fbtn_title: { fontWeight: 600 },
  inlineCode: { fontFamily: "var(--font-mono)", fontSize: "0.9em", background: "var(--surface-2)", color: "var(--fg-1)", padding: "0.12em 0.4em", borderRadius: 4, border: "1px solid var(--border-1)" },
};

const C = (text) => <code style={dpStyles.inlineCode}>{text}</code>;

// ───────── PAGE: Quick Start ─────────
function PageQuickStart({ onNavigate }) {
  const nav = (id) => (e) => { e.preventDefault(); onNavigate && onNavigate(id); };
  return (
    <article style={dpStyles.page}>
      <div style={dpStyles.breadcrumb}>Getting started <span style={{ margin: "0 6px", color: "var(--fg-4)" }}>/</span> <span style={dpStyles.breadcrumb_b}>Quick start</span></div>
      <h1 id="quick-start" style={dpStyles.h1}>Quick start</h1>
      <p style={dpStyles.lede}>Get a browser launched, a page navigated, and an assertion polling in three lines of V — no manual driver setup.</p>

      <h2 id="install" style={dpStyles.h2}>Install</h2>
      <p style={dpStyles.p}>Add Vebidor to your <code style={dpStyles.inlineCode}>v.mod</code> dependencies and pull it in with a single import.</p>
      <CodeBlock lang="vlang" filename="v.mod" lines={[
        [{ t: "Module {" }],
        [{ t: "  ", k: null }, { t: "name:", k: "keyword" }, { t: " ", k: null }, { t: "'my-bot'", k: "string" }],
        [{ t: "  ", k: null }, { t: "dependencies:", k: "keyword" }, { t: " [", k: null }, { t: "'vebidor'", k: "string" }, { t: "]", k: null }],
        [{ t: "}" }],
      ]} />

      <h2 id="first-script" style={dpStyles.h2}>Your first script</h2>
      <p style={dpStyles.p}>{C('launch_edge()')} locates the driver on <code style={dpStyles.inlineCode}>PATH</code>, picks a free port, opens a session, and tears everything down on <code style={dpStyles.inlineCode}>close()</code>.</p>
      <CodeBlock lang="vlang" filename="example_quick_start.v" showLineNumbers lines={[
        [{ t: "import", k: "keyword" }, { t: " vebidor.webdriver" }],
        [{ t: "" }],
        [{ t: "fn", k: "keyword" }, { t: " " }, { t: "main", k: "function" }, { t: "() {" }],
        [{ t: "  mut", k: "keyword" }, { t: " b := webdriver." }, { t: "launch_edge", k: "function" }, { t: "(webdriver." }, { t: "LaunchOptions", k: "type" }, { t: "{ headless: " }, { t: "true", k: "keyword" }, { t: " })!" }],
        [{ t: "  defer", k: "keyword" }, { t: " { b." }, { t: "close", k: "function" }, { t: "() }" }],
        [{ t: "" }],
        [{ t: "  b." }, { t: "goto", k: "function" }, { t: "(" }, { t: "'https://example.com'", k: "string" }, { t: ")!" }],
        [{ t: "  webdriver." }, { t: "expect", k: "function" }, { t: "(b.wd." }, { t: "get_by_role", k: "function" }, { t: "(" }, { t: "'heading'", k: "string" }, { t: ", " }, { t: "''", k: "string" }, { t: "))." }, { t: "to_be_visible", k: "function" }, { t: "()!" }],
        [{ t: "}" }],
      ]} />

      <Callout kind="info" title="What just happened?">
        <p style={{ margin: 0 }}>{C('expect()')} polls the locator for up to 30 seconds. The heading doesn't need to be in the DOM yet — Vebidor will wait for it.</p>
      </Callout>

      <h2 id="run" style={dpStyles.h2}>Run it</h2>
      <CodeBlock lang="bash" filename="terminal" lines={[
        [{ t: "$ ", k: "comment" }, { t: "v run example_quick_start.v" }],
        [{ t: "✓ heading: \"Example Domain\"", k: "string" }],
      ]} />

      <h2 id="next" style={dpStyles.h2}>Next steps</h2>
      <ul style={dpStyles.ul}>
        <li style={dpStyles.li}><a href="#modern-api" onClick={nav("modern-api")}>Modern API</a> — Locators, selectors, retrying assertions</li>
        <li style={dpStyles.li}><a href="#bidi" onClick={nav("bidi")}>WebDriver-BiDi</a> — network interception, isolated contexts, mobile emulation</li>
        <li style={dpStyles.li}><a href="#comparison" onClick={nav("comparison")}>Comparison with Selenium &amp; Playwright</a> — feature-by-feature</li>
      </ul>
    </article>
  );
}

// ───────── PAGE: Modern API ─────────
function PageModernApi() {
  return (
    <article style={dpStyles.page}>
      <div style={dpStyles.breadcrumb}>API reference <span style={{ margin: "0 6px", color: "var(--fg-4)" }}>/</span> <span style={dpStyles.breadcrumb_b}>Modern API</span></div>
      <h1 id="modern-api" style={dpStyles.h1}>Modern API <span className="chip chip--info" style={{ verticalAlign: "middle", marginLeft: 10, fontSize: 11 }}>✨ Playwright-style</span></h1>
      <p style={dpStyles.lede}>Lazy auto-waiting <code style={dpStyles.inlineCode}>Locator</code>s, semantic selector engines, and web-first retrying assertions — on top of the raw W3C WebDriver client.</p>

      <h2 id="locators" style={dpStyles.h2}>Locators</h2>
      <p style={dpStyles.p}>A {C('Locator')} is a <em>lazy</em> handle to an element. Unlike {C('ElementRef')}, it does not capture a specific element id up front — it stores the selection criteria and re-resolves on every use, so it's immune to staleness from DOM re-renders.</p>

      <ApiSignature
        name="get_by_role"
        params={[
          { name: "role", type: "string", note: "ARIA role: 'button', 'heading', 'link', …" },
          { name: "name", type: "string", note: "accessible name (substring match); '' to skip" },
        ]}
        returns="Locator"
        description="Return a locator targeting the first element with the given ARIA role and accessible name."
      />

      <h3 id="actions" style={dpStyles.h3}>Auto-waiting actions</h3>
      <p style={dpStyles.p}>Actions on a {C('Locator')} wait for the element to be attached, visible, enabled, and scrolled into view before acting.</p>
      <CodeBlock lang="vlang" lines={[
        [{ t: "b.wd." }, { t: "get_by_role", k: "function" }, { t: "(" }, { t: "'button'", k: "string" }, { t: ", " }, { t: "'Submit'", k: "string" }, { t: ")." }, { t: "click", k: "function" }, { t: "()!" }],
        [{ t: "b.wd." }, { t: "get_by_label", k: "function" }, { t: "(" }, { t: "'Email'", k: "string" }, { t: ")." }, { t: "fill", k: "function" }, { t: "(" }, { t: "'me@example.com'", k: "string" }, { t: ")!" }],
      ]} />

      <h2 id="assertions" style={dpStyles.h2}>Web-first assertions</h2>
      <p style={dpStyles.p}>{C('expect(loc).to_be_visible()')} polls the locator until the condition holds — no manual <code style={dpStyles.inlineCode}>sleep</code> required. Invert with {C('.not()')}, customize timeout with {C('.with_timeout(ms)')}.</p>
      <CodeBlock lang="vlang" lines={[
        [{ t: "webdriver.", k: null }, { t: "expect", k: "function" }, { t: "(loc)." }, { t: "to_have_text", k: "function" }, { t: "(" }, { t: "'Welcome'", k: "string" }, { t: ")!" }],
        [{ t: "webdriver.", k: null }, { t: "expect", k: "function" }, { t: "(loc)." }, { t: "not", k: "function" }, { t: "()." }, { t: "to_be_disabled", k: "function" }, { t: "()." }, { t: "with_timeout", k: "function" }, { t: "(" }, { t: "5000", k: "number" }, { t: ")!" }],
      ]} />

      <Callout kind="warning" title="One known limit">
        <p style={{ margin: 0 }}>Real <code style={dpStyles.inlineCode}>touchstart</code>/<code style={dpStyles.inlineCode}>touchend</code> events need driver-level touch emulation (CDP / mobileEmulation capability), which WebDriver-BiDi doesn't expose. {C('tap()')} synthesizes a click.</p>
      </Callout>
    </article>
  );
}

// ───────── PAGE: WebDriver-BiDi ─────────
function PageBiDi() {
  return (
    <article style={dpStyles.page}>
      <div style={dpStyles.breadcrumb}>API reference <span style={{ margin: "0 6px", color: "var(--fg-4)" }}>/</span> <span style={dpStyles.breadcrumb_b}>WebDriver-BiDi</span></div>
      <h1 id="bidi" style={dpStyles.h1}>WebDriver-BiDi <span className="emoji" style={{ fontSize: 28 }}>🎭</span></h1>
      <p style={dpStyles.lede}>Launch with {C('bidi: true')} to get a persistent WebSocket alongside the Classic session — network mocking, console events, isolated contexts, and more.</p>

      <h2 id="network-mocking" style={dpStyles.h2}>Network mocking</h2>
      <p style={dpStyles.p}>Intercept and rewrite responses with {C('route')} (Playwright-style). There is no Classic-WebDriver equivalent for this.</p>
      <CodeBlock lang="vlang" filename="example_bidi.v" lines={[
        [{ t: "mut", k: "keyword" }, { t: " b := webdriver." }, { t: "launch_edge", k: "function" }, { t: "(webdriver." }, { t: "LaunchOptions", k: "type" }, { t: "{" }],
        [{ t: "  headless: " }, { t: "true", k: "keyword" }, { t: ", bidi: " }, { t: "true", k: "keyword" }],
        [{ t: "})!" }],
        [{ t: "mut", k: "keyword" }, { t: " bidi := b." }, { t: "bidi", k: "function" }, { t: "()!" }],
        [{ t: "" }],
        [{ t: "bidi." }, { t: "route", k: "function" }, { t: "(" }, { t: "fn", k: "keyword" }, { t: " (req webdriver." }, { t: "InterceptedRequest", k: "type" }, { t: ") {" }],
        [{ t: "  ", k: null }, { t: "if", k: "keyword" }, { t: " req.url." }, { t: "contains", k: "function" }, { t: "(" }, { t: "'/api'", k: "string" }, { t: ") {" }],
        [{ t: "    req." }, { t: "fulfill", k: "function" }, { t: "(" }, { t: "200", k: "number" }, { t: ", " }, { t: "'application/json'", k: "string" }, { t: ", " }, { t: "'{\"mocked\":true}'", k: "string" }, { t: ") or {}" }],
        [{ t: "  } " }, { t: "else", k: "keyword" }, { t: " {" }],
        [{ t: "    req." }, { t: "continue_request", k: "function" }, { t: "() or {}" }],
        [{ t: "  }" }],
        [{ t: "})!" }],
      ]} />

      <Callout kind="success" title="Verified live">
        <p style={{ margin: 0 }}>Every BiDi feature listed is verified against headless Edge. Capability probing via {C('status()')} / {C('supports()')} lets your scripts adapt to what a given driver actually implements.</p>
      </Callout>

      <h2 id="contexts" style={dpStyles.h2}>Isolated user contexts</h2>
      <p style={dpStyles.p}>Equivalent to Playwright's {C('browser.newContext()')}. Per-context proxy, geolocation, permissions, and storageState session reuse.</p>
    </article>
  );
}

// ───────── PAGE: Comparison ─────────
function PageComparison() {
  return (
    <article style={dpStyles.page}>
      <div style={dpStyles.breadcrumb}>Reference <span style={{ margin: "0 6px", color: "var(--fg-4)" }}>/</span> <span style={dpStyles.breadcrumb_b}>Comparison</span></div>
      <h1 id="comparison" style={dpStyles.h1}>Comparison <span className="emoji" style={{ fontSize: 26 }}>🎯</span></h1>
      <p style={dpStyles.lede}>Vebidor sits between Selenium (peer) and Playwright (newer generation). This is where it lands feature-for-feature.</p>

      <h2 id="vs-playwright" style={dpStyles.h2}>vs Playwright</h2>
      <ComparisonTable
        columns={[
          { label: "Feature", width: "38%" },
          { label: "Vebidor", width: "16%" },
          { label: "Playwright", width: "14%" },
          { label: "Notes" },
        ]}
        rows={[
          ["Auto-waiting actions",                  { chip: "Built-in", kind: "success", em: "✅" }, { chip: "Yes", kind: "success", em: "✅" }, "visible + enabled + scrolled-into-view"],
          ["Web-first assertions",                  { chip: "Yes", kind: "success", em: "✅" }, { chip: "Yes", kind: "success", em: "✅" }, <span>polling, <code style={dpStyles.inlineCode}>.not()</code> / <code style={dpStyles.inlineCode}>.with_timeout()</code></span>],
          ["Network mocking",                       { chip: "BiDi", kind: "success", em: "✅" }, { chip: "Yes", kind: "success", em: "✅" }, "route / fulfill / abort / continue"],
          ["Standards-based transport",             { chip: "W3C", kind: "milestone", em: "🏆" }, { chip: "CDP", kind: "neutral", em: "" }, "talks to any conformant driver, incl. Safari"],
          ["Real touch-event dispatch",             { chip: "Protocol limit", kind: "warning", em: "⚠️" }, { chip: "Yes", kind: "success", em: "✅" }, "BiDi doesn't expose CDP touch"],
          ["Codegen recorder",                      { chip: "Deferred", kind: "neutral", em: "" }, { chip: "Yes", kind: "success", em: "✅" }, "high effort, low value"],
        ]}
      />

      <h2 id="phases" style={dpStyles.h2}>Phase history</h2>
      <p style={dpStyles.p}>Vebidor's release notes are organized around <strong>Phases</strong> — each one closes a specific gap relative to Selenium or Playwright.</p>
      <ul style={dpStyles.ul}>
        <li style={dpStyles.li}><strong>Phase 1–8</strong> — Selenium parity (element properties, alerts, page info, window mgmt, CSS, expected conditions, advanced actions, async/shadow). <span className="chip chip--milestone" style={{ marginLeft: 6 }}><span className="emoji">🏆</span> 100%</span></li>
        <li style={dpStyles.li}><strong>Phase 0–5 (Playwright)</strong> — transport seam, locators, launch(), BiDi transport, BiDi features, tooling. <span className="chip chip--success" style={{ marginLeft: 6 }}><span className="emoji">✅</span> shipped</span></li>
        <li style={dpStyles.li}><strong>v4.2.0</strong> — mobile-web emulation (device presets, viewport/UA/touch, locale/timezone). <span className="chip chip--info" style={{ marginLeft: 6 }}><span className="emoji">✨</span> new</span></li>
      </ul>
    </article>
  );
}

// ───────── PAGE: Mobile (preview) ─────────
function PageMobile() {
  return (
    <article style={dpStyles.page}>
      <div style={dpStyles.breadcrumb}>API reference <span style={{ margin: "0 6px", color: "var(--fg-4)" }}>/</span> <span style={dpStyles.breadcrumb_b}>Mobile (preview)</span></div>
      <h1 id="mobile" style={dpStyles.h1}>
        Mobile <span className="chip chip--info" style={{ verticalAlign: "middle", marginLeft: 10, fontSize: 11 }}>✨ Preview · not shipped</span>
      </h1>
      <p style={dpStyles.lede}>
        A proposed mobile backend that skips Appium entirely. Talk to <strong>WebDriverAgent</strong> on iOS and the <strong>UiAutomator2 server</strong> on Android over their native sockets — the same protocols Appium uses, minus the Node middleware.
      </p>

      <Callout kind="warning" title="Status: design sketch">
        <p style={{ margin: 0 }}>
          Nothing in this page is implemented yet. It's a concrete proposal for how a real-device mobile API could fit inside Vebidor without compromising the W3C-standards posture. Feedback welcome before code lands.
        </p>
      </Callout>

      <h2 id="speed-comes-from" style={dpStyles.h2}>Where speed actually comes from</h2>
      <p style={dpStyles.p}>
        Mobile test runners split into two tiers: <strong>in-process</strong> (test code runs inside the app's process and syncs with the runloop) and <strong>out-of-process</strong> (test code drives the device over a socket). In-process is fastest but locks you into the app's language. Vebidor's slot is the fastest-possible <em>out-of-process</em> tier.
      </p>
      <ComparisonTable
        columns={[
          { label: "Tool", width: "20%" },
          { label: "Tier", width: "20%" },
          { label: "Fast because…", width: "32%" },
          { label: "Cost" },
        ]}
        rows={[
          ["Espresso (Android)",  "In-process",     "Syncs with main looper + AsyncTask — zero polling",       "Must be the app · JVM · rebuild"],
          ["EarlGrey 2 (iOS)",    "In-process",     "XCUITest + RunLoop / dispatch_queue sync",                 "Swift/Obj-C · rebuild"],
          ["Detox (RN only)",     "In-process",     "Hooks RN's bridge / Hermes idle signals",                  "React Native only"],
          ["Maestro",             "Out-of-process", "Direct sockets to idb_companion + UiAutomator2",           "Less granular than full WebDriver"],
          ["Appium",              "Out-of-process", { chip: "Multi-hop", kind: "warning", em: "⚠️" },           "HTTP → Node → vendor → device"],
          [<strong>Vebidor mobile</strong>, <span className="chip chip--info" style={{ fontSize: 11 }}>✨ Proposed</span>, "Native V client → WDA / UiAutomator2 sockets, no Appium",  "Out-of-process · still can't beat in-process"],
        ]}
      />

      <h2 id="architecture" style={dpStyles.h2}>Architecture</h2>
      <p style={dpStyles.p}>
        One <code style={dpStyles.inlineCode}>vebidor.mobile</code> API surface, two backends. Each backend speaks its platform's automation protocol natively from V — no Appium server, no JSON-Wire-over-HTTP-over-Node hop.
      </p>

      <div style={archStyles.frame}>
        <svg viewBox="0 0 720 360" width="100%" style={{ maxWidth: 720, display: "block", margin: "0 auto" }} role="img" aria-label="Mobile backend architecture">
          <defs>
            <marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
              <path d="M0,0 L10,5 L0,10 z" fill="#475569" />
            </marker>
          </defs>

          {/* Tier label: code */}
          <text x="20" y="32" fontFamily="Geist, sans-serif" fontSize="11" fontWeight="600" fill="#94A3B8" letterSpacing="0.06em">USER CODE</text>
          {/* User code box */}
          <rect x="180" y="14" width="360" height="46" rx="8" fill="#0B1220" stroke="#1E293B"/>
          <text x="360" y="42" textAnchor="middle" fontFamily="JetBrains Mono, monospace" fontSize="13" fill="#C0CAF5">
            <tspan fill="#7AA2F7">b</tspan>
            <tspan>.</tspan>
            <tspan fill="#E0AF68">mobile</tspan>
            <tspan>.</tspan>
            <tspan fill="#E0AF68">tap</tspan>
            <tspan>(</tspan>
            <tspan fill="#E0AF68">by_text</tspan>
            <tspan>(</tspan>
            <tspan fill="#9ECE6A">'Sign in'</tspan>
            <tspan>))!</tspan>
          </text>
          {/* arrow down */}
          <line x1="360" y1="60" x2="360" y2="92" stroke="#475569" strokeWidth="1.5" markerEnd="url(#arr)"/>

          {/* Tier label: vebidor */}
          <text x="20" y="118" fontFamily="Geist, sans-serif" fontSize="11" fontWeight="600" fill="#94A3B8" letterSpacing="0.06em">VEBIDOR</text>
          {/* Vebidor box */}
          <rect x="180" y="98" width="360" height="60" rx="10" fill="#EEF3FF" stroke="#3E63DD" strokeWidth="1.5"/>
          <text x="360" y="122" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="14" fontWeight="600" fill="#1E3A8A">vebidor.mobile</text>
          <text x="360" y="142" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="11.5" fill="#475569">one API · auto-waiting locators · batched flows</text>

          {/* fork lines */}
          <line x1="280" y1="158" x2="200" y2="200" stroke="#475569" strokeWidth="1.5" markerEnd="url(#arr)"/>
          <line x1="440" y1="158" x2="520" y2="200" stroke="#475569" strokeWidth="1.5" markerEnd="url(#arr)"/>

          {/* Tier label: backends */}
          <text x="20" y="226" fontFamily="Geist, sans-serif" fontSize="11" fontWeight="600" fill="#94A3B8" letterSpacing="0.06em">BACKENDS</text>

          {/* iOS box */}
          <rect x="60" y="208" width="280" height="58" rx="10" fill="#FFFFFF" stroke="#CBD5E1"/>
          <text x="200" y="231" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="14" fontWeight="600" fill="#0F172A">iOS · WebDriverAgent</text>
          <text x="200" y="250" textAnchor="middle" fontFamily="JetBrains Mono, monospace" fontSize="11" fill="#64748B">TCP / JSON Wire via idb · go-ios</text>

          {/* Android box */}
          <rect x="380" y="208" width="280" height="58" rx="10" fill="#FFFFFF" stroke="#CBD5E1"/>
          <text x="520" y="231" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="14" fontWeight="600" fill="#0F172A">Android · UiAutomator2</text>
          <text x="520" y="250" textAnchor="middle" fontFamily="JetBrains Mono, monospace" fontSize="11" fill="#64748B">TCP / proto via adb forward</text>

          {/* arrows to devices */}
          <line x1="200" y1="266" x2="200" y2="298" stroke="#475569" strokeWidth="1.5" markerEnd="url(#arr)"/>
          <line x1="520" y1="266" x2="520" y2="298" stroke="#475569" strokeWidth="1.5" markerEnd="url(#arr)"/>

          {/* Tier label: devices */}
          <text x="20" y="324" fontFamily="Geist, sans-serif" fontSize="11" fontWeight="600" fill="#94A3B8" letterSpacing="0.06em">DEVICES</text>

          {/* iOS device pills */}
          <rect x="80" y="304" width="110" height="32" rx="16" fill="#F1F5F9" stroke="#CBD5E1"/>
          <text x="135" y="324" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="12" fill="#334155">real iPhone</text>
          <rect x="210" y="304" width="110" height="32" rx="16" fill="#F1F5F9" stroke="#CBD5E1"/>
          <text x="265" y="324" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="12" fill="#334155">simulator</text>

          {/* Android device pills */}
          <rect x="400" y="304" width="110" height="32" rx="16" fill="#F1F5F9" stroke="#CBD5E1"/>
          <text x="455" y="324" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="12" fill="#334155">real Pixel</text>
          <rect x="530" y="304" width="110" height="32" rx="16" fill="#F1F5F9" stroke="#CBD5E1"/>
          <text x="585" y="324" textAnchor="middle" fontFamily="Geist, sans-serif" fontSize="12" fill="#334155">emulator</text>
        </svg>
      </div>

      <h2 id="example" style={dpStyles.h2}>What it would look like</h2>
      <p style={dpStyles.p}>
        Same lazy auto-waiting locator pattern as the web API. <code style={dpStyles.inlineCode}>launch_ios()</code> handles WDA install + port-forward; you get a session and a familiar <code style={dpStyles.inlineCode}>Locator</code> with platform-aware selectors.
      </p>
      <CodeBlock lang="vlang" filename="example_mobile.v" lines={[
        [{ t: "import", k: "keyword" }, { t: " vebidor.mobile" }],
        [{ t: "" }],
        [{ t: "fn", k: "keyword" }, { t: " " }, { t: "main", k: "function" }, { t: "() {" }],
        [{ t: "  mut", k: "keyword" }, { t: " b := mobile." }, { t: "launch_ios", k: "function" }, { t: "(mobile." }, { t: "iOSOptions", k: "type" }, { t: "{" }],
        [{ t: "    udid:        " }, { t: "'00008110-001A1D2E0E80801E'", k: "string" }],
        [{ t: "    bundle_id:   " }, { t: "'com.foo.MyApp'", k: "string" }],
        [{ t: "    install_app: " }, { t: "true", k: "keyword" }],
        [{ t: "  })!" }],
        [{ t: "  defer", k: "keyword" }, { t: " { b." }, { t: "close", k: "function" }, { t: "() }" }],
        [{ t: "" }],
        [{ t: "  ", k: null }, { t: "// auto-waiting locator — same as web", k: "comment" }],
        [{ t: "  b." }, { t: "get_by_label", k: "function" }, { t: "(" }, { t: "'Sign in'", k: "string" }, { t: ")." }, { t: "tap", k: "function" }, { t: "()!" }],
        [{ t: "  b." }, { t: "get_by_label", k: "function" }, { t: "(" }, { t: "'Email'", k: "string" }, { t: ")." }, { t: "fill", k: "function" }, { t: "(" }, { t: "'me@example.com'", k: "string" }, { t: ")!" }],
        [{ t: "" }],
        [{ t: "  ", k: null }, { t: "// Maestro-style batched flow → ONE round trip", k: "comment" }],
        [{ t: "  b." }, { t: "flow", k: "function" }, { t: "([" }],
        [{ t: "    .tap_text(" }, { t: "'Continue'", k: "string" }, { t: ")," }],
        [{ t: "    .assert_visible(" }, { t: "'Welcome back'", k: "string" }, { t: "),", k: null }],
        [{ t: "  ])!" }],
        [{ t: "}" }],
      ]} />

      <h2 id="speed-targets" style={dpStyles.h2}>Speed targets</h2>
      <p style={dpStyles.p}>
        Projected, not measured. The "fastest" column stays out of reach — Espresso runs inside the app process and Vebidor can't.
      </p>
      <ComparisonTable
        columns={[
          { label: "Operation", width: "32%" },
          { label: "Appium", width: "18%" },
          { label: "Maestro", width: "18%" },
          { label: "Vebidor mobile (proj.)", width: "20%" },
          { label: "In-process (Espresso)" },
        ]}
        rows={[
          ["Single tap command",      "100–300 ms", "30–80 ms",    { chip: "15–40 ms",   kind: "success", em: "✨" }, "1–5 ms"],
          ["Session start (real)",    "15–60 s",    "5–15 s",      { chip: "3–10 s",     kind: "success", em: "✨" }, "n/a (already in app)"],
          ["Batched flow · 10 steps", "1–3 s",      "300–800 ms",  { chip: "100–300 ms", kind: "success", em: "✨" }, "10–30 ms"],
        ]}
      />

      <Callout kind="milestone" title="The honest framing">
        <p style={{ margin: 0 }}>
          Out-of-process, the win comes from <strong>removing the Node hop</strong> and <strong>batching at the protocol layer</strong>. V's overhead is below Node's, but the latency floor is still set by USB / WiFi to the device. In-process tooling will always win raw command speed; Vebidor's claim is "the fastest universal out-of-process mobile runner."
        </p>
      </Callout>

      <h2 id="mvp" style={dpStyles.h2}>MVP plan</h2>
      <ol style={{ ...dpStyles.ul, paddingLeft: 24 }}>
        <li style={dpStyles.li}><strong>vebidor/mobile/wda.v</strong> — V client for WebDriverAgent's JSON Wire endpoints (~500 LOC, reuses existing <code style={dpStyles.inlineCode}>HttpTransport</code>).</li>
        <li style={dpStyles.li}><strong>vebidor/mobile/uia2.v</strong> — V client for UiAutomator2 server (~600 LOC).</li>
        <li style={dpStyles.li}><strong>vebidor/mobile/locators.v</strong> — predicate / accessibility-id / text locators with the same lazy auto-waiting semantics as web.</li>
        <li style={dpStyles.li}><strong>vebidor/mobile/bridges.v</strong> — wrap <code style={dpStyles.inlineCode}>idb</code>/<code style={dpStyles.inlineCode}>go-ios</code>/<code style={dpStyles.inlineCode}>adb</code> lifecycle behind a <code style={dpStyles.inlineCode}>launch()</code>-style API.</li>
        <li style={dpStyles.li}><strong>examples/example_mobile.v</strong> — install, launch, tap, assert, on a real iPhone. Proof of life.</li>
      </ol>

      <h2 id="skip" style={dpStyles.h2}>Out of scope</h2>
      <ul style={dpStyles.ul}>
        <li style={dpStyles.li}><strong>In-process V on iOS/Android.</strong> V compiles to ARM and can link as a <code style={dpStyles.inlineCode}>.dylib</code>/<code style={dpStyles.inlineCode}>.so</code>, but everything useful (UIKit, AndroidX) sits behind a Swift/Kotlin FFI boundary that erases the in-process speed advantage. Use XCTest/Espresso natively if you need that tier.</li>
        <li style={dpStyles.li}><strong>Beating Detox on React Native.</strong> Detox understands RN's bridge and Hermes idle signals. Reproducing that in V means tracking React Native's release cadence forever. Not worth it.</li>
        <li style={dpStyles.li}><strong>Native app element trees beyond what WDA/UiAutomator2 expose.</strong> Vebidor's reach stops where its backend's reach stops — no private API spelunking.</li>
      </ul>
    </article>
  );
}

const archStyles = {
  frame: {
    border: "1px solid var(--border-1)",
    borderRadius: "var(--radius-lg)",
    background: "var(--surface-0)",
    padding: 20,
    margin: "20px 0",
  },
};

const PAGES_DATA = {
  "quick-start": { component: PageQuickStart, toc: [
    { id: "quick-start", label: "Quick start", depth: 1 },
    { id: "install", label: "Install", depth: 2 },
    { id: "first-script", label: "Your first script", depth: 2 },
    { id: "run", label: "Run it", depth: 2 },
    { id: "next", label: "Next steps", depth: 2 },
  ]},
  "modern-api": { component: PageModernApi, toc: [
    { id: "modern-api", label: "Modern API", depth: 1 },
    { id: "locators", label: "Locators", depth: 2 },
    { id: "actions", label: "Auto-waiting actions", depth: 2 },
    { id: "assertions", label: "Web-first assertions", depth: 2 },
  ]},
  "bidi": { component: PageBiDi, toc: [
    { id: "bidi", label: "WebDriver-BiDi", depth: 1 },
    { id: "network-mocking", label: "Network mocking", depth: 2 },
    { id: "contexts", label: "Isolated contexts", depth: 2 },
  ]},
  "mobile": { component: PageMobile, toc: [
    { id: "mobile", label: "Mobile (preview)", depth: 1 },
    { id: "speed-comes-from", label: "Where speed comes from", depth: 2 },
    { id: "architecture", label: "Architecture", depth: 2 },
    { id: "example", label: "What it would look like", depth: 2 },
    { id: "speed-targets", label: "Speed targets", depth: 2 },
    { id: "mvp", label: "MVP plan", depth: 2 },
    { id: "skip", label: "Out of scope", depth: 2 },
  ]},
  "comparison": { component: PageComparison, toc: [
    { id: "comparison", label: "Comparison", depth: 1 },
    { id: "vs-playwright", label: "vs Playwright", depth: 2 },
    { id: "phases", label: "Phase history", depth: 2 },
  ]},
};

function DocsPage({ pageId, onNavigate }) {
  const data = PAGES_DATA[pageId] || PAGES_DATA["quick-start"];
  const Page = data.component;
  return <Page onNavigate={onNavigate} />;
}

window.DocsPage = DocsPage;
window.DOCS_PAGES_TOC = (id) => (PAGES_DATA[id] || PAGES_DATA["quick-start"]).toc;

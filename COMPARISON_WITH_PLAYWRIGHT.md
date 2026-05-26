# Vebidor vs Playwright - Comparison & Status

## Overview

This document compares Vebidor with [Playwright](https://playwright.dev/). Where the
Selenium comparison ([COMPARISON_WITH_SELENIUM.md](COMPARISON_WITH_SELENIUM.md)) measures
vebidor against a *peer* (another WebDriver-Classic client), this document measures it
against a *newer generation* of automation tooling.

**Status: the Playwright-parity roadmap (Phases 0–5) is implemented**, plus a follow-up
pass that brings the WebDriver-BiDi coverage ahead of Selenium's. Every feature below was
verified live against headless Edge.

Vebidor now runs on **two coexisting transports**:

- **WebDriver Classic** — one HTTP round-trip per command to an external driver
  (msedgedriver, chromedriver, geckodriver). See [`webdriver/client.v`](webdriver/client.v).
- **WebDriver-BiDi** — the W3C bidirectional protocol over a persistent WebSocket,
  unlocking events, network interception, and isolated contexts. See
  [`webdriver/bidi.v`](webdriver/bidi.v).

Both share one session (created with `webSocketUrl: true`): use Classic for the command
surface and BiDi for the event-driven features. Playwright achieves the same via CDP
(Chromium-only); vebidor stays on a cross-browser **W3C standard**.

---

## Feature comparison

### Ergonomics (WebDriver Classic layer) — implemented

| Feature | Vebidor | Playwright | Notes |
|---------|---------|------------|-------|
| Auto-waiting / actionability | ✅ Built into Locator actions | ✅ | [`locator.v`](webdriver/locator.v) — visible + enabled + scrolled-into-view |
| Web-first retrying assertions | ✅ `expect(loc).to_be_visible()` | ✅ | [`assertions.v`](webdriver/assertions.v), with `.not()` / `.with_timeout()` |
| Rich selectors (role/text/test-id) | ✅ `get_by_role/text/label/placeholder/test_id` | ✅ | [`selectors.v`](webdriver/selectors.v) |
| Locator abstraction (lazy, chainable) | ✅ `Locator` + `nth`/`first` | ✅ | [`locator.v`](webdriver/locator.v) — re-resolves, staleness-immune |
| Auto-managed browsers / drivers | ✅ `launch()` / `launch_edge()` | ✅ `browserType.launch()` | [`launcher.v`](webdriver/launcher.v) — detect driver+browser, free port, teardown |
| Screenshot-on-failure | ✅ `Browser.run_or_screenshot` | ✅ | [`fixtures.v`](webdriver/fixtures.v) |

### Bidirectional capabilities (WebDriver-BiDi layer) — implemented

| Feature | Vebidor | Playwright | Notes |
|---------|---------|------------|-------|
| Network interception / mocking | ✅ `route` + `continue_request`/`abort`/`fulfill` | ✅ | [`bidi_network.v`](webdriver/bidi_network.v) |
| Response-phase interception | ✅ `route_response` + `InterceptedResponse` | ✅ | request- and response-phase |
| HTTP auth handling | ✅ `on_auth(user, pass)` | ✅ | `continueWithAuth` |
| Console / network event listeners | ✅ `on_log` / `on_request` / `on_response` | ✅ | [`bidi_modules.v`](webdriver/bidi_modules.v), [`bidi_network.v`](webdriver/bidi_network.v) |
| Event-driven waits (no polling) | ✅ `wait_for_event` | ✅ | [`bidi.v`](webdriver/bidi.v) |
| Isolated browser contexts | ✅ `create_user_context` / `create_context` | ✅ `browser.newContext()` | [`bidi_context.v`](webdriver/bidi_context.v) |
| Per-context proxy / geolocation / permissions | ✅ `create_user_context(proxy_type: …)`, `set_geolocation`, `set_permission` | ✅ | driver-dependent; probe with `supports()` |
| storageState (session reuse) | ✅ `storage_state` / `apply_storage_state` | ✅ `storageState` | cookies (localStorage via `evaluate`) |
| Capability probing | ✅ `status()` / `supports()` | n/a (owns impl) | feature-detect optional BiDi modules |
| Preload / init scripts | ✅ `add_preload_script` | ✅ `addInitScript` | [`bidi_script.v`](webdriver/bidi_script.v) |
| Viewport / DPR emulation | ✅ `set_viewport` / `set_device_pixel_ratio` | ✅ | [`bidi_context.v`](webdriver/bidi_context.v) |
| File upload | ✅ `locate_node` + `set_files` | ✅ `setInputFiles` | [`bidi_dom.v`](webdriver/bidi_dom.v) |
| Cookies + change events | ✅ `get/set/delete_cookies` + `on_cookie_changed` | ✅ | [`bidi_storage.v`](webdriver/bidi_storage.v) |
| Screenshots / PDF | ✅ `capture_screenshot` / `save_pdf` | ✅ | [`bidi_screenshot.v`](webdriver/bidi_screenshot.v), [`bidi_context.v`](webdriver/bidi_context.v) |
| Tracing | ✅ `Tracer` (console+network → JSON) | ✅ Trace viewer | [`bidi_trace.v`](webdriver/bidi_trace.v) — log, not binary trace format |

### Where vebidor stays ahead

| Strength | Notes |
|----------|-------|
| Native V API | Playwright has no V binding; vebidor is the only real option in V. |
| Standards-based | W3C WebDriver + WebDriver-BiDi, so it talks to any conformant driver — including Safari's `safaridriver` — not a Chromium-only protocol. |
| Dependency-light | No bundled Chromium download, no Node runtime. Compiles to a native V binary. |
| Generic BiDi escape hatch | `send(method, params)` / `on(event)` reach *any* BiDi command/event, even unwrapped. |
| Capability probing | `status()` / `supports(method, params)` feature-detect optional BiDi modules, so scripts adapt to what a given browser's BiDi actually implements rather than assuming uniform conformance. |

### Genuinely not implemented (deferred)

| Feature | Why deferred |
|---------|--------------|
| Real video capture | No standardized BiDi screencast yet; would need periodic screenshots + ffmpeg. The screenshot/PDF primitives are the building blocks. |
| Codegen recorder | High effort, low automation value. |

---

## Quick API map (Playwright → vebidor)

| Playwright | Vebidor |
|------------|---------|
| `chromium.launch()` | `webdriver.launch_edge(LaunchOptions{ headless: true })` |
| `page.goto(url)` | `b.goto(url)` |
| `page.getByRole('button', { name })` | `b.wd.get_by_role('button', name)` |
| `locator.click()` / `.fill()` | `loc.click()` / `loc.fill()` (auto-waiting) |
| `expect(locator).toBeVisible()` | `webdriver.expect(loc).to_be_visible()` |
| `page.route(url, fulfill)` | `bidi.route(fn (req) { req.fulfill(...) })` |
| `page.addInitScript(js)` | `bidi.add_preload_script(js)` |
| `browser.newContext()` | `bidi.create_user_context()` + `bidi.create_context(uc)` |
| `locator.setInputFiles(path)` | `bidi.set_files(ctx, bidi.locate_node(...), [path])` |
| `page.on('console')` | `bidi.on_log(fn (e) { ... })` |

---

## Implementation log (Phases 0–5, all shipped)

- **Phase 0 — Transport seam.** `Transport` interface + `Response`; `HttpTransport`
  wraps Classic. Lets Classic and BiDi coexist behind one `WebDriver`.
  ([`client.v`](webdriver/client.v))
- **Phase 1 — Classic ergonomics.** Lazy auto-waiting `Locator`, `get_by_*` selector
  engines, web-first `expect` assertions.
  ([`locator.v`](webdriver/locator.v), [`selectors.v`](webdriver/selectors.v), [`assertions.v`](webdriver/assertions.v))
- **Phase 2 — Lifecycle.** `launch()` detects driver+browser, picks a free port,
  health-checks `/status`, and tears down. ([`launcher.v`](webdriver/launcher.v))
- **Phase 3 — BiDi transport.** WebSocket client with id-correlated commands and a
  threaded event loop; `browsingContext`/`script`/`log` modules.
  ([`bidi.v`](webdriver/bidi.v), [`bidi_modules.v`](webdriver/bidi_modules.v))
- **Phase 4 — BiDi features.** Network interception/mocking, observation, isolated
  contexts, event-driven waits. ([`bidi_network.v`](webdriver/bidi_network.v), [`bidi_context.v`](webdriver/bidi_context.v))
- **Phase 5 — Tooling.** Tracer, BiDi screenshots, `v test` fixtures (and a fix making
  the W3C screenshot endpoints use GET).
  ([`bidi_trace.v`](webdriver/bidi_trace.v), [`bidi_screenshot.v`](webdriver/bidi_screenshot.v), [`fixtures.v`](webdriver/fixtures.v))
- **BiDi gap closure (vs Selenium).** Preload scripts + `call_function`, network auth,
  response-phase interception, viewport emulation, BiDi cookies + `cookieChanged`,
  node handles + `set_files`, and `browsingContext` extras
  (print/traverse/activate/handleUserPrompt).
  ([`bidi_script.v`](webdriver/bidi_script.v), [`bidi_storage.v`](webdriver/bidi_storage.v), [`bidi_dom.v`](webdriver/bidi_dom.v))

---

## Mobile emulation roadmap (in progress)

Playwright's "mobile" is **device emulation** (device descriptors: viewport, UA,
device-scale-factor, `isMobile`, `hasTouch`, touch input) — not real-device automation
(that's Appium). vebidor is matching the emulation side over BiDi. Fidelity is best on
Chromium-based drivers (Edge/Chrome); each `emulation.*` call is gated by `supports()`.

| Gap | Mechanism | Status |
|-----|-----------|--------|
| viewport + device-scale-factor | `set_viewport` / `set_device_pixel_ratio` | ✅ done |
| **Device descriptor + `emulate()`** | `Device{…}` + `bidi.emulate(ctx, device)` ([`emulation.v`](webdriver/emulation.v)) | ✅ **M1 done** (viewport + DPR) |
| user-agent (real request header) | BiDi UA override if supported, else rewrite `User-Agent` via network interception; + preload script for JS-visible `navigator.userAgent` | ⏳ M2 |
| `isMobile` / `hasTouch` JS flags | `add_preload_script` (maxTouchPoints, ontouchstart, mobile hints) | ⏳ M2 |
| touch input / `tap()` | Actions `pointerType:"touch"` + `Locator.tap()` ([`actions.v`](webdriver/actions.v), [`locator.v`](webdriver/locator.v)) | ✅ **M3 done** (tap gesture; touch *events* need M2 hasTouch) |
| device presets (`iPhone`, `Pixel`, …) | curated `devices` catalog + `emulate_device(name)` | ⏳ M4 |
| locale / timezone / orientation | `emulation.set*Override` (probe-gated) | ⏳ M5 |

**Out of scope:** real native devices / Appium (UiAutomator2/XCUITest) — a different
protocol surface, and not what Playwright does either.

Sequencing: M1 → M3 → M2 → M4 → M5 (viewport + tap first for the visible mobile feel; UA
last as it's the most driver-dependent).

---

## Summary

Vebidor now offers Playwright-style ergonomics (one-call launch, lazy auto-waiting
locators, semantic selectors, web-first assertions, route/fulfill mocking) **and**
standards-based WebDriver-BiDi coverage that meets or exceeds Selenium's — on a native V
API, with no Node runtime or bundled browser download. The remaining Playwright-only items
(binary trace viewer, video, codegen) are non-standard conveniences rather than capability
gaps.

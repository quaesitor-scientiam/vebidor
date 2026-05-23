# Vebidor vs Playwright - Comparison & Roadmap

## Overview

This document compares Vebidor with [Playwright](https://playwright.dev/) and lays out a
staged roadmap for closing the gap. Where the Selenium comparison
([COMPARISON_WITH_SELENIUM.md](COMPARISON_WITH_SELENIUM.md)) measures vebidor against a
*peer* (another WebDriver-Classic client), this document measures it against a
*newer generation* of automation tooling.

Vebidor and Playwright sit in different categories:

- **Vebidor** is a **WebDriver-Classic** client. Every command is a single HTTP
  round-trip to an external driver process (msedgedriver, chromedriver, geckodriver),
  which forwards to the browser. See [`webdriver/client.v`](webdriver/client.v).
- **Playwright** is a **protocol-native** framework. It speaks the browser's own
  bidirectional protocol (CDP for Chromium, patched protocols for Firefox/WebKit) over a
  persistent WebSocket, and ships its own browser builds.

Almost every difference below traces back to that one architectural split.

---

## The core architectural fork

Playwright's headline capabilities — network interception, reliable auto-waiting,
isolated contexts, tracing — all depend on a **persistent, bidirectional connection** to
the browser. WebDriver Classic is request/response only: the client cannot subscribe to
events, intercept network traffic, or stream logs.

This divides the gaps into two buckets:

1. **Ergonomics gaps** — solvable on WebDriver Classic *today*, with no protocol change.
   Auto-waiting, rich selectors, retrying assertions, browser lifecycle management.
2. **Capability gaps** — genuinely require a bidirectional protocol. The
   standards-aligned answer (and the one consistent with vebidor's "W3C-conformant"
   identity) is **WebDriver-BiDi** — the WebSocket-based W3C specification now shipping in
   Chrome, Edge, and Firefox. (Raw CDP would also work but is Chromium-only and would
   abandon cross-browser support.)

The roadmap harvests the ergonomic wins on Classic first, then adds a BiDi transport for
the features that are otherwise impossible.

---

## Feature comparison

### Solvable on WebDriver Classic (ergonomics)

| Feature | Vebidor today | Playwright | Path |
|---------|---------------|------------|------|
| Auto-waiting / actionability | ⚠️ Manual `wait_*` helpers ([`expected_conditions.v`](webdriver/expected_conditions.v)) | ✅ Built into every action | Classic |
| Web-first retrying assertions | ❌ None | ✅ `expect(locator).toBeVisible()` | Classic |
| Rich selectors (role/text/test-id) | ⚠️ `find_element(using, value)` only | ✅ `getByRole`, `getByText`, `getByTestId`, … | Classic |
| Locator abstraction (lazy, chainable) | ❌ Eager `ElementRef` | ✅ Lazy `Locator` | Classic |
| Frame-piercing locators | ⚠️ Manual `switch_to_frame` | ✅ `frameLocator` | Classic |
| Auto-managed browsers / drivers | ❌ Manual "start chromedriver on 9515" | ✅ `browserType.launch()` | Classic |
| Screenshot-on-failure | ⚠️ Manual screenshots ([`screenshot.v`](webdriver/screenshot.v)) | ✅ Automatic | Classic |

### Require a bidirectional protocol (WebDriver-BiDi)

| Feature | Vebidor today | Playwright | Path |
|---------|---------------|------------|------|
| Network interception / mocking | ❌ (Edge throttling only) | ✅ `route` / `fulfill` / `abort` | **BiDi** |
| Console / page event listeners | ❌ None | ✅ `page.on('console')` etc. | **BiDi** |
| Request / response inspection | ❌ None | ✅ Full request/response objects | **BiDi** |
| Isolated browser contexts | ❌ One session = one context | ✅ Cheap `browser.newContext()` | **BiDi** |
| Event-driven waits (no polling) | ❌ Polling only | ✅ Event-driven | **BiDi** |
| Tracing / video | ⚠️ Screenshots only | ✅ Trace viewer + video | **BiDi** |
| Codegen recorder | ❌ None | ✅ `playwright codegen` | Tooling |

### Where vebidor stays ahead

| Strength | Notes |
|----------|-------|
| Native V API | Playwright has no V binding; vebidor is the only real option in V. |
| Standards-based | Speaks W3C WebDriver, so it talks to any conformant driver — including Safari's built-in `safaridriver`. |
| Dependency-light | No bundled Chromium download, no Node runtime. Compiles to a native V binary. |

---

## Roadmap

### Phase 0 — Transport seam (refactor)

`wd_do` is a free function and all commands hang off the `WebDriver` struct
([`client.v:28`](webdriver/client.v)). Extract a transport abstraction so
Classic-HTTP and BiDi-WebSocket transports can coexist behind one driver type.

- Define a transport interface (send command / await response).
- Move HTTP logic behind it; keep current behavior identical.
- Low risk; unblocks every later phase.

### Phase 1 — Classic ergonomics layer (highest ROI, ship first)

Makes vebidor *feel* like Playwright for the majority of scripting, with no protocol
change.

- **`Locator` type** — lazy selector with chaining; re-resolves on each use rather than
  capturing a stale `ElementRef`.
- **Auto-waiting actions** — `click` / `fill` / etc. inject an actionability check
  (visible, stable, enabled, hit-testable) and retry until the configured timeout,
  superseding the manual `wait_until_clickable` pattern.
- **Selector engines** — `get_by_role`, `get_by_text`, `get_by_test_id`,
  `get_by_label`, `get_by_placeholder`, implemented as injected JS / XPath translation.
- **Web-first assertions** — `expect(locator).to_be_visible()` style, with built-in retry.

### Phase 2 — Browser / driver lifecycle

A `launch()` that auto-detects (or downloads) the matching driver + browser, starts it on
a free port, and tears it down — eliminating the manual setup documented in the README.
Cross-platform (Windows / macOS / Linux).

### Phase 3 — WebDriver-BiDi transport

V provides `net.websocket` in vlib.

- Request `webSocketUrl: true` in capabilities ([`capabiities.v`](webdriver/capabiities.v)).
- Build the JSON command/response correlator plus an event-dispatch loop.
- Implement core modules: `session`, `browsingContext`, `script`, `log`.

### Phase 4 — BiDi-powered features

- Network interception / mocking (`network` module).
- Console & request/response event listeners.
- Isolated user contexts (independent cookies/storage in one browser).
- Event-driven waits replacing Phase 1's polling.

### Phase 5 — Tooling

- Screencast video + tracing via BiDi events.
- Optional codegen recorder.
- V test-runner (`v test`) fixtures and helpers.

---

## Summary

Phases 1–2 close the **ergonomics** gap on the existing WebDriver-Classic foundation and
deliver the largest felt improvement fastest. Phases 3–4 close the **capability** gap
(network control, events, isolated contexts) while keeping vebidor on a W3C standard
rather than a Chromium-only protocol. Phase 5 adds the surrounding tooling.

This sequencing front-loads value: vebidor scripts start looking and behaving like
Playwright after Phase 1, long before the heavier BiDi work lands.

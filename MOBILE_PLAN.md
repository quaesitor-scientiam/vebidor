# Vebidor Mobile — Implementation Plan

> Status: planning. Mob-1 (foundations) is the first commit; the rest follow.
> Live design sketch: <https://quaesitor-scientiam.github.io/vebidor/ui_kits/docs/index.html#mobile>

A native V client for WebDriverAgent (iOS) and the UiAutomator2 server (Android),
talked to directly over their existing HTTP sockets — same protocols Appium uses,
minus the Node middleware. Out-of-process, W3C-aligned, fits as a sibling module
to `vebidor.webdriver`.

---

## Architectural fit

Mobile reuses ~60% of vebidor's existing infrastructure:

| Existing piece | Mobile reuse | Adjustment |
|---|---|---|
| `Transport` interface + `HttpTransport` (`webdriver/client.v`) | WDA and UiA2 both speak HTTP JSON. Point an `HttpTransport` at `http://127.0.0.1:8100` (WDA) or `http://127.0.0.1:6790` (UiA2). | Promote to its own file so `mobile/` can import without dragging Classic-WebDriver semantics. |
| `Locator` lazy auto-wait (`webdriver/locator.v`) | Same semantics: re-resolve on use, auto-wait actionability. Public API maps 1:1. | Extract the polling loop into `wait_helpers.v` so both `Locator` and `MobileLocator` use the same primitive. |
| Selector engines (`webdriver/selectors.v`) | `get_by_label`, `get_by_text`, `get_by_role`, `get_by_test_id` all have direct mobile equivalents. | New per-platform compiler functions; same public API. |
| `expect(loc).to_be_*` assertions (`webdriver/assertions.v`) | Polling / timeout / `.not()` / `.with_timeout()` are platform-agnostic. | Tiny refactor to share the polling helper. |
| Actions API + touch pointer (`webdriver/actions.v`, M3) | `pointerType:"touch"` is the mobile default; sequence builder reusable. | Add `tap`/`swipe`/`long_press`/`pinch` builders. |
| Launcher pattern (`webdriver/launcher.v`) | `launch_ios()` / `launch_android()` mirror `launch_edge()`'s shape: detect bridge tool, spawn, port-free, health-check, teardown. | Two new bridges; same RAII struct, renamed `MobileSession`. |
| Screenshot + fixtures (`webdriver/screenshot.v`, `webdriver/fixtures.v`) | Identical pattern. | One-line port. |

Net new code is WDA client, UiA2 client, two bridge modules, mobile selector
compilers, and mobile gestures. The plumbing (HTTP transport, polling, lazy
locators, assertions, lifecycle) reuses what already exists.

---

## Module structure

```
vebidor/
├── webdriver/                  ← unchanged public API (Edge/Chrome/Firefox/Safari)
│   ├── transport.v             ← NEW: extracted Transport + Response + HttpTransport
│   ├── wait_helpers.v          ← NEW: extracted polling loop (WaitOptions, poll_until_true)
│   └── … (existing files unchanged)
│
└── mobile/                     ← NEW MODULE: import vebidor.mobile
    ├── session.v               ← MobileSession (the Browser-equivalent)
    ├── launcher.v              ← launch_ios() / launch_android()
    ├── wda.v                   ← WebDriverAgent HTTP client
    ├── uia2.v                  ← UiAutomator2-server HTTP client
    ├── bridges_ios.v           ← go-ios / xcrun simctl lifecycle
    ├── bridges_android.v       ← adb / am instrument lifecycle
    ├── locator.v               ← MobileLocator (mirrors web Locator)
    ├── locators_ios.v          ← XCUITest predicate / class-chain compilers
    ├── locators_android.v      ← UIAutomator selector compilers
    ├── selectors.v             ← cross-platform get_by_* surface
    ├── actions.v               ← tap / swipe / long_press / pinch
    ├── assertions.v            ← mobile.expect() — shares polling helper
    ├── screenshot.v            ← MobileSession.save_screenshot
    └── app.v                   ← install_app / launch_app / terminate / background
```

**Why a sibling module, not files inside `webdriver/`:**

- Different mental model (devices, apps, gestures vs. browsers, windows, frames).
- Different defaults (touch is implicit, no mouse).
- Lets `webdriver` stay a clean W3C client; mobile evolves independently.
- Public API reads correctly: `import vebidor.mobile`.

`MobileSession` is its own struct (not a subclass of `WebDriver`). They share
`Transport` and the polling helpers; the command surfaces diverge enough that
forcing polymorphism would leak. Each module owns its locator type.

---

## Adjustments to the existing `webdriver` module

All non-breaking. Purely refactors that improve reuse.

1. **Extract `Transport` + `Response` + `HttpTransport` into `webdriver/transport.v`.**
   Today they live in `client.v` alongside `WebDriver`. Move them so `mobile/` can
   pick up the transport type without depending on browser-specific code.

2. **Extract polling loop into `webdriver/wait_helpers.v`.** Today
   `Locator.wait_for`, `Locator.wait_until_actionable`, and
   `LocatorAssertions.poll` each carry their own copy of the same loop. Add:

   ```v
   pub struct WaitOptions {
   pub:
       timeout_ms  int = default_timeout_ms
       interval_ms int = default_poll_ms
       describe    string
   }

   pub fn poll_until_true(opts WaitOptions, predicate fn () !bool) !
   ```

   Refactor `LocatorAssertions.poll` to delegate. (Locator's element-returning
   loops keep their inlined form for now — a generic `poll_until_ok[T]` lands
   in Mob-2 when `MobileLocator` actually needs it.)

3. **Locatable interface.** Deferred to Mob-2 — premature without
   `MobileLocator` to validate the shape against.

4. **No breaking changes to public API.** Existing users continue to call
   `webdriver.launch_edge` etc. unchanged. Mobile is purely additive.

---

## Phased implementation

Each phase shippable and demonstrable on its own, mirroring the M1–M5
mobile-emulation roadmap pattern.

### **Mob-1 — Foundations** ✅ shipped (`12481c4`)

- Refactors above (`transport.v`, `wait_helpers.v`).
- `mobile/` skeleton: `MobileSession`, `iOSOptions`, `AndroidOptions`,
  `launch_ios()` / `launch_android()` returning `error('not yet implemented')`.
- `examples/mobile/example_mob_phase1.v` — compiles, prints expected error.
- No external dependencies yet.
- **Validation:** existing webdriver builds + the example builds and errors as
  designed.

### **Mob-2 — iOS WDA client** ✅ first cut shipped; auto-launch deferred to Mob-2.1

End-to-end iOS Simulator driving on macOS.

> **First-cut status:** the wire client (`wda.v`), `MobileLocator` with
> auto-wait (`locator.v`), XCUITest selector factories (`wda_locators.v`),
> action surface (`actions.v`), screenshots (`screenshot.v`), and an iOS
> Settings smoke example (`examples/mobile/example_mob_ios.v`) are all in.
> The launcher connects to an **already-running** WDA — see `wda_bridge.v`
> for the launch instructions surfaced in errors. Auto-build/auto-launch
> via `xcodebuild test-without-building` (Sim) and `go-ios` (real device)
> lands as Mob-2.1.

- `mobile/wda.v` — WDA HTTP command wrappers: `/session`, `/element`,
  `/element/{}/click|value|clear|text`, `/element/{}/displayed|enabled`,
  `/source`, `/screenshot`, `/actions`.
- `mobile/bridges_ios.v` — Simulator-first:
  - Detect `xcrun simctl` (built into macOS).
  - Build WDA against the Simulator runtime (`xcodebuild test-without-building`),
    install the user app via `simctl install`, launch, the WDA server is
    already on `localhost:8100`.
  - For real device: detect `go-ios`, `ios install <wda.ipa>`,
    `ios runwda --udid`, `ios forward 8100`.
  - Graceful teardown (kill WDA, close session).
- `mobile/locator.v` — `MobileLocator` mirroring web `Locator` shape.
- `mobile/locators_ios.v` — XCUITest predicates: `by_accessibility_id`,
  `by_class_chain`, `by_predicate`, `by_xpath`.
- `mobile/actions.v` — `tap()`, `fill()`, `clear()`, `swipe_*()`,
  `long_press()` via the W3C actions endpoint.
- `mobile/screenshot.v` — `MobileSession.save_screenshot(path)`.
- `examples/mobile/example_mob_ios.v` — drives the iOS Simulator Calculator
  (preinstalled, accessibility-id'd buttons). Bit-identical in tone to the
  existing web examples.
- **Validation:** iOS Simulator on macOS. Free, fast, no signing required.

### **Mob-3 — Android UiAutomator2 client** (~2-3 weeks)

Symmetric to Mob-2, validated on the Android Emulator since the maintainer
lacks Android devices.

- `mobile/uia2.v` — UiAutomator2-server commands (wire shape is almost
  identical to WDA, mostly copy-and-adapt from `wda.v`).
- `mobile/bridges_android.v`:
  - Detect `adb` on PATH (or via `ANDROID_HOME`/`ANDROID_SDK_ROOT`).
  - Vendor pinned `appium-uiautomator2-server.apk` +
    `appium-uiautomator2-server-test.apk`.
  - `adb install -r <apk>`, `adb shell am instrument -w …`,
    `adb forward tcp:6790 tcp:6790`.
- `mobile/locators_android.v` — UIAutomator selectors: `text`,
  `text_contains`, `resource_id`, `content_desc`, `class_name`.
- `examples/mobile/example_mob_android.v` — same calculator-app idea against
  the AOSP Calculator on an emulator.
- **Validation:** Android Emulator from the SDK on macOS.

### **Mob-4 — Cross-platform selectors** (~1 week)

This is where the *vebidor* feel emerges — same V code drives both platforms.

- `mobile/selectors.v` — `get_by_label`, `get_by_test_id`, `get_by_text`,
  `get_by_role`, `locator(strategy, value)`.
- Internal dispatch on `s.platform`:
  - `get_by_label("Sign in")` →
    - iOS: predicate `label == 'Sign in' OR name == 'Sign in' OR value == 'Sign in'`
    - Android: prefer `content-desc == 'Sign in'`, fall back to `text == 'Sign in'`
  - `get_by_test_id("submit-btn")` →
    - iOS: predicate `name == 'submit-btn'` (accessibility identifier)
    - Android: `content-desc == 'submit-btn'`
  - `get_by_role(.button)` →
    - iOS: class chain `**/XCUIElementTypeButton`
    - Android: className `android.widget.Button`
- `examples/mobile/example_mob_cross.v` — same V source against iOS + Android.

### **Mob-5 — Assertions, scrolling, gestures** (~1 week)

- `mobile/assertions.v` — `mobile.expect(loc).to_be_visible/hidden/...` —
  delegates to `poll_until_true` from Mob-1.
- `swipe_to(loc)` (scroll-into-view, essential because mobile lists are tall),
  `pinch_in`/`pinch_out`, `drag_and_drop(from, to)`, `multi_touch`.
- Tracer integration mirroring `bidi_trace.v`.

### **Mob-6 — App management + device state** (~1 week)

- `install_app(path)`, `remove_app(bundle_id)`, `launch_app()`,
  `terminate_app()`, `background_app(seconds)`, `query_app_state() AppState`.
- `set_orientation(.portrait | .landscape)`, `lock()`, `unlock()`,
  `set_geolocation(lat, lng)`, `set_network_condition(...)`.

### **Mob-7 — Docs, release, comparison** (~1 week)

- Promote `PageMobile` from "Preview · not shipped" to a real page.
- `MOBILE_TESTING.md` (analog of `TESTING.md`): WDA prerequisites, signing,
  Simulator vs real device, emulator setup.
- `COMPARISON_WITH_APPIUM.md` — same wire, no Node, no hybrid-webview support
  yet.
- README mobile section; CHANGELOG entry for `v5.0.0` (major: new module).
- Mobile chip in the docs sidebar (stub exists at `#mobile`).

---

## Deliberately deferred from v1

- **Hybrid app webview driving** — WDA exposes Safari via WebKit Remote
  Inspector; UiA2 exposes WebViews via CDP-over-adb. Both are their own
  protocols and worth a full phase later.
- **iOS keyboard chaining / IME quirks** — `fill` on a `UITextField` works;
  complex IME flows (autocorrect, predictive text) need per-iOS-version polish.
- **Mobile-specific waits** — `wait_for_animation_settled`, `wait_for_idle`
  (Android `Looper` synchronization) are valuable but tricky.
- **Cross-platform `expect` chip-by-chip equivalence with web** — ship the
  ~80% surface; long-tail assertions follow.
- **CI** — full GitHub Actions matrix with both iOS Simulator + Android
  Emulator is a follow-up. Initial CI keeps the existing webdriver tests.

---

## Validation strategy

The maintainer is on **macOS** with **no Android devices**.

| Phase | Validatable locally |
|---|---|
| Mob-2 (iOS) | ✅ iOS Simulator on macOS, no signing |
| Mob-3 (Android) | ✅ Android Emulator via SDK |
| Mob-4 (cross-platform) | ✅ Simulator + Emulator side by side |
| Mob-5 (assertions/gestures) | ✅ |
| Mob-6 (app management) | ✅ App lifecycle works on Simulator/Emulator |
| iOS real device | ✅ when an iPhone is connected (signing on macOS) |
| Android real device | ⚠️ deferred to contributors or future device acquisition |

Simulator + Emulator cover ~95% of automation behavior. Real-device-only
quirks (real touch latency, real network, hardware sensors) are testable when
devices appear; development can complete without them.

---

## Open questions

1. **Vendored WDA binary** — ship a known-good signed `wda.ipa` in the repo,
   or require users to build their own?
2. **Vendored UiA2 APKs** — APKs don't need per-user signing, probably ship.
3. **Bridge tool requirement** — hard-require `go-ios` for iOS real-device
   (autoinstall via `brew` on macOS), or document the install step?
4. **`v5.0.0` vs `v4.3.0`** — a new module is conceptually major; leaning
   `v5.0.0`.

---

## LOC estimate

| Area | Estimate |
|---|---|
| `mobile/wda.v` | ~400 LOC |
| `mobile/uia2.v` | ~400 LOC |
| `mobile/locators_*.v` + `selectors.v` | ~600 LOC |
| `mobile/bridges_*.v` | ~700 LOC (process lifecycle is genuine work) |
| `mobile/session.v` | ~400 LOC |
| `mobile/actions.v` | ~200 LOC (reuses Actions API) |
| `mobile/assertions.v` | ~150 LOC |
| `mobile/screenshot.v`, `app.v`, etc. | ~600 LOC across 3-4 files |
| **Total** | **~3500 LOC across ~13 files** |

About 75% more than the roadmap page's `~2000 LOC` because process lifecycle
is the real work.

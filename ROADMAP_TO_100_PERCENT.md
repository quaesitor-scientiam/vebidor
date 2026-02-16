# Roadmap to 100% Feature Parity with Selenium

**Current Status**: v2.1.0 - 91% feature parity
**Target**: v3.0.0 - 100% feature parity
**Remaining**: 9% (~12-14 additional methods)

---

## 📊 Gap Analysis

### Current Coverage by Category

| Category | Current | Target | Gap |
|----------|---------|--------|-----|
| Element Properties | 64% (7/11) | 100% (11/11) | 4 methods |
| Element Interaction | 75% (3/4) | 100% (4/4) | 1 method |
| JavaScript | 67% (2/3) | 100% (3/3) | 1 method |
| Actions API | 80% (8/10) | 100% (10/10) | 2 methods |
| Waits & Expected Conditions | 100% (9/9) | 100% (9/9) | 0 methods ✅ |
| Timeouts | 100% (4/4) | 100% (4/4) | 0 methods ✅ |
| Shadow DOM | 0% (0/1) | 100% (1/1) | 1 method |
| Browser Logs | ~50% (1/2) | 100% (2/2) | 1 method |

**Total Missing**: ~12-14 methods

---

## 🎯 Implementation Phases (85% → 100%)

### Phase 5: Advanced Element Properties (MEDIUM PRIORITY)

**Impact**: Medium - Less common but useful
**Effort**: Low (1-2 days)
**Coverage Gain**: 64% → 73% (+9%)

#### 5.1 Get CSS Value
**W3C Endpoint**: `GET /session/{session id}/element/{element id}/css/{property name}`

```v
// File: webdriver/elements.v

pub fn (wd WebDriver) get_css_value(el ElementRef, property_name string) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/css/${property_name}')!
	return resp.value
}
```

**Use Case**: Get computed CSS styles (color, font-size, display, etc.)

#### 5.2 Get Element Size
**W3C Endpoint**: `GET /session/{session id}/element/{element id}/rect`

```v
// File: webdriver/elements.v

pub struct ElementSize {
pub:
	width  f64
	height f64
}

pub fn (wd WebDriver) get_element_size(el ElementRef) !ElementSize {
	rect := wd.get_element_rect(el)!
	return ElementSize{
		width: rect.width
		height: rect.height
	}
}
```

#### 5.3 Get Element Location
**W3C Endpoint**: `GET /session/{session id}/element/{element id}/rect`

```v
// File: webdriver/elements.v

pub struct ElementLocation {
pub:
	x f64
	y f64
}

pub fn (wd WebDriver) get_element_location(el ElementRef) !ElementLocation {
	rect := wd.get_element_rect(el)!
	return ElementLocation{
		x: rect.x
		y: rect.y
	}
}
```

#### 5.4 Get Element Rect (Unified)
**W3C Endpoint**: `GET /session/{session id}/element/{element id}/rect`

```v
// File: webdriver/elements.v

pub struct ElementRect {
pub:
	x      f64
	y      f64
	width  f64
	height f64
}

pub fn (wd WebDriver) get_element_rect(el ElementRef) !ElementRect {
	resp := wd.get_request[ElementRect]('/session/${wd.session_id}/element/${el.element_id}/rect')!
	return resp.value
}
```

**Methods Added**: 4
**Files**: `webdriver/elements.v` (modified)
**Tests**: `webdriver/element_properties_test.v` (add 4 tests)

---

### Phase 6: Expected Conditions & Advanced Waits ✅ COMPLETE

**Impact**: High - Very commonly used pattern
**Effort**: Medium (2-3 days)
**Coverage Gain**: 85% → 91% (+6%)
**Completion Date**: 2026-02-15

#### ✅ Implemented Methods

1. **`wait_until_clickable(using, value, timeout_ms)`** ✅
   - Waits for element to be both visible and enabled
   - File: `webdriver/expected_conditions.v`
   - Uses 500ms polling interval

2. **`wait_until_visible(using, value, timeout_ms)`** ✅
   - Waits for element to be visible on page
   - File: `webdriver/expected_conditions.v`
   - Combines find_element + is_displayed checks

3. **`wait_until_present(using, value, timeout_ms)`** ✅
   - Waits for element to exist in DOM (no visibility check)
   - File: `webdriver/expected_conditions.v`
   - Simplest wait - just element presence

4. **`wait_for_text_in_element(using, value, text, timeout_ms)`** ✅
   - Waits for element to contain specific text
   - File: `webdriver/expected_conditions.v`
   - Case-sensitive substring match

5. **`get_timeouts()`** ✅
   - Retrieve current timeout configuration
   - File: `webdriver/wait.v`
   - W3C Endpoint: `GET /session/{session id}/timeouts`
   - Returns Timeouts struct with optional fields

**Implementation Details**:
- All wait methods accept `using` and `value` parameters (not just CSS selectors)
- Generic helper `wait_for_condition()` used internally
- Timeout errors include helpful context (selector, duration, last error)
- Uses V closures with `&WebDriver` reference for condition checking

**Files Created**:
- `webdriver/expected_conditions.v` - 4 wait helper methods
- `webdriver/expected_conditions_test.v` - 7 comprehensive tests
- `example_phase6.v` - Full demonstration with 7 scenarios

**Testing**: All 7 tests pass (presence, visibility, clickability, text, timeouts, timeout behavior, intervals)

---

### Phase 7: Advanced Actions & Interactions (MEDIUM PRIORITY)

**Impact**: Medium - Useful for complex interactions
**Effort**: Medium (2-3 days)
**Coverage Gain**: 78% → 85% (+7%)

#### 7.1 Form Submit
**W3C Endpoint**: N/A (can use click or JavaScript)

```v
// File: webdriver/elements.v

pub fn (wd WebDriver) submit(el ElementRef) ! {
	// Find the form element
	wd.execute_script('arguments[0].submit()', [json.Any(json.encode(el))])!
}
```

#### 7.2 Context Click (Right Click)

```v
// File: webdriver/actions.v

pub fn (wd WebDriver) context_click(el ElementRef) ! {
	mut actions := wd.new_action_builder()

	// Get element center
	rect := wd.get_element_rect(el)!
	x := int(rect.x + rect.width / 2)
	y := int(rect.y + rect.height / 2)

	actions.pointer_move(x, y, 0)
	actions.pointer_down(2)  // Right button = 2
	actions.pointer_up(2)

	wd.perform_actions(actions.build())!
}
```

#### 7.3 Click and Hold

```v
// File: webdriver/actions.v

pub fn (wd WebDriver) click_and_hold(el ElementRef) ! {
	rect := wd.get_element_rect(el)!
	x := int(rect.x + rect.width / 2)
	y := int(rect.y + rect.height / 2)

	mut actions := wd.new_action_builder()
	actions.pointer_move(x, y, 0)
	actions.pointer_down(0)  // Left button, hold down

	wd.perform_actions(actions.build())!
}

pub fn (wd WebDriver) release_held_button() ! {
	mut actions := wd.new_action_builder()
	actions.pointer_up(0)  // Release left button

	wd.perform_actions(actions.build())!
}
```

#### 7.4 Drag and Drop (Enhanced)

```v
// File: webdriver/actions.v

pub fn (wd WebDriver) drag_and_drop_to_element(source ElementRef, target ElementRef) ! {
	source_rect := wd.get_element_rect(source)!
	target_rect := wd.get_element_rect(target)!

	source_x := int(source_rect.x + source_rect.width / 2)
	source_y := int(source_rect.y + source_rect.height / 2)
	target_x := int(target_rect.x + target_rect.width / 2)
	target_y := int(target_rect.y + target_rect.height / 2)

	mut actions := wd.new_action_builder()
	actions.pointer_move(source_x, source_y, 0)
	actions.pointer_down(0)
	actions.pointer_move(target_x, target_y, 500)  // 500ms duration
	actions.pointer_up(0)

	wd.perform_actions(actions.build())!
}

pub fn (wd WebDriver) drag_and_drop_by_offset(el ElementRef, x_offset int, y_offset int) ! {
	rect := wd.get_element_rect(el)!

	start_x := int(rect.x + rect.width / 2)
	start_y := int(rect.y + rect.height / 2)
	end_x := start_x + x_offset
	end_y := start_y + y_offset

	mut actions := wd.new_action_builder()
	actions.pointer_move(start_x, start_y, 0)
	actions.pointer_down(0)
	actions.pointer_move(end_x, end_y, 500)
	actions.pointer_up(0)

	wd.perform_actions(actions.build())!
}
```

**Methods Added**: 6 (submit, context_click, click_and_hold, release, 2x drag_and_drop)
**Files**: `webdriver/elements.v`, `webdriver/actions.v` (modified)
**Tests**: `webdriver/actions_test.v` (add 6 tests)

---

### Phase 8: Advanced JavaScript & Browser Features (LOW PRIORITY)

**Impact**: Low-Medium - Specialized use cases
**Effort**: Low (1-2 days)
**Coverage Gain**: 85% → 92% (+7%)

#### 8.1 Execute Async Script
**W3C Endpoint**: `POST /session/{session id}/execute/async`

```v
// File: webdriver/script.v

pub fn (wd WebDriver) execute_async_script(script string, args []json.Any) !json.Any {
	mut payload := map[string]json.Any{}
	payload['script'] = json.Any(script)
	payload['args'] = json.Any(args)

	resp := wd.post[json.Any]('/session/${wd.session_id}/execute/async', json.Any(payload))!
	return resp.value
}
```

**Use Case**: Execute JavaScript that uses callbacks or promises

#### 8.2 Shadow Root Support
**W3C Endpoint**: `GET /session/{session id}/element/{element id}/shadow`

```v
// File: webdriver/elements.v

pub struct ShadowRoot {
pub:
	shadow_root_id string @[json: 'shadow-6066-11e4-a52e-4f735466cecf']
}

pub fn (wd WebDriver) get_shadow_root(el ElementRef) !ShadowRoot {
	resp := wd.get_request[ShadowRoot]('/session/${wd.session_id}/element/${el.element_id}/shadow')!
	return resp.value
}

pub fn (wd WebDriver) find_element_in_shadow_root(shadow ShadowRoot, using string, value string) !ElementRef {
	mut payload := map[string]json.Any{}
	payload['using'] = json.Any(using)
	payload['value'] = json.Any(value)

	resp := wd.post[ElementRef]('/session/${wd.session_id}/shadow/${shadow.shadow_root_id}/element', json.Any(payload))!
	return resp.value
}
```

#### 8.3 Enhanced Browser Logs
**W3C Endpoint**: `POST /session/{session id}/se/log` (Selenium extension)

```v
// File: webdriver/client.v

pub struct LogEntry {
pub:
	timestamp int
	level     string
	message   string
}

pub fn (wd WebDriver) get_log_types() ![]string {
	// Implementation depends on browser-specific endpoints
	// For now, return common types
	return ['browser', 'driver', 'performance']
}

pub fn (wd WebDriver) get_logs(log_type string) ![]LogEntry {
	mut payload := map[string]json.Any{}
	payload['type'] = json.Any(log_type)

	resp := wd.post[[]LogEntry]('/session/${wd.session_id}/se/log', json.Any(payload))!
	return resp.value
}
```

**Methods Added**: 5 (execute_async_script, shadow_root, find_in_shadow, get_log_types, get_logs)
**Files**: `webdriver/script.v`, `webdriver/elements.v`, `webdriver/client.v` (modified)
**Tests**: Multiple test files (5 tests)

---

### Phase 9: Multi-Browser Support (HIGH PRIORITY - EXPANDING SCOPE)

**Impact**: High - Browser diversity and cross-platform support
**Effort**: High (2-3 weeks)
**Coverage Gain**: Scope expansion, platform compatibility

#### 9.1 Chrome/Chromium Support (Windows, Linux, macOS)

```v
// File: webdriver/capabilities.v

pub struct ChromeOptions {
pub mut:
	args              []string
	binary            string
	extensions        []string
	prefs             map[string]json.Any
	detach            bool
	debugger_address  string
	exclude_switches  []string
	experimental_options map[string]json.Any
}

pub fn new_chrome_driver(url string, caps Capabilities) !WebDriver {
	// ChromeDriver implementation
	// Platform detection for default binary paths:
	// - Windows: C:\Program Files\Google\Chrome\Application\chrome.exe
	// - Linux: /usr/bin/google-chrome
	// - macOS: /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
	return WebDriver{
		base_url: url
		session_id: create_session(url, caps)!
	}
}
```

**Platform-specific paths**:
- Windows: `C:\Program Files\Google\Chrome\Application\chrome.exe`
- Linux: `/usr/bin/google-chrome` or `/usr/bin/chromium-browser`
- macOS: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`

#### 9.2 Firefox Support (Windows, Linux, macOS)

```v
// File: webdriver/capabilities.v

pub struct FirefoxOptions {
pub mut:
	args    []string
	binary  string
	profile string
	prefs   map[string]json.Any
	log     map[string]string
	env     map[string]string
}

pub fn new_firefox_driver(url string, caps Capabilities) !WebDriver {
	// GeckoDriver implementation
	// Platform detection for default binary paths:
	// - Windows: C:\Program Files\Mozilla Firefox\firefox.exe
	// - Linux: /usr/bin/firefox
	// - macOS: /Applications/Firefox.app/Contents/MacOS/firefox
	return WebDriver{
		base_url: url
		session_id: create_session(url, caps)!
	}
}
```

**Platform-specific paths**:
- Windows: `C:\Program Files\Mozilla Firefox\firefox.exe`
- Linux: `/usr/bin/firefox`
- macOS: `/Applications/Firefox.app/Contents/MacOS/firefox`

#### 9.3 Safari Support (macOS only)

```v
// File: webdriver/capabilities.v

pub struct SafariOptions {
pub mut:
	automatic_inspection bool
	automatic_profiling  bool
	use_technology_preview bool
}

$if macos {
	pub fn new_safari_driver(url string, caps Capabilities) !WebDriver {
		// SafariDriver implementation (macOS only)
		// Safari is pre-installed on macOS
		// SafariDriver at: /usr/bin/safaridriver
		return WebDriver{
			base_url: url
			session_id: create_session(url, caps)!
		}
	}
}
```

**Platform**: macOS only (Safari is not available on Windows/Linux)
**Driver**: `/usr/bin/safaridriver` (built-in on macOS 10.12+)

#### 9.4 Platform Detection Helper

```v
// File: webdriver/platform.v (new file)

module webdriver

import os

pub enum Platform {
	windows
	linux
	macos
	unknown
}

pub fn detect_platform() Platform {
	$if windows {
		return .windows
	} $else $if linux {
		return .linux
	} $else $if macos {
		return .macos
	} $else {
		return .unknown
	}
}

pub fn get_default_browser_path(browser string) ?string {
	platform := detect_platform()

	match browser {
		'chrome' {
			return match platform {
				.windows { r'C:\Program Files\Google\Chrome\Application\chrome.exe' }
				.linux { '/usr/bin/google-chrome' }
				.macos { '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' }
				else { none }
			}
		}
		'firefox' {
			return match platform {
				.windows { r'C:\Program Files\Mozilla Firefox\firefox.exe' }
				.linux { '/usr/bin/firefox' }
				.macos { '/Applications/Firefox.app/Contents/MacOS/firefox' }
				else { none }
			}
		}
		'safari' {
			return match platform {
				.macos { '/Applications/Safari.app/Contents/MacOS/Safari' }
				else { none }
			}
		}
		'edge' {
			return match platform {
				.windows { r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
				.linux { '/usr/bin/microsoft-edge' }
				.macos { '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge' }
				else { none }
			}
		}
		else { return none }
	}
}
```

**Methods Added**: 4 new driver constructors + platform utilities
**Files**: `webdriver/capabilities.v`, `webdriver/client.v`, `webdriver/platform.v` (new)
**Tests**: Browser-specific and platform-specific test suites

---

### Phase 10: WebDriver BiDi Protocol Support (ADVANCED - FUTURE)

**Impact**: High - Modern bidirectional communication
**Effort**: Very High (3-4 weeks)
**Coverage Gain**: Advanced features, real-time capabilities

**Background**: WebDriver BiDi is the next-generation protocol that provides bidirectional communication between the test script and browser, enabling real-time events and improved performance.

#### 10.1 BiDi Session Management

```v
// File: webdriver/bidi.v (new file)

module webdriver

import net.websocket

pub struct BiDiSession {
mut:
	ws           &websocket.Client
	session_id   string
	command_id   int
	event_handlers map[string]fn(json.Any)
}

pub fn (mut wd WebDriver) enable_bidi() !BiDiSession {
	// Upgrade HTTP session to BiDi WebSocket connection
	// WebSocket URL: ws://localhost:port/session/{session_id}/bidi
	ws_url := '${wd.base_url.replace('http://', 'ws://')}/session/${wd.session_id}/bidi'

	mut ws := websocket.new_client(ws_url)!
	ws.connect()!

	return BiDiSession{
		ws: ws
		session_id: wd.session_id
		command_id: 0
		event_handlers: map[string]fn(json.Any){}
	}
}
```

#### 10.2 BiDi Commands

```v
// File: webdriver/bidi.v

pub fn (mut bidi BiDiSession) send_command(method string, params json.Any) !json.Any {
	bidi.command_id++

	command := {
		'id': bidi.command_id
		'method': method
		'params': params
	}

	bidi.ws.write_string(json.encode(command))!

	// Wait for response
	response := bidi.ws.read_string()!
	result := json.decode(response)!

	return result
}

// Example BiDi commands
pub fn (mut bidi BiDiSession) subscribe_to_log_events() ! {
	bidi.send_command('session.subscribe', {
		'events': ['log.entryAdded']
	})!
}

pub fn (mut bidi BiDiSession) navigate_with_wait(url string) ! {
	bidi.send_command('browsingContext.navigate', {
		'url': url
		'wait': 'complete'
	})!
}
```

#### 10.3 BiDi Events (Real-time)

```v
// File: webdriver/bidi.v

pub fn (mut bidi BiDiSession) on_console_log(handler fn(json.Any)) {
	bidi.event_handlers['log.entryAdded'] = handler

	// Start event listener in background
	go bidi.listen_for_events()
}

fn (mut bidi BiDiSession) listen_for_events() {
	for {
		message := bidi.ws.read_string() or { break }

		event := json.decode(message) or { continue }

		if event_name := event['method'] {
			if handler := bidi.event_handlers[event_name.str()] {
				handler(event['params'])
			}
		}
	}
}
```

#### 10.4 BiDi Use Cases

**Real-time Console Monitoring**:
```v
mut bidi := wd.enable_bidi()!
defer { bidi.close() }

// Subscribe to console logs in real-time
bidi.on_console_log(fn (entry json.Any) {
	println('Console: ${entry}')
})

wd.get('https://example.com')!
// Console logs appear immediately as they happen
```

**Network Interception**:
```v
bidi.subscribe_to_network_events()!

bidi.on_request_sent(fn (request json.Any) {
	println('Request: ${request['url']}')
})

bidi.on_response_received(fn (response json.Any) {
	println('Response: ${response['status']}')
})
```

**Performance Monitoring**:
```v
bidi.subscribe_to_performance_events()!

metrics := bidi.get_performance_metrics()!
println('Page load time: ${metrics.dom_content_loaded}ms')
```

#### 10.5 BiDi Features Roadmap

**Browsing Context**:
- Navigation with wait conditions
- Context creation/destruction
- Frame handling
- Window management

**Network**:
- Request/response interception
- Network event monitoring
- Cookie management
- Authentication handling

**Script**:
- Script evaluation with realm support
- Channel communication
- Exception handling

**Logging**:
- Console log monitoring
- JavaScript errors
- Performance logs

**Input**:
- Actions API enhancement
- File handling
- Drag and drop improvements

**Methods Added**: 15-20 BiDi methods
**Files**: `webdriver/bidi.v` (new), `webdriver/bidi_test.v` (new)
**Dependencies**: WebSocket support in V
**Timeline**: 3-4 weeks (complex protocol)

**Standards**:
- [WebDriver BiDi Spec](https://w3c.github.io/webdriver-bidi/)
- Chrome DevTools Protocol compatibility
- Firefox Marionette compatibility

---

## 📋 Complete Implementation Checklist

### Phase 5: Advanced Element Properties ⏳
- [ ] `get_css_value(el, property)` - Get computed CSS
- [ ] `get_element_size(el)` - Get width/height
- [ ] `get_element_location(el)` - Get x/y position
- [ ] `get_element_rect(el)` - Get unified rect
- [ ] Write 4 tests
- [ ] Update documentation

**Effort**: 1-2 days | **Gain**: +9%

### Phase 6: Expected Conditions ✅ COMPLETE
- [x] `wait_until_clickable(using, value, timeout_ms)` - Wait for clickable
- [x] `wait_until_visible(using, value, timeout_ms)` - Wait for visible
- [x] `wait_until_present(using, value, timeout_ms)` - Wait for present
- [x] `wait_for_text_in_element(using, value, text, timeout_ms)` - Wait for text
- [x] `get_timeouts()` - Get current timeouts
- [x] Create `expected_conditions.v`
- [x] Write 7 tests (5 wait methods + timeout retrieval + error handling)
- [x] Create `example_phase6.v` demo
- [x] Update documentation

**Effort**: 2-3 days | **Gain**: +6% | **Status**: ✅ COMPLETE (2026-02-15)

### Phase 7: Advanced Actions ⏳
- [ ] `submit(el)` - Submit form
- [ ] `context_click(el)` - Right click
- [ ] `click_and_hold(el)` - Click and hold
- [ ] `release_held_button()` - Release held button
- [ ] `drag_and_drop_to_element(source, target)` - Drag and drop
- [ ] `drag_and_drop_by_offset(el, x, y)` - Drag by offset
- [ ] Write 6 tests
- [ ] Update documentation

**Effort**: 2-3 days | **Gain**: +7%

### Phase 8: Advanced Features ⏳
- [ ] `execute_async_script(script, args)` - Async JavaScript
- [ ] `get_shadow_root(el)` - Get shadow root
- [ ] `find_element_in_shadow_root(shadow, using, value)` - Find in shadow
- [ ] `get_log_types()` - Get available log types
- [ ] `get_logs(type)` - Get browser logs
- [ ] Write 5 tests
- [ ] Update documentation

**Effort**: 1-2 days | **Gain**: +7%

### Phase 9: Multi-Browser & Platform Support ⏳
- [ ] Platform detection (Windows, Linux, macOS)
- [ ] Chrome/Chromium driver (all platforms)
- [ ] Firefox driver / GeckoDriver (all platforms)
- [ ] Safari driver (macOS only)
- [ ] Edge driver for Linux/macOS
- [ ] Platform-specific binary path detection
- [ ] Cross-platform capabilities
- [ ] Cross-browser test suite
- [ ] Platform-specific CI/CD workflows

**Effort**: 2-3 weeks | **Scope expansion + Platform compatibility**

### Phase 10: WebDriver BiDi Protocol ⏳
- [ ] WebSocket-based BiDi session
- [ ] BiDi command/response handling
- [ ] Event subscription system
- [ ] Real-time console log monitoring
- [ ] Network interception
- [ ] Performance monitoring
- [ ] Script evaluation with realms
- [ ] Browsing context management
- [ ] BiDi test suite
- [ ] Documentation and examples

**Effort**: 3-4 weeks | **Advanced features**

---

## 📊 Progress Tracking

| Phase | Methods | Effort | Coverage Before | Coverage After | Status |
|-------|---------|--------|-----------------|----------------|--------|
| 1-4 | 23 | Done | 55% | 85% | ✅ COMPLETE |
| 5 | 4 | 1-2 days | 91% | 93% | ⏳ Pending |
| 6 | 5 | 2-3 days | 85% | 91% | ✅ COMPLETE |
| 7 | 6 | 2-3 days | 93% | 97% | ⏳ Pending |
| 8 | 5 | 1-2 days | 97% | 100% | ⏳ Pending |
| 9 | Platform utilities | 2-3 weeks | Multi-browser support | ⏳ High Priority |
| 10 | 15-20 BiDi methods | 3-4 weeks | Advanced BiDi features | ⏳ Future |

**Total Additional Methods (Phases 5, 7-8)**: 15
**Time to 100% Feature Parity**: 4-8 days (1-1.5 weeks)
**Time for Full Platform Support**: +2-3 weeks (Phase 9)
**Time for BiDi Protocol**: +3-4 weeks (Phase 10)

**Milestones**:
- **v2.1.0**: 91% feature parity (Phase 6) - ✅ COMPLETE (2026-02-15)
- **v3.0.0**: 100% W3C WebDriver parity (Phases 5, 7-8) - 1-1.5 weeks
- **v3.5.0**: Multi-browser + Platform support (Phase 9) - 2-3 weeks
- **v4.0.0**: WebDriver BiDi protocol (Phase 10) - 3-4 weeks

---

## 🎯 Recommended Priority Order

### High Priority (Core Features - Do First)
1. **Phase 6: Expected Conditions** - Most commonly requested (2-3 days)
2. **Phase 7: Advanced Actions** - Common use cases (2-3 days)
3. **Phase 5: Element Properties** - Complete the category (1-2 days)
4. **Phase 8: Advanced Features** - Nice to have (1-2 days)

**Total**: 4-8 days → **v3.0.0 (100% W3C WebDriver)**

**Note**: Phase 6 was completed before Phase 5 due to higher priority and impact.

### High Priority (Platform Expansion)
5. **Phase 9: Multi-Browser & Platform Support** - Critical for adoption (2-3 weeks)
   - Chrome/Chromium on all platforms
   - Firefox on all platforms
   - Safari on macOS
   - Edge on Linux/macOS
   - Platform detection and auto-configuration

**Total**: 2-3 weeks → **v3.5.0 (Cross-platform + Multi-browser)**

### Future (Advanced Features)
6. **Phase 10: WebDriver BiDi Protocol** - Modern real-time capabilities (3-4 weeks)
   - Real-time browser events
   - Network interception
   - Performance monitoring
   - Modern web app testing

**Total**: 3-4 weeks → **v4.0.0 (BiDi Protocol Support)**

---

## 🚀 Quick Start for Phase 5

To begin implementing Phase 5 immediately:

```bash
# Create branch for Phase 5
git checkout -b phase5-element-properties

# Create test file
touch webdriver/element_rect_test.v

# Start implementation in webdriver/elements.v
# Add the 4 methods listed in Phase 5 section
```

---

## 💡 Implementation Notes

### Phases 5-8 (Core Features)
- Build on existing infrastructure
- Minimal new files (only `expected_conditions.v`)
- All use standard W3C WebDriver classic protocol
- Focus on completing desktop feature parity
- No breaking changes to existing API

### Phase 9 (Multi-Browser & Platform)
- Platform detection using V's conditional compilation (`$if windows`, `$if linux`, `$if macos`)
- Browser binary auto-detection per platform
- Shared WebDriver interface across all browsers
- Platform-specific test suites
- Safari support is macOS-only (not available on other platforms)
- Edge on Linux requires Microsoft's Edge for Linux package

### Phase 10 (WebDriver BiDi)
- Requires WebSocket support (V's `net.websocket` module)
- Parallel protocol to classic HTTP-based WebDriver
- Can run alongside classic WebDriver
- Enables real-time browser events without polling
- Modern alternative to Chrome DevTools Protocol (CDP)
- Future-proof for next-generation web testing

### Out of Scope
- **Mobile features** (Appium) - Separate project
- **Browser extensions** - Different use case
- **UI automation** outside browsers - Use other tools
- **Selenium Grid** - Server infrastructure (possible future addition)

---

## ✅ Success Criteria

### v3.0.0 - 100% W3C WebDriver Classic Protocol

1. ✅ All W3C WebDriver classic endpoints implemented
2. ✅ All common Selenium methods have V equivalents
3. ✅ Comprehensive test coverage (>90%)
4. ✅ All expected conditions helpers available
5. ✅ Advanced interactions (drag/drop, right-click) working
6. ✅ Shadow DOM support for modern web components
7. ✅ Async script execution
8. ✅ Browser log access

**Target Release**: v3.0.0
**Timeline**: 1.5-2 weeks from v2.0.0
**Feature Parity**: 100% with Selenium WebDriver Classic Protocol

### v3.5.0 - Cross-Platform Multi-Browser Support

1. ✅ Chrome/Chromium support on Windows, Linux, macOS
2. ✅ Firefox support on Windows, Linux, macOS
3. ✅ Safari support on macOS
4. ✅ Edge support on Windows, Linux, macOS
5. ✅ Platform auto-detection
6. ✅ Default binary path resolution per platform
7. ✅ Cross-platform test suite
8. ✅ Platform-specific CI/CD pipelines

**Target Release**: v3.5.0
**Timeline**: 2-3 weeks from v3.0.0
**Platform Parity**: All major browsers on all platforms

### v4.0.0 - WebDriver BiDi Protocol

1. ✅ WebSocket-based BiDi session management
2. ✅ Real-time event subscription system
3. ✅ Console log monitoring
4. ✅ Network interception and monitoring
5. ✅ Performance metrics collection
6. ✅ Script evaluation with realms
7. ✅ Bidirectional communication
8. ✅ Modern web app testing features

**Target Release**: v4.0.0
**Timeline**: 3-4 weeks from v3.5.0
**Feature Parity**: Modern Selenium 4.x BiDi features

---

**Status**: Draft roadmap - Ready for implementation
**Version**: Draft for v2.0.0 → v3.0.0
**Date**: 2026-02-14

# Roadmap to 100% Feature Parity with Selenium

**Current Status**: v2.0.0 - 85% feature parity
**Target**: v3.0.0 - 100% feature parity
**Remaining**: 15% (~18-20 additional methods)

---

## 📊 Gap Analysis

### Current Coverage by Category

| Category | Current | Target | Gap |
|----------|---------|--------|-----|
| Element Properties | 64% (7/11) | 100% (11/11) | 4 methods |
| Element Interaction | 75% (3/4) | 100% (4/4) | 1 method |
| JavaScript | 67% (2/3) | 100% (3/3) | 1 method |
| Actions API | 80% (8/10) | 100% (10/10) | 2 methods |
| Waits | 57% (4/7) | 100% (7/7) | 3 methods |
| Timeouts | 75% (3/4) | 100% (4/4) | 1 method |
| Shadow DOM | 0% (0/1) | 100% (1/1) | 1 method |
| Browser Logs | ~50% (1/2) | 100% (2/2) | 1 method |

**Total Missing**: ~18-20 methods

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

### Phase 6: Expected Conditions & Advanced Waits (HIGH PRIORITY)

**Impact**: High - Very commonly used pattern
**Effort**: Medium (2-3 days)
**Coverage Gain**: 73% → 78% (+5%)

#### 6.1 Create Expected Conditions Module

```v
// File: webdriver/expected_conditions.v (new file)

module webdriver

import time

// Wait for element to be clickable (visible and enabled)
pub fn (wd WebDriver) wait_until_clickable(selector string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(timeout_ms, 500, fn [wd, selector] () !(bool, ElementRef) {
		el := wd.find_element('css selector', selector) or {
			return false, ElementRef{}
		}
		visible := wd.is_displayed(el) or { return false, ElementRef{} }
		enabled := wd.is_enabled(el) or { return false, ElementRef{} }

		if visible && enabled {
			return true, el
		}
		return false, ElementRef{}
	})!
}

// Wait for element to be visible
pub fn (wd WebDriver) wait_until_visible(selector string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(timeout_ms, 500, fn [wd, selector] () !(bool, ElementRef) {
		el := wd.find_element('css selector', selector) or {
			return false, ElementRef{}
		}
		visible := wd.is_displayed(el) or { return false, ElementRef{} }

		if visible {
			return true, el
		}
		return false, ElementRef{}
	})!
}

// Wait for element to be present (exists in DOM)
pub fn (wd WebDriver) wait_until_present(selector string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(timeout_ms, 500, fn [wd, selector] () !(bool, ElementRef) {
		el := wd.find_element('css selector', selector) or {
			return false, ElementRef{}
		}
		return true, el
	})!
}

// Wait for text to be present in element
pub fn (wd WebDriver) wait_for_text_in_element(selector string, text string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(timeout_ms, 500, fn [wd, selector, text] () !(bool, ElementRef) {
		el := wd.find_element('css selector', selector) or {
			return false, ElementRef{}
		}
		elem_text := wd.get_text(el) or { return false, ElementRef{} }

		if elem_text.contains(text) {
			return true, el
		}
		return false, ElementRef{}
	})!
}

// Generic condition helper
fn (wd WebDriver) wait_for_condition(timeout_ms int, interval_ms int, condition fn () !(bool, ElementRef)) !ElementRef {
	start := time.now()
	for {
		success, el := condition() or { false, ElementRef{} }
		if success {
			return el
		}

		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('Timeout waiting for condition after ${timeout_ms}ms')
		}

		time.sleep(interval_ms * time.millisecond)
	}
	return error('Unreachable')
}
```

#### 6.2 Get Timeouts
**W3C Endpoint**: `GET /session/{session id}/timeouts`

```v
// File: webdriver/wait.v

pub struct Timeouts {
pub:
	implicit  int  // implicit wait timeout in ms
	page_load int @[json: 'pageLoad']  // page load timeout in ms
	script    int  // script timeout in ms
}

pub fn (wd WebDriver) get_timeouts() !Timeouts {
	resp := wd.get_request[Timeouts]('/session/${wd.session_id}/timeouts')!
	return resp.value
}
```

**Methods Added**: 5 (4 expected conditions + 1 get_timeouts)
**Files**: `webdriver/expected_conditions.v` (new), `webdriver/wait.v` (modified)
**Tests**: `webdriver/expected_conditions_test.v` (new, 5 tests)

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

### Phase 9: Multi-Browser Support (OPTIONAL - EXPANDING SCOPE)

**Impact**: High - Browser diversity
**Effort**: High (1-2 weeks)
**Coverage Gain**: Scope expansion, not percentage

#### 9.1 Chrome/Chromium Support

```v
// File: webdriver/capabilities.v

pub struct ChromeOptions {
pub mut:
	args           []string
	binary         string
	extensions     []string
	prefs          map[string]json.Any
	detach         bool
	debugger_address string
}

pub fn new_chrome_driver(url string, caps Capabilities) !WebDriver {
	// Similar to new_edge_driver but for Chrome
}
```

#### 9.2 Firefox Support

```v
// File: webdriver/capabilities.v

pub struct FirefoxOptions {
pub mut:
	args    []string
	binary  string
	profile string
	prefs   map[string]json.Any
	log     map[string]string
}

pub fn new_firefox_driver(url string, caps Capabilities) !WebDriver {
	// GeckoDriver implementation
}
```

#### 9.3 Safari Support

```v
pub fn new_safari_driver(url string, caps Capabilities) !WebDriver {
	// SafariDriver implementation
}
```

**Methods Added**: 3 new driver constructors
**Files**: `webdriver/capabilities.v`, `webdriver/client.v` (modified)
**Tests**: Browser-specific test suites

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

### Phase 6: Expected Conditions ⏳
- [ ] `wait_until_clickable(selector, timeout)` - Wait for clickable
- [ ] `wait_until_visible(selector, timeout)` - Wait for visible
- [ ] `wait_until_present(selector, timeout)` - Wait for present
- [ ] `wait_for_text_in_element(selector, text, timeout)` - Wait for text
- [ ] `get_timeouts()` - Get current timeouts
- [ ] Create `expected_conditions.v`
- [ ] Write 5 tests
- [ ] Update documentation

**Effort**: 2-3 days | **Gain**: +5%

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

### Phase 9: Multi-Browser (Optional) ⏳
- [ ] Chrome/Chromium driver
- [ ] Firefox driver (GeckoDriver)
- [ ] Safari driver
- [ ] Browser-specific capabilities
- [ ] Cross-browser test suite

**Effort**: 1-2 weeks | **Scope expansion**

---

## 📊 Progress Tracking

| Phase | Methods | Effort | Coverage Before | Coverage After | Status |
|-------|---------|--------|-----------------|----------------|--------|
| 1-4 | 23 | Done | 55% | 85% | ✅ COMPLETE |
| 5 | 4 | 1-2 days | 85% | 87% | ⏳ Pending |
| 6 | 5 | 2-3 days | 87% | 91% | ⏳ Pending |
| 7 | 6 | 2-3 days | 91% | 95% | ⏳ Pending |
| 8 | 5 | 1-2 days | 95% | 100% | ⏳ Pending |
| 9 | N/A | 1-2 weeks | Scope expansion | ⏳ Optional |

**Total Additional Methods**: 20
**Total Estimated Time**: 6-10 days (1.5-2 weeks)
**Final Coverage**: 100% 🎉

---

## 🎯 Recommended Priority Order

### High Priority (Do First)
1. **Phase 6: Expected Conditions** - Most commonly requested
2. **Phase 7: Advanced Actions** - Common use cases
3. **Phase 5: Element Properties** - Complete the category

### Medium Priority (Do Second)
4. **Phase 8: Advanced Features** - Nice to have

### Low Priority (Optional)
5. **Phase 9: Multi-Browser** - Scope expansion, separate project phase

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

## 💡 Notes

- Phases 5-8 build on existing infrastructure
- No new files required except `expected_conditions.v`
- All use standard W3C endpoints
- Mobile features (Appium) are out of scope for desktop WebDriver
- Focus on desktop browser automation first
- Multi-browser support (Phase 9) could be a separate v3.5.0 or v4.0.0 release

---

## ✅ Success Criteria for 100%

1. ✅ All W3C WebDriver desktop endpoints implemented
2. ✅ All common Selenium methods have V equivalents
3. ✅ Comprehensive test coverage (>90%)
4. ✅ All expected conditions helpers available
5. ✅ Advanced interactions (drag/drop, right-click) working
6. ✅ Shadow DOM support for modern web components
7. ✅ Async script execution
8. ✅ Browser log access

**Target Release**: v3.0.0
**Timeline**: 1.5-2 weeks of focused development
**Feature Parity**: 100% with Selenium WebDriver (desktop)

---

**Status**: Draft roadmap - Ready for implementation
**Version**: Draft for v2.0.0 → v3.0.0
**Date**: 2026-02-14

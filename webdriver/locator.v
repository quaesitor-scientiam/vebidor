module webdriver

import time
import x.json2 as json

// default_timeout_ms is how long auto-waiting operations poll before giving up.
pub const default_timeout_ms = 30000

// default_poll_ms is the interval between auto-waiting retries.
pub const default_poll_ms = 100

// Locator is a lazy, re-resolvable handle to an element (Playwright-style).
// Unlike ElementRef it does NOT capture a specific element id up front; it
// stores the selection criteria and resolves them fresh on every use, so it is
// immune to staleness from DOM re-renders. Actions on a Locator auto-wait for
// the element to become actionable.
@[heap]
pub struct Locator {
pub:
	wd          &WebDriver
	using       string // 'css selector' | 'xpath' | 'link text' | ...
	value       string
	parent      &Locator = unsafe { nil } // for chained / scoped locators
	index       int      = -1             // -1 = first match; >=0 = nth match
	timeout_ms  int      = default_timeout_ms
	interval_ms int      = default_poll_ms
}

// parse_selector maps a Playwright-ish selector string onto a W3C strategy.
// Plain strings are CSS; `xpath=`/`css=` prefixes and a leading `//` force a
// strategy explicitly.
fn parse_selector(selector string) (string, string) {
	if selector.starts_with('xpath=') {
		return 'xpath', selector[6..]
	}
	if selector.starts_with('css=') {
		return 'css selector', selector[4..]
	}
	if selector.starts_with('//') || selector.starts_with('(//') || selector.starts_with('(/') {
		return 'xpath', selector
	}
	return 'css selector', selector
}

// locator creates a Locator rooted at the document.
pub fn (wd &WebDriver) locator(selector string) Locator {
	using, value := parse_selector(selector)
	return Locator{
		wd:    wd
		using: using
		value: value
	}
}

// locator narrows the search to descendants of this locator's element.
pub fn (l &Locator) locator(selector string) Locator {
	using, value := parse_selector(selector)
	return Locator{
		wd:          l.wd
		using:       using
		value:       value
		parent:      l
		timeout_ms:  l.timeout_ms
		interval_ms: l.interval_ms
	}
}

// describe returns a human-readable form of the locator for error messages.
pub fn (l Locator) describe() string {
	mut s := '${l.using}=${l.value}'
	if l.index >= 0 {
		s += ' [nth=${l.index}]'
	}
	if !isnil(l.parent) {
		s = '${l.parent.describe()} >> ${s}'
	}
	return s
}

// nth returns a locator targeting the i-th match (0-based).
pub fn (l Locator) nth(i int) Locator {
	return Locator{
		wd:          l.wd
		using:       l.using
		value:       l.value
		parent:      l.parent
		index:       i
		timeout_ms:  l.timeout_ms
		interval_ms: l.interval_ms
	}
}

// first returns a locator targeting the first match.
pub fn (l Locator) first() Locator {
	return l.nth(0)
}

// with_timeout returns a copy of the locator using a different auto-wait timeout.
pub fn (l Locator) with_timeout(ms int) Locator {
	return Locator{
		wd:          l.wd
		using:       l.using
		value:       l.value
		parent:      l.parent
		index:       l.index
		timeout_ms:  ms
		interval_ms: l.interval_ms
	}
}

// find resolves the locator to a single ElementRef (no waiting).
fn (l Locator) find() !ElementRef {
	if l.index >= 0 {
		els := l.find_all()!
		if l.index >= els.len {
			return error('locator "${l.describe()}" index ${l.index} out of range (found ${els.len})')
		}
		return els[l.index]
	}
	if isnil(l.parent) {
		return l.wd.find_element(l.using, l.value)
	}
	pel := l.parent.find()!
	return l.wd.find_element_from(pel, l.using, l.value)
}

// find_all resolves the locator to every matching ElementRef (no waiting).
fn (l Locator) find_all() ![]ElementRef {
	if isnil(l.parent) {
		return l.wd.find_elements(l.using, l.value)
	}
	pel := l.parent.find()!
	return l.wd.find_elements_from(pel, l.using, l.value)
}

// wait_for waits until the element is present in the DOM and returns it.
pub fn (l Locator) wait_for() !ElementRef {
	start := time.now()
	mut last := ''
	for {
		if el := l.find() {
			return el
		} else {
			last = err.msg()
		}
		if time.now().unix_milli() - start.unix_milli() > i64(l.timeout_ms) {
			return error('locator "${l.describe()}" not found after ${l.timeout_ms}ms: ${last}')
		}
		time.sleep(l.interval_ms * time.millisecond)
	}
	return error('unreachable')
}

// actionability checks (in-page) whether an element is ready to be interacted
// with. It scrolls the element into view and returns 'ok' or a reason string.
fn (wd &WebDriver) actionability(el ElementRef) !string {
	script := 'var el = arguments[0];' + 'if (!el || !el.isConnected) return "detached";' +
		'el.scrollIntoView({block:"center",inline:"center"});' +
		'var s = window.getComputedStyle(el);' +
		'if (s.visibility === "hidden" || s.display === "none") return "hidden";' +
		'var r = el.getBoundingClientRect();' +
		'if (r.width === 0 && r.height === 0) return "zero_size";' +
		'if (el.disabled) return "disabled";' + 'if (el.getAttribute("aria-disabled") === "true") return "aria_disabled";' +
		'return "ok";'
	el_arg := {
		'element-6066-11e4-a52e-4f735466cecf': json.Any(el.element_id)
	}
	res := wd.execute_script(script, [json.Any(el_arg)])!
	return res.str()
}

// wait_until_actionable waits for the element to be attached, visible, and
// enabled, scrolling it into view, then returns it.
fn (l Locator) wait_until_actionable() !ElementRef {
	start := time.now()
	mut last := 'unknown'
	for {
		if el := l.find() {
			status := l.wd.actionability(el) or {
				last = 'check failed: ${err.msg()}'
				''
			}
			if status == 'ok' {
				return el
			}
			if status.len > 0 {
				last = status
			}
		} else {
			last = 'not attached'
		}
		if time.now().unix_milli() - start.unix_milli() > i64(l.timeout_ms) {
			return error('locator "${l.describe()}" not actionable after ${l.timeout_ms}ms (${last})')
		}
		time.sleep(l.interval_ms * time.millisecond)
	}
	return error('unreachable')
}

// click auto-waits for actionability, then clicks. Retries once on staleness.
pub fn (l Locator) click() ! {
	el := l.wait_until_actionable()!
	l.wd.click(el) or {
		// Element may have gone stale between resolve and click; re-resolve once.
		el2 := l.wait_until_actionable()!
		l.wd.click(el2)!
	}
}

// tap performs a touch tap at the element's center (mobile emulation),
// auto-waiting for actionability. Touch events fire only on a touch-capable or
// emulated browser (see Device emulation); on others it behaves like a click.
pub fn (l Locator) tap() ! {
	el := l.wait_until_actionable()!
	rect := l.wd.get_element_rect(el)!
	x := int(rect.x + rect.width / 2)
	y := int(rect.y + rect.height / 2)
	src := touch('touch', [
		pointer_move(x, y, 0),
		pointer_down(0),
		pointer_up(0),
	])
	l.wd.perform_actions([src])!
}

// fill clears the field and types text into it, auto-waiting for actionability.
pub fn (l Locator) fill(text string) ! {
	el := l.wait_until_actionable()!
	l.wd.clear(el)!
	l.wd.send_keys(el, text)!
}

// type_text types text without clearing first, auto-waiting for actionability.
pub fn (l Locator) type_text(text string) ! {
	el := l.wait_until_actionable()!
	l.wd.send_keys(el, text)!
}

// clear empties the field, auto-waiting for actionability.
pub fn (l Locator) clear() ! {
	el := l.wait_until_actionable()!
	l.wd.clear(el)!
}

// text returns the element's visible text, waiting for it to be present.
pub fn (l Locator) text() !string {
	el := l.wait_for()!
	return l.wd.get_text(el)
}

// get_attribute returns an attribute value, waiting for the element to exist.
pub fn (l Locator) get_attribute(name string) !string {
	el := l.wait_for()!
	return l.wd.get_attribute(el, name)
}

// is_visible reports current visibility without waiting (false if not found).
pub fn (l Locator) is_visible() bool {
	el := l.find() or { return false }
	return l.wd.is_displayed(el) or { false }
}

// is_enabled reports the current enabled state, waiting for the element.
pub fn (l Locator) is_enabled() !bool {
	el := l.wait_for()!
	return l.wd.is_enabled(el)
}

// count returns how many elements currently match (no waiting).
pub fn (l Locator) count() !int {
	els := l.find_all()!
	return els.len
}

// element resolves and returns the underlying ElementRef, for callers that
// need the lower-level WebDriver element API.
pub fn (l Locator) element() !ElementRef {
	return l.wait_for()
}

// --- WebDriver scoped-find helpers (used by chained locators) ---

// find_element_from finds the first descendant of `parent` matching the locator.
// W3C Endpoint: POST /session/{session id}/element/{element id}/element
pub fn (wd &WebDriver) find_element_from(parent ElementRef, using string, value string) !ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[ElementRef]('/session/${wd.session_id}/element/${parent.element_id}/element',
		json.Any(params))!
	return resp.value
}

// find_elements_from finds all descendants of `parent` matching the locator.
// W3C Endpoint: POST /session/{session id}/element/{element id}/elements
pub fn (wd &WebDriver) find_elements_from(parent ElementRef, using string, value string) ![]ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[[]ElementRef]('/session/${wd.session_id}/element/${parent.element_id}/elements',
		json.Any(params))!
	return resp.value
}

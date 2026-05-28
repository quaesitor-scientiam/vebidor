module mobile

// Action methods on MobileLocator. Each one auto-waits for actionability
// (present + displayed + enabled) before dispatching, so callers don't have
// to thread their own `wait_*` calls. Mirrors `webdriver.Locator.click /
// fill / clear / text` etc. on the web side.

// tap auto-waits for the element to be actionable, then taps it.
// Equivalent to a single-finger click; for multi-finger or precise-position
// gestures use the actions API directly (lands later in this phase).
pub fn (l MobileLocator) tap() ! {
	el := l.wait_until_actionable()!
	l.session.click_element(el)!
}

// fill auto-waits for actionability, then types `text` into the element.
// Use `tap()` first to focus a text field if the platform demands it
// (XCUITest usually focuses on its own when the field is editable).
pub fn (l MobileLocator) fill(text string) ! {
	el := l.wait_until_actionable()!
	l.session.send_keys(el, text)!
}

// clear empties a text field. Auto-waits.
pub fn (l MobileLocator) clear() ! {
	el := l.wait_until_actionable()!
	l.session.clear_element(el)!
}

// text returns the rendered text of the element. Waits for presence (not
// full actionability — invisible elements still have text).
pub fn (l MobileLocator) text() !string {
	el := l.wait_for()!
	return l.session.element_text(el)
}

// is_visible returns true if the element is currently in the view tree and
// displayed. Returns false on any error — useful for fast "is it there yet?"
// checks; for an assertion that polls, use `mobile.expect(loc).to_be_visible()`
// (Mob-5).
pub fn (l MobileLocator) is_visible() bool {
	el := l.find() or { return false }
	return l.session.is_element_displayed(el) or { false }
}

// is_enabled returns true if the element accepts input. Returns false on
// any error.
pub fn (l MobileLocator) is_enabled() bool {
	el := l.find() or { return false }
	return l.session.is_element_enabled(el) or { false }
}

// attribute reads a single XCUITest attribute (e.g. `name`, `label`,
// `value`, `enabled`, `accessible`). Waits for presence.
pub fn (l MobileLocator) attribute(name string) !string {
	el := l.wait_for()!
	return l.session.element_attribute(el, name)
}

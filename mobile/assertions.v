module mobile

import vebidor.webdriver

// Mobile-first assertions (Playwright-style). Each assertion polls the
// locator until the expected condition holds or the timeout elapses — no
// "assert right after action" flakes. Use `.not()` to invert any assertion
// and `.with_timeout(ms)` to override the polling window.
//
// Mirrors `webdriver.LocatorAssertions` on the web side; both share the
// polling helper (`webdriver.poll_until_true`) extracted in Mob-1.

pub struct MobileLocatorAssertions {
pub:
	locator    MobileLocator
	timeout_ms int = default_timeout_ms
	is_not     bool
}

// expect begins a mobile-first assertion chain against a MobileLocator.
// Lives in the `mobile` module, so it doesn't collide with
// `webdriver.expect` — call sites distinguish via the module prefix
// (`mobile.expect(loc)` vs `webdriver.expect(loc)`).
pub fn expect(l MobileLocator) MobileLocatorAssertions {
	return MobileLocatorAssertions{
		locator:    l
		timeout_ms: l.timeout_ms
	}
}

// not inverts the assertion that follows.
pub fn (a MobileLocatorAssertions) not() MobileLocatorAssertions {
	return MobileLocatorAssertions{
		locator:    a.locator
		timeout_ms: a.timeout_ms
		is_not:     true
	}
}

// with_timeout overrides the polling timeout for this assertion.
pub fn (a MobileLocatorAssertions) with_timeout(ms int) MobileLocatorAssertions {
	return MobileLocatorAssertions{
		locator:    a.locator
		timeout_ms: ms
		is_not:     a.is_not
	}
}

// poll runs the shared `webdriver.poll_until_true` helper with this
// assertion's timeout / interval, formats the timeout message with the
// locator's description and `desc`, and inverts the predicate when
// `.not()` is in effect.
fn (a MobileLocatorAssertions) poll(desc string, check fn () !bool) ! {
	is_not := a.is_not
	neg := if is_not { ' not' } else { '' }
	webdriver.poll_until_true(webdriver.WaitOptions{
		timeout_ms:  a.timeout_ms
		interval_ms: a.locator.interval_ms
		describe:    'mobile.expect(${a.locator.describe()})${neg} ${desc}'
	}, fn [check, is_not] () !bool {
		ok := check() or { false }
		return if is_not { !ok } else { ok }
	})!
}

// to_be_visible asserts the element is present and displayed.
pub fn (a MobileLocatorAssertions) to_be_visible() ! {
	l := a.locator
	a.poll('to_be_visible', fn [l] () !bool {
		el := l.find() or { return false }
		return l.session.is_element_displayed(el) or { false }
	})!
}

// to_be_hidden asserts the element is absent or not displayed.
pub fn (a MobileLocatorAssertions) to_be_hidden() ! {
	l := a.locator
	a.poll('to_be_hidden', fn [l] () !bool {
		el := l.find() or { return true } // not in tree => hidden
		return !(l.session.is_element_displayed(el) or { false })
	})!
}

// to_be_enabled asserts the element accepts input.
pub fn (a MobileLocatorAssertions) to_be_enabled() ! {
	l := a.locator
	a.poll('to_be_enabled', fn [l] () !bool {
		el := l.find() or { return false }
		return l.session.is_element_enabled(el) or { false }
	})!
}

// to_be_disabled asserts the element rejects input.
pub fn (a MobileLocatorAssertions) to_be_disabled() ! {
	l := a.locator
	a.poll('to_be_disabled', fn [l] () !bool {
		el := l.find() or { return true } // not in tree => not enabled
		return !(l.session.is_element_enabled(el) or { false })
	})!
}

// to_have_text asserts the element's rendered text equals `want`.
pub fn (a MobileLocatorAssertions) to_have_text(want string) ! {
	l := a.locator
	a.poll('to_have_text "${want}"', fn [l, want] () !bool {
		el := l.find() or { return false }
		got := l.session.element_text(el) or { return false }
		return got == want
	})!
}

// to_contain_text asserts the element's rendered text contains `want`
// as a substring.
pub fn (a MobileLocatorAssertions) to_contain_text(want string) ! {
	l := a.locator
	a.poll('to_contain_text "${want}"', fn [l, want] () !bool {
		el := l.find() or { return false }
		got := l.session.element_text(el) or { return false }
		return got.contains(want)
	})!
}

// to_have_attribute asserts the element's `name` attribute equals `value`.
// `name` is an XCUITest attribute (e.g. `label`, `name`, `value`, `enabled`).
pub fn (a MobileLocatorAssertions) to_have_attribute(name string, value string) ! {
	l := a.locator
	a.poll('to_have_attribute "${name}=${value}"', fn [l, name, value] () !bool {
		el := l.find() or { return false }
		got := l.session.element_attribute(el, name) or { return false }
		return got == value
	})!
}

// to_have_count asserts the locator's `find_elements` returns exactly
// `want` results. Useful for "I expect N rows after this filter applies".
pub fn (a MobileLocatorAssertions) to_have_count(want int) ! {
	l := a.locator
	a.poll('to_have_count ${want}', fn [l, want] () !bool {
		els := l.session.find_elements(l.using, l.value) or { return false }
		return els.len == want
	})!
}

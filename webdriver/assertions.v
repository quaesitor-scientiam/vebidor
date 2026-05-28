module webdriver

// Web-first assertions (Playwright-style). Each assertion polls the locator
// until the expected condition holds or the timeout elapses, instead of
// checking once. This removes most flakiness from "assert right after action"
// patterns. Use `.not()` to invert any assertion.

pub struct LocatorAssertions {
pub:
	locator    Locator
	timeout_ms int = default_timeout_ms
	is_not     bool
}

// expect begins a web-first assertion chain against a locator.
pub fn expect(l Locator) LocatorAssertions {
	return LocatorAssertions{
		locator:    l
		timeout_ms: l.timeout_ms
	}
}

// not inverts the assertion that follows.
pub fn (a LocatorAssertions) not() LocatorAssertions {
	return LocatorAssertions{
		locator:    a.locator
		timeout_ms: a.timeout_ms
		is_not:     true
	}
}

// with_timeout overrides the polling timeout for this assertion.
pub fn (a LocatorAssertions) with_timeout(ms int) LocatorAssertions {
	return LocatorAssertions{
		locator:    a.locator
		timeout_ms: ms
		is_not:     a.is_not
	}
}

// poll repeatedly evaluates `check` until it matches the (possibly negated)
// expectation or the timeout elapses. Delegates to the shared
// `poll_until_true` helper so the polling loop has a single owner.
fn (a LocatorAssertions) poll(desc string, check fn () !bool) ! {
	is_not := a.is_not
	neg := if is_not { ' not' } else { '' }
	poll_until_true(WaitOptions{
		timeout_ms:  a.timeout_ms
		interval_ms: a.locator.interval_ms
		describe:    'expect(${a.locator.describe()})${neg} ${desc}'
	}, fn [check, is_not] () !bool {
		ok := check() or { false }
		return if is_not { !ok } else { ok }
	})!
}

// to_be_visible asserts the element is present and displayed.
pub fn (a LocatorAssertions) to_be_visible() ! {
	l := a.locator
	a.poll('to_be_visible', fn [l] () !bool {
		el := l.find() or { return false }
		return l.wd.is_displayed(el) or { false }
	})!
}

// to_be_hidden asserts the element is absent or not displayed.
pub fn (a LocatorAssertions) to_be_hidden() ! {
	l := a.locator
	a.poll('to_be_hidden', fn [l] () !bool {
		el := l.find() or { return true } // not in DOM => hidden
		return !(l.wd.is_displayed(el) or { false })
	})!
}

// to_be_enabled asserts the element exists and is enabled.
pub fn (a LocatorAssertions) to_be_enabled() ! {
	l := a.locator
	a.poll('to_be_enabled', fn [l] () !bool {
		el := l.find() or { return false }
		return l.wd.is_enabled(el) or { false }
	})!
}

// to_be_disabled asserts the element exists and is disabled.
pub fn (a LocatorAssertions) to_be_disabled() ! {
	l := a.locator
	a.poll('to_be_disabled', fn [l] () !bool {
		el := l.find() or { return false }
		return !(l.wd.is_enabled(el) or { true })
	})!
}

// to_have_text asserts the element's trimmed visible text equals `text`.
pub fn (a LocatorAssertions) to_have_text(text string) ! {
	l := a.locator
	a.poll('to_have_text "${text}"', fn [l, text] () !bool {
		el := l.find() or { return false }
		actual := l.wd.get_text(el) or { return false }
		return actual.trim_space() == text
	})!
}

// to_contain_text asserts the element's visible text contains `text`.
pub fn (a LocatorAssertions) to_contain_text(text string) ! {
	l := a.locator
	a.poll('to_contain_text "${text}"', fn [l, text] () !bool {
		el := l.find() or { return false }
		actual := l.wd.get_text(el) or { return false }
		return actual.contains(text)
	})!
}

// to_have_value asserts a form control's current value equals `value`.
pub fn (a LocatorAssertions) to_have_value(value string) ! {
	l := a.locator
	a.poll('to_have_value "${value}"', fn [l, value] () !bool {
		el := l.find() or { return false }
		v := l.wd.get_property(el, 'value') or { return false }
		return v.str() == value
	})!
}

// to_have_attribute asserts an attribute exists with the given value.
pub fn (a LocatorAssertions) to_have_attribute(name string, value string) ! {
	l := a.locator
	a.poll('to_have_attribute ${name}="${value}"', fn [l, name, value] () !bool {
		el := l.find() or { return false }
		actual := l.wd.get_attribute(el, name) or { return false }
		return actual == value
	})!
}

// to_have_count asserts exactly `n` elements match the locator.
pub fn (a LocatorAssertions) to_have_count(n int) ! {
	l := a.locator
	a.poll('to_have_count ${n}', fn [l, n] () !bool {
		c := l.count() or { return false }
		return c == n
	})!
}

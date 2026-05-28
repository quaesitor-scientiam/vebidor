module mobile

// XCUITest selector factories on MobileSession. Each returns a lazy
// MobileLocator that resolves against WDA on every use. Strategy strings
// match WDA's wire vocabulary verbatim.
//
// Cross-platform `get_by_label` / `get_by_test_id` / `get_by_role` (the
// Playwright-style surface that picks the right strategy per platform)
// land in Mob-4 (`selectors.v`).

// accessibility_id matches against the element's accessibility identifier
// (XCUITest `name` attribute). Most stable selector — wire it into your
// app's views and you get bullet-proof tests.
pub fn (s &MobileSession) accessibility_id(id string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'accessibility id'
		value:   id
	}
}

// class_chain matches with an XCUITest class chain expression — a
// terser, faster cousin of XPath. Example: `**/XCUIElementTypeButton[\`name == 'Sign in'\`]`.
pub fn (s &MobileSession) class_chain(expr string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'class chain'
		value:   expr
	}
}

// predicate matches with an iOS NSPredicate string. Most flexible
// selector. Example: `label == 'Sign in' AND visible == 1`.
pub fn (s &MobileSession) predicate(expr string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'predicate string'
		value:   expr
	}
}

// xpath matches with an XPath expression against the XCUITest element
// tree. Slowest of the four; reach for it when the others can't express
// what you need.
pub fn (s &MobileSession) xpath(expr string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'xpath'
		value:   expr
	}
}

// label is a small convenience — `s.label('General')` builds the
// predicate `label == 'General'`. Useful when you don't have an
// accessibility id and the label is unique enough.
pub fn (s &MobileSession) label(text string) MobileLocator {
	return s.predicate("label == '${escape_predicate(text)}'")
}

// name is `predicate("name == '...'")`. XCUITest's `name` and
// accessibility id usually coincide, so prefer `accessibility_id`; this
// is here for the cases where they don't.
pub fn (s &MobileSession) name(text string) MobileLocator {
	return s.predicate("name == '${escape_predicate(text)}'")
}

// escape_predicate escapes single-quotes for embedding in an NSPredicate
// single-quoted string literal. NSPredicate doubles single-quotes to
// escape them.
fn escape_predicate(s string) string {
	return s.replace("'", "''")
}

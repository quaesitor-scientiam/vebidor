module mobile

// UiAutomator2 selector factories on MobileSession. Each returns a lazy
// MobileLocator that resolves against UiA2 on every use. Strategy strings
// match UiA2's wire vocabulary verbatim.
//
// `accessibility_id` and `xpath` (defined in wda_locators.v) work for
// both WDA and UiA2 because they're W3C-standard strategy names.
// This file adds the Android-specific ones: resource id, class name,
// and the UiSelector DSL.
//
// Cross-platform `get_by_label` / `get_by_test_id` / `get_by_role` (the
// Playwright-style surface that picks the right strategy per platform)
// lands in Mob-4.

// resource_id matches against an element's Android resource identifier
// (e.g. `com.example.app:id/login_button`). The most stable Android
// selector — wire it into your app's views and you get bullet-proof
// tests.
pub fn (s &MobileSession) resource_id(id string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'id'
		value:   id
	}
}

// class_name matches against an element's Android widget class (e.g.
// `android.widget.Button`, `android.widget.TextView`).
pub fn (s &MobileSession) class_name(name string) MobileLocator {
	return MobileLocator{
		session: s
		using:   'class name'
		value:   name
	}
}

// uia2_selector matches with a UiAutomator UiSelector expression — the
// most flexible Android selector. Example:
//
//     new UiSelector().textContains("Sign in").className("android.widget.Button")
pub fn (s &MobileSession) uia2_selector(expr string) MobileLocator {
	return MobileLocator{
		session: s
		using:   '-android uiautomator'
		value:   expr
	}
}

// text is a small convenience — `s.text('Battery')` builds the
// UiSelector `new UiSelector().text("Battery")`. Useful when content-desc
// isn't set and visible text is unique enough.
pub fn (s &MobileSession) text(text string) MobileLocator {
	return s.uia2_selector('new UiSelector().text("${escape_uiselector(text)}")')
}

// text_contains is the substring-matching variant of `text` — handy when
// the rendered text has trailing whitespace or platform-injected suffixes.
pub fn (s &MobileSession) text_contains(needle string) MobileLocator {
	return s.uia2_selector('new UiSelector().textContains("${escape_uiselector(needle)}")')
}

// escape_uiselector escapes backslashes and double quotes for embedding
// in a UiSelector double-quoted string literal.
fn escape_uiselector(s string) string {
	return s.replace('\\', '\\\\').replace('"', '\\"')
}

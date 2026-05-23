module webdriver

// Playwright-style semantic selector engines. Each returns a lazy Locator built
// on a CSS or XPath translation, so resolution goes through the native W3C
// find_element endpoint (reliable element-ref handling) rather than returning
// elements out of execute_script.

// test_id_attribute is the attribute consulted by get_by_test_id.
pub const test_id_attribute = 'data-testid'

// xpath_literal safely quotes an arbitrary string for use as an XPath literal,
// falling back to concat() when the value contains both quote characters.
fn xpath_literal(s string) string {
	if !s.contains('"') {
		return '"${s}"'
	}
	if !s.contains("'") {
		return "'${s}'"
	}
	// Contains both ' and " : build concat("a", '"', "b", ...)
	parts := s.split('"')
	mut pieces := []string{}
	for i, p in parts {
		pieces << '"${p}"'
		if i < parts.len - 1 {
			pieces << '\'"\''
		}
	}
	return 'concat(${pieces.join(', ')})'
}

// css_escape_quotes escapes double quotes for use inside a CSS [attr="..."] value.
fn css_escape_quotes(s string) string {
	return s.replace('"', '\\"')
}

// get_by_test_id locates an element by its test id attribute (default
// `data-testid`). This is the most stable selector for app-authored test hooks.
pub fn (wd &WebDriver) get_by_test_id(id string) Locator {
	return wd.locator('css=[${test_id_attribute}="${css_escape_quotes(id)}"]')
}

// get_by_placeholder locates an input/textarea by its placeholder text (exact).
pub fn (wd &WebDriver) get_by_placeholder(text string) Locator {
	return wd.locator('css=[placeholder="${css_escape_quotes(text)}"]')
}

// get_by_text locates the innermost element containing the given text
// (substring match). The `not(.//*[...])` clause selects the deepest match so
// you target the leaf element rather than an enclosing container.
pub fn (wd &WebDriver) get_by_text(text string) Locator {
	lit := xpath_literal(text)
	xp := '//*[contains(normalize-space(.), ${lit}) and not(.//*[contains(normalize-space(.), ${lit})])]'
	return wd.locator('xpath=${xp}')
}

// get_by_label locates a form control associated with a label whose text
// matches (exact): via wrapping <label>, via label[for]=id, or via aria-label.
pub fn (wd &WebDriver) get_by_label(text string) Locator {
	lit := xpath_literal(text)
	xp := '//label[normalize-space(.)=${lit}]//input' +
		' | //label[normalize-space(.)=${lit}]//textarea' +
		' | //label[normalize-space(.)=${lit}]//select' +
		' | //input[@id=//label[normalize-space(.)=${lit}]/@for]' +
		' | //textarea[@id=//label[normalize-space(.)=${lit}]/@for]' +
		' | //select[@id=//label[normalize-space(.)=${lit}]/@for]' + ' | //*[@aria-label=${lit}]'
	return wd.locator('xpath=${xp}')
}

// role_base_xpath maps an ARIA role onto an XPath union of elements that carry
// that role implicitly or explicitly. Unknown roles fall back to [role=...].
fn role_base_xpath(role string) string {
	return match role {
		'button' {
			'//button | //input[@type="button" or @type="submit" or @type="reset" or @type="image"] | //*[@role="button"]'
		}
		'link' {
			'//a[@href] | //*[@role="link"]'
		}
		'checkbox' {
			'//input[@type="checkbox"] | //*[@role="checkbox"]'
		}
		'radio' {
			'//input[@type="radio"] | //*[@role="radio"]'
		}
		'textbox' {
			'//input[not(@type) or @type="text" or @type="search" or @type="email" or @type="url" or @type="tel" or @type="password"] | //textarea | //*[@role="textbox"]'
		}
		'heading' {
			'//h1 | //h2 | //h3 | //h4 | //h5 | //h6 | //*[@role="heading"]'
		}
		'img' {
			'//img | //*[@role="img"]'
		}
		'list' {
			'//ul | //ol | //*[@role="list"]'
		}
		'listitem' {
			'//li | //*[@role="listitem"]'
		}
		'combobox' {
			'//select | //*[@role="combobox"]'
		}
		'table' {
			'//table | //*[@role="table"]'
		}
		'navigation' {
			'//nav | //*[@role="navigation"]'
		}
		'banner' {
			'//header | //*[@role="banner"]'
		}
		'contentinfo' {
			'//footer | //*[@role="contentinfo"]'
		}
		'main' {
			'//main | //*[@role="main"]'
		}
		else {
			'//*[@role="${role}"]'
		}
	}
}

// get_by_role locates an element by ARIA role, optionally filtered by accessible
// name (matched against text content, aria-label, or title). Pass an empty
// `name` to match by role alone.
pub fn (wd &WebDriver) get_by_role(role string, name string) Locator {
	base := role_base_xpath(role)
	if name == '' {
		return wd.locator('xpath=${base}')
	}
	lit := xpath_literal(name)
	xp := '(${base})[normalize-space(.)=${lit} or @aria-label=${lit} or @title=${lit}]'
	return wd.locator('xpath=${xp}')
}

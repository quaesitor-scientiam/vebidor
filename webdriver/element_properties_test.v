module webdriver

import x.json2 as json

// Test helper to create a test driver instance
fn setup_test_driver() !WebDriver {
	caps := Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: EdgeOptions{
			args: [
				'--headless=new',
				'--disable-gpu',
				'--disable-dev-shm-usage',
				'--no-sandbox',
				'--log-level=3',
			]
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}
	return new_edge_driver('http://127.0.0.1:9515', caps)!
}

// Test get_text() method
fn test_get_text() {
	println('Testing: get_text()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Find heading and get its text
	heading := wd.find_element('css selector', 'h1') or {
		eprintln('Failed to find h1: ${err}')
		assert false
		return
	}

	text := wd.get_text(heading) or {
		eprintln('Failed to get text: ${err}')
		assert false
		return
	}

	assert text == 'Example Domain'
	println('✓ get_text() works correctly')
}

// Test get_attribute() method
fn test_get_attribute() {
	println('Testing: get_attribute()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Find link and get href attribute
	link := wd.find_element('css selector', 'a') or {
		eprintln('Failed to find link: ${err}')
		assert false
		return
	}

	href := wd.get_attribute(link, 'href') or {
		eprintln('Failed to get attribute: ${err}')
		assert false
		return
	}

	assert href.contains('iana.org')
	println('✓ get_attribute() works correctly')
}

// Test get_property() method
fn test_get_property() {
	println('Testing: get_property()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Get the tagName property of h1
	heading := wd.find_element('css selector', 'h1') or {
		eprintln('Failed to find h1: ${err}')
		assert false
		return
	}

	tag := wd.get_property(heading, 'tagName') or {
		eprintln('Failed to get property: ${err}')
		assert false
		return
	}

	assert tag.str().to_lower() == 'h1'
	println('✓ get_property() works correctly')
}

// Test is_displayed() method
fn test_is_displayed() {
	println('Testing: is_displayed()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Heading should be visible
	heading := wd.find_element('css selector', 'h1') or {
		eprintln('Failed to find h1: ${err}')
		assert false
		return
	}

	displayed := wd.is_displayed(heading) or {
		eprintln('Failed to check is_displayed: ${err}')
		assert false
		return
	}

	assert displayed == true
	println('✓ is_displayed() works correctly')
}

// Test is_enabled() method
fn test_is_enabled() {
	println('Testing: is_enabled()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Link should be enabled
	link := wd.find_element('css selector', 'a') or {
		eprintln('Failed to find link: ${err}')
		assert false
		return
	}

	enabled := wd.is_enabled(link) or {
		eprintln('Failed to check is_enabled: ${err}')
		assert false
		return
	}

	assert enabled == true
	println('✓ is_enabled() works correctly')
}

// Test get_tag_name() method
fn test_get_tag_name() {
	println('Testing: get_tag_name()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	heading := wd.find_element('css selector', 'h1') or {
		eprintln('Failed to find h1: ${err}')
		assert false
		return
	}

	tag_name := wd.get_tag_name(heading) or {
		eprintln('Failed to get tag name: ${err}')
		assert false
		return
	}

	assert tag_name.to_lower() == 'h1'
	println('✓ get_tag_name() works correctly')
}

// Combined test for clear() and element state
fn test_clear_and_input() {
	println('Testing: clear() with input fields')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a test page with an input field using JavaScript
	wd.get('https://example.com') or {
		assert false
		return
	}

	// Add an input field to the page
	wd.execute_script('
		const input = document.createElement("input");
		input.id = "test-input";
		input.type = "text";
		input.value = "initial value";
		document.body.appendChild(input);
	', []) or {
		eprintln('Failed to create input: ${err}')
		assert false
		return
	}

	// Find the input
	input := wd.find_element('css selector', '#test-input') or {
		eprintln('Failed to find input: ${err}')
		assert false
		return
	}

	// Check initial value using get_property
	initial_value := wd.get_property(input, 'value') or {
		eprintln('Failed to get initial value: ${err}')
		assert false
		return
	}
	assert initial_value.str() == 'initial value'

	// Clear the input
	wd.clear(input) or {
		eprintln('Failed to clear input: ${err}')
		assert false
		return
	}

	// Verify it's cleared
	cleared_value := wd.get_property(input, 'value') or {
		eprintln('Failed to get cleared value: ${err}')
		assert false
		return
	}
	assert cleared_value.str() == ''

	// Send new keys
	wd.send_keys(input, 'new value') or {
		eprintln('Failed to send keys: ${err}')
		assert false
		return
	}

	// Verify new value
	new_value := wd.get_property(input, 'value') or {
		eprintln('Failed to get new value: ${err}')
		assert false
		return
	}
	assert new_value.str() == 'new value'

	println('✓ clear() and input handling works correctly')
}

// Test is_selected() with checkboxes
fn test_is_selected() {
	println('Testing: is_selected() with checkboxes')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com') or {
		assert false
		return
	}

	// Create a checkbox using JavaScript
	wd.execute_script('
		const checkbox = document.createElement("input");
		checkbox.id = "test-checkbox";
		checkbox.type = "checkbox";
		document.body.appendChild(checkbox);
	', []) or {
		eprintln('Failed to create checkbox: ${err}')
		assert false
		return
	}

	checkbox := wd.find_element('css selector', '#test-checkbox') or {
		eprintln('Failed to find checkbox: ${err}')
		assert false
		return
	}

	// Should not be selected initially
	selected := wd.is_selected(checkbox) or {
		eprintln('Failed to check is_selected: ${err}')
		assert false
		return
	}
	assert selected == false

	// Click to select it
	wd.click(checkbox) or {
		eprintln('Failed to click checkbox: ${err}')
		assert false
		return
	}

	// Should now be selected
	selected_after := wd.is_selected(checkbox) or {
		eprintln('Failed to check is_selected after click: ${err}')
		assert false
		return
	}
	assert selected_after == true

	println('✓ is_selected() works correctly')
}

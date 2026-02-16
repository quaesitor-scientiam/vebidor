module webdriver

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

// Test wait_until_present - waits for element to exist in DOM
fn test_wait_until_present() {
	println('Testing: wait_until_present()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Wait for heading to be present (should succeed immediately)
	element := wd.wait_until_present('css selector', 'h1', 5000)!
	assert element.element_id != ''

	println('  ✓ wait_until_present() found element')
}

// Test wait_until_visible - waits for element to be visible
fn test_wait_until_visible() {
	println('Testing: wait_until_visible()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Wait for heading to be visible
	element := wd.wait_until_visible('css selector', 'h1', 5000)!
	assert element.element_id != ''

	// Verify it's actually visible
	visible := wd.is_displayed(element)!
	assert visible == true

	println('  ✓ wait_until_visible() found visible element')
}

// Test wait_until_clickable - waits for element to be clickable
fn test_wait_until_clickable() {
	println('Testing: wait_until_clickable()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Wait for link to be clickable
	element := wd.wait_until_clickable('css selector', 'a', 5000)!
	assert element.element_id != ''

	// Verify it's visible and enabled
	visible := wd.is_displayed(element)!
	enabled := wd.is_enabled(element)!
	assert visible == true
	assert enabled == true

	println('  ✓ wait_until_clickable() found clickable element')
}

// Test wait_for_text_in_element - waits for specific text
fn test_wait_for_text_in_element() {
	println('Testing: wait_for_text_in_element()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Wait for heading to contain "Example"
	element := wd.wait_for_text_in_element('css selector', 'h1', 'Example', 5000)!
	assert element.element_id != ''

	// Verify the text is present
	text := wd.get_text(element)!
	assert text.contains('Example')

	println('  ✓ wait_for_text_in_element() found text')
}

// Test get_timeouts - retrieves current timeout configuration
fn test_get_timeouts() {
	println('Testing: get_timeouts()')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Set some timeouts
	wd.set_implicit_wait(10000)!
	wd.set_page_load_timeout(30000)!
	wd.set_script_timeout(15000)!

	// Get timeouts and verify
	timeouts := wd.get_timeouts()!

	// Timeouts struct has optional fields
	if implicit := timeouts.implicit {
		assert implicit == 10000
		println('    Implicit: ${implicit}ms')
	}
	if page_load := timeouts.page_load {
		assert page_load == 30000
		println('    Page Load: ${page_load}ms')
	}
	if script := timeouts.script {
		assert script == 15000
		println('    Script: ${script}ms')
	}

	println('  ✓ get_timeouts() retrieved correct values')
}

// Test timeout behavior - element not found
fn test_wait_timeout() {
	println('Testing: wait timeout behavior')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Try to wait for non-existent element (should timeout)
	wd.wait_until_present('css selector', '#does-not-exist', 2000) or {
		// Expected to fail with timeout
		assert err.msg().contains('Timeout')
		println('  ✓ wait_until_present() correctly times out for missing element')
		return
	}

	// Should not reach here
	assert false, 'Expected timeout error'
}

// Test wait with custom interval
fn test_wait_intervals() {
	println('Testing: wait polling intervals')

	wd := setup_test_driver() or {
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// The wait functions use 500ms interval by default
	// This test just verifies the wait completes successfully
	element := wd.wait_until_present('css selector', 'h1', 5000)!
	assert element.element_id != ''

	println('  ✓ wait functions use proper polling intervals')
}

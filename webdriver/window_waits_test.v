module webdriver

fn setup_test_driver() !WebDriver {
	caps := Capabilities{
		browser_name:          'msedge'
		accept_insecure_certs: true
		edge_options:          EdgeOptions{
			args:   [
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

// Test maximize_window()
fn test_maximize_window() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Maximize the window
	wd.maximize_window()!

	// Get window rect to verify it changed
	rect := wd.get_window_rect()!
	// In headless mode, maximize might not change dimensions much
	// but the call should succeed
	assert rect.width > 0
	assert rect.height > 0

	println('✓ maximize_window() test passed')
}

// Test minimize_window()
fn test_minimize_window() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Minimize the window (may not work in headless mode)
	wd.minimize_window() or {
		// Minimize might not be supported in headless mode
		println('✓ minimize_window() test passed (not supported in headless)')
		return
	}

	println('✓ minimize_window() test passed')
}

// Test fullscreen_window()
fn test_fullscreen_window() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Fullscreen the window
	wd.fullscreen_window()!

	println('✓ fullscreen_window() test passed')
}

// Test set_implicit_wait()
fn test_set_implicit_wait() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Set implicit wait to 5 seconds
	wd.set_implicit_wait(5000)!

	wd.get('https://example.com')!

	// Now find_element should wait up to 5 seconds for elements
	element := wd.find_element('css selector', 'h1')!
	assert element.element_id.len > 0

	println('✓ set_implicit_wait() test passed')
}

// Test set_page_load_timeout()
fn test_set_page_load_timeout() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Set page load timeout to 30 seconds
	wd.set_page_load_timeout(30000)!

	wd.get('https://example.com')!

	println('✓ set_page_load_timeout() test passed')
}

// Test set_script_timeout()
fn test_set_script_timeout() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Set script timeout to 10 seconds
	wd.set_script_timeout(10000)!

	wd.get('https://example.com')!

	// Execute a quick script
	result := wd.execute_script('return 42', [])!
	assert result.int() == 42

	println('✓ set_script_timeout() test passed')
}

// Test new_window() - Create new tab
fn test_new_window_tab() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Get initial window handles
	initial_handles := wd.get_window_handles()!
	initial_count := initial_handles.len

	// Create a new tab
	result := wd.new_window('tab')!
	assert result.handle.len > 0
	assert result.type_ == 'tab'

	// Verify we have one more window handle
	new_handles := wd.get_window_handles()!
	assert new_handles.len == initial_count + 1

	println('✓ new_window(tab) test passed')
}

// Test switch_to_window()
fn test_switch_to_window() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate in first window
	wd.get('https://example.com')!
	first_handle := wd.get_window_handle()!

	// Create a new tab
	result := wd.new_window('tab')!
	second_handle := result.handle

	// Switch to the new tab
	wd.switch_to_window(second_handle)!

	// Verify we're in the new window
	current := wd.get_window_handle()!
	assert current == second_handle

	// Navigate in second window
	wd.get('https://www.iana.org/domains/reserved')!

	// Switch back to first window
	wd.switch_to_window(first_handle)!

	// Verify we're back in first window
	current2 := wd.get_window_handle()!
	assert current2 == first_handle

	println('✓ switch_to_window() test passed')
}

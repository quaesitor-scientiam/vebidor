module main

import webdriver

fn main() {
	println('========================================')
	println('WebDriver Simple Test Suite')
	println('========================================\n')

	mut passed := 0
	mut failed := 0

	// Test 1: Session creation and navigation
	println('[1/5] Testing session creation and navigation...')
	if run_test_basic_session() {
		println('✅ PASSED\n')
		passed++
	} else {
		println('❌ FAILED\n')
		failed++
	}

	// Test 2: Element finding
	println('[2/5] Testing element finding...')
	if run_test_element_finding() {
		println('✅ PASSED\n')
		passed++
	} else {
		println('❌ FAILED\n')
		failed++
	}

	// Test 3: JavaScript execution
	println('[3/5] Testing JavaScript execution...')
	if run_test_javascript() {
		println('✅ PASSED\n')
		passed++
	} else {
		println('❌ FAILED\n')
		failed++
	}

	// Test 4: Window operations
	println('[4/5] Testing window operations...')
	if run_test_window_ops() {
		println('✅ PASSED\n')
		passed++
	} else {
		println('❌ FAILED\n')
		failed++
	}

	// Test 5: Cookie operations
	println('[5/5] Testing cookie operations...')
	if run_test_cookies() {
		println('✅ PASSED\n')
		passed++
	} else {
		println('❌ FAILED\n')
		failed++
	}

	// Summary
	println('========================================')
	println('Test Results: ${passed} passed, ${failed} failed')
	println('========================================')

	if failed > 0 {
		exit(1)
	}
}

fn create_driver() !webdriver.WebDriver {
	caps := webdriver.Capabilities{
		browser_name:          'msedge'
		accept_insecure_certs: true
		edge_options:          webdriver.EdgeOptions{
			args:   [
				'--headless=new',
				'--disable-gpu',
				'--no-sandbox',
				'--log-level=3',
			]
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}
	return webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
}

fn run_test_basic_session() bool {
	wd := create_driver() or {
		eprintln('  Error: Failed to create driver: ${err}')
		return false
	}
	defer {
		wd.quit() or {}
	}

	// Navigate
	wd.get('https://example.com') or {
		eprintln('  Error: Navigation failed: ${err}')
		return false
	}

	println('  ✓ Session created and navigated')
	return true
}

fn run_test_element_finding() bool {
	wd := create_driver() or { return false }
	defer { wd.quit() or {} }

	wd.get('https://example.com') or { return false }

	// Find single element
	heading := wd.find_element('css selector', 'h1') or {
		eprintln('  Error: Failed to find element: ${err}')
		return false
	}

	if heading.element_id == '' {
		eprintln('  Error: Element ID is empty')
		return false
	}

	// Find multiple elements
	paragraphs := wd.find_elements('css selector', 'p') or {
		eprintln('  Error: Failed to find elements: ${err}')
		return false
	}

	if paragraphs.len == 0 {
		eprintln('  Error: No paragraphs found')
		return false
	}

	println('  ✓ Found heading and ${paragraphs.len} paragraphs')
	return true
}

fn run_test_javascript() bool {
	wd := create_driver() or { return false }
	defer { wd.quit() or {} }

	wd.get('https://example.com') or { return false }

	// Get title
	title := wd.execute_script('return document.title', []) or {
		eprintln('  Error: Failed to execute script: ${err}')
		return false
	}

	if title.str() != 'Example Domain' {
		eprintln('  Error: Wrong title: ${title}')
		return false
	}

	// Arithmetic
	result := wd.execute_script('return 2 + 2', []) or {
		eprintln('  Error: Failed arithmetic: ${err}')
		return false
	}

	if result.int() != 4 {
		eprintln('  Error: Wrong result: ${result}')
		return false
	}

	println('  ✓ JavaScript execution works')
	return true
}

fn run_test_window_ops() bool {
	wd := create_driver() or { return false }
	defer { wd.quit() or {} }

	wd.get('https://example.com') or { return false }

	// Get window handle
	handle := wd.get_window_handle() or {
		eprintln('  Error: Failed to get window handle: ${err}')
		return false
	}

	if handle == '' {
		eprintln('  Error: Window handle is empty')
		return false
	}

	// Get all handles
	handles := wd.get_window_handles() or {
		eprintln('  Error: Failed to get window handles: ${err}')
		return false
	}

	if handles.len == 0 {
		eprintln('  Error: No window handles')
		return false
	}

	println('  ✓ Window operations work (handle: ${handle[..8]}...)')
	return true
}

fn run_test_cookies() bool {
	wd := create_driver() or { return false }
	defer { wd.quit() or {} }

	wd.get('https://example.com') or { return false }

	// Add cookie
	cookie := webdriver.Cookie{
		name:   'test'
		value:  'value'
		path:   '/'
		domain: 'example.com'
	}
	wd.add_cookie(cookie) or {
		eprintln('  Error: Failed to add cookie: ${err}')
		return false
	}

	// Get cookies
	cookies := wd.get_cookies() or {
		eprintln('  Error: Failed to get cookies: ${err}')
		return false
	}

	if cookies.len == 0 {
		eprintln('  Error: No cookies found')
		return false
	}

	// Delete cookie
	wd.delete_cookie('test') or {
		eprintln('  Error: Failed to delete cookie: ${err}')
		return false
	}

	println('  ✓ Cookie operations work (${cookies.len} cookies)')
	return true
}

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

// Combined test for session, navigation, and basic operations
// This reduces the number of browser sessions created
fn test_basic_operations() {
	println('Testing: Basic operations (session, navigation, elements, JS)')

	wd := setup_test_driver() or {
		eprintln('Failed to create driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	// Verify session was created
	assert wd.session_id != ''
	assert wd.base_url == 'http://127.0.0.1:9515'

	// Navigate to a page
	wd.get('https://example.com') or {
		eprintln('Failed to navigate: ${err}')
		assert false
		return
	}

	// Get page title
	title := wd.execute_script('return document.title', []) or {
		eprintln('Failed to get title: ${err}')
		assert false
		return
	}
	assert title.str() == 'Example Domain'

	// Find single element
	heading := wd.find_element('css selector', 'h1') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}
	assert heading.element_id != ''

	// Find multiple elements
	paragraphs := wd.find_elements('css selector', 'p') or {
		eprintln('Failed to find elements: ${err}')
		assert false
		return
	}
	assert paragraphs.len > 0

	// Execute script with return value
	result := wd.execute_script('return 2 + 2', []) or {
		eprintln('Failed to execute script: ${err}')
		assert false
		return
	}
	assert result.int() == 4

	// Execute script with arguments
	result2 := wd.execute_script('return arguments[0] + arguments[1]', [
		json.Any(10),
		json.Any(20),
	]) or {
		eprintln('Failed to execute script with args: ${err}')
		assert false
		return
	}
	assert result2.int() == 30

	println('✓ Basic operations passed')
}

// Test window and cookie operations in one session
fn test_window_and_cookies() {
	println('Testing: Window and cookie operations')

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

	// Window operations
	handle := wd.get_window_handle() or {
		eprintln('Failed to get window handle: ${err}')
		assert false
		return
	}
	assert handle != ''

	handles := wd.get_window_handles() or {
		eprintln('Failed to get window handles: ${err}')
		assert false
		return
	}
	assert handles.len >= 1

	// Cookie operations
	cookie := Cookie{
		name: 'test_cookie'
		value: 'test_value'
		path: '/'
		domain: 'example.com'
	}
	wd.add_cookie(cookie) or {
		eprintln('Failed to add cookie: ${err}')
		assert false
		return
	}

	cookies := wd.get_cookies() or {
		eprintln('Failed to get cookies: ${err}')
		assert false
		return
	}
	assert cookies.len > 0

	wd.delete_cookie('test_cookie') or {
		eprintln('Failed to delete cookie: ${err}')
		assert false
		return
	}

	wd.delete_all_cookies() or {
		eprintln('Failed to delete all cookies: ${err}')
		assert false
		return
	}

	println('✓ Window and cookie operations passed')
}

// Test element not found error
fn test_element_not_found() {
	println('Testing: Element not found error handling')

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

	// Try to find non-existent element
	wd.find_element('css selector', '#nonexistent') or {
		// Should fail - this is expected
		assert err.msg().contains('no such element')
		println('✓ Element not found error handled correctly')
		return
	}
	// If we get here, the test failed
	assert false, 'Should have thrown an error for non-existent element'
}

// Test capabilities conversion (no browser needed)
fn test_capabilities_conversion() {
	println('Testing: Capabilities conversion')

	caps := Capabilities{
		browser_name: 'msedge'
		browser_version: '120.0'
		platform_name: 'windows'
		accept_insecure_certs: true
		page_load_strategy: 'normal'
		edge_options: EdgeOptions{
			args: ['--headless=new', '--disable-gpu']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
		timeouts: Timeouts{
			implicit: 5000
			page_load: 30000
			script: 10000
		}
	}

	params := caps.to_session_params()
	assert params.capabilities.always_match['browserName'] or { json.Any('') }.str() == 'msedge'
	assert params.capabilities.always_match['browserVersion'] or { json.Any('') }.str() == '120.0'
	assert params.capabilities.always_match['platformName'] or { json.Any('') }.str() == 'windows'

	// Verify firstMatch is not present (should be none)
	assert params.capabilities.first_match == none

	println('✓ Capabilities conversion passed')
}

// Test action builders (no browser needed)
fn test_action_builders() {
	println('Testing: Action builders')

	// Test key actions
	key_down_action := key_down('a')
	assert key_down_action.kind == 'keyDown'
	assert key_down_action.value or { '' } == 'a'

	key_up_action := key_up('a')
	assert key_up_action.kind == 'keyUp'
	assert key_up_action.value or { '' } == 'a'

	// Test pointer actions
	move_action := pointer_move(100, 200, 500)
	assert move_action.kind == 'pointerMove'
	assert move_action.x or { 0 } == 100
	assert move_action.y or { 0 } == 200
	assert move_action.duration or { 0 } == 500

	down_action := pointer_down(0)
	assert down_action.kind == 'pointerDown'
	assert down_action.button or { -1 } == 0

	up_action := pointer_up(0)
	assert up_action.kind == 'pointerUp'
	assert up_action.button or { -1 } == 0

	// Test pause
	pause_action := pause(1000)
	assert pause_action.kind == 'pause'
	assert pause_action.duration or { 0 } == 1000

	// Test wheel scroll
	scroll_action := wheel_scroll(0, 0, 10, 50)
	assert scroll_action.kind == 'scroll'
	assert scroll_action.delta_x or { 0 } == 10
	assert scroll_action.delta_y or { 0 } == 50

	// Test keyboard source
	kb_src := keyboard('kb1', [key_down('a'), key_up('a')])
	assert kb_src.kind == 'key'
	assert kb_src.id == 'kb1'
	assert kb_src.actions.len == 2

	// Test mouse source
	mouse_src := mouse('mouse1', [pointer_move(10, 10, 0)])
	assert mouse_src.kind == 'pointer'
	assert mouse_src.id == 'mouse1'
	assert mouse_src.actions.len == 1

	// Test wheel source
	wheel_src := wheel('wheel1', [wheel_scroll(0, 0, 5, 10)])
	assert wheel_src.kind == 'wheel'
	assert wheel_src.id == 'wheel1'
	assert wheel_src.actions.len == 1

	println('✓ Action builders passed')
}

module webdriver

import x.json2 as json

// Quick smoke tests - only essential functionality
// Run with: v test webdriver/quick_test.v

fn test_capabilities_and_actions() {
	println('Testing: Capabilities and action builders (no browser)')

	// Test capabilities conversion
	caps := Capabilities{
		browser_name:          'msedge'
		browser_version:       '120.0'
		platform_name:         'windows'
		accept_insecure_certs: true
	}

	params := caps.to_session_params()
	assert params.capabilities.always_match['browserName'] or { json.Any('') }.str() == 'msedge'
	assert params.capabilities.first_match == none

	// Test action builders
	key_action := key_down('a')
	assert key_action.kind == 'keyDown'
	assert key_action.value or { '' } == 'a'

	mouse_action := pointer_move(100, 200, 500)
	assert mouse_action.kind == 'pointerMove'
	assert mouse_action.x or { 0 } == 100

	kb_src := keyboard('kb1', [key_down('a'), key_up('a')])
	assert kb_src.kind == 'key'
	assert kb_src.actions.len == 2

	println('✓ Fast tests passed (no browser required)')
}

// Single integration test - creates only ONE browser session
fn test_webdriver_integration() {
	println('Testing: WebDriver integration (one browser session)')

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

	println('  Creating session...')
	wd := new_edge_driver('http://127.0.0.1:9515', caps) or {
		eprintln('Failed to create driver: ${err}')
		eprintln('Make sure EdgeDriver is running: .\\msedgedriver.exe --port=9515')
		assert false
		return
	}
	defer {
		println('  Closing session...')
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	// Verify session
	assert wd.session_id != ''

	// Navigate
	println('  Navigating...')
	wd.get('https://example.com') or {
		eprintln('Failed to navigate: ${err}')
		assert false
		return
	}

	// Execute JS
	println('  Executing JavaScript...')
	title := wd.execute_script('return document.title', []) or {
		eprintln('Failed to execute script: ${err}')
		assert false
		return
	}
	assert title.str() == 'Example Domain'

	// Find element
	println('  Finding element...')
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

	println('✓ Integration test passed')
}

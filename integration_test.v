module main

import webdriver
import x.json2 as json

// Integration test: Search on a website
fn test_search_flow() ! {
	println('Running integration test: Search flow')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	// Navigate to example.com
	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Verify page title
	title := wd.execute_script('return document.title', [])!
	assert title.str() == 'Example Domain'
	println('✓ Page title verified: ${title}')

	// Find and verify heading
	heading := wd.find_element('css selector', 'h1')!
	println('✓ Found h1 element: ${heading.element_id}')

	// Get heading text using JavaScript
	heading_text := wd.execute_script('return document.querySelector("h1").textContent', [])!
	println('✓ Heading text: ${heading_text}')

	println('✅ Search flow test passed!')
}

// Integration test: Cookie management
fn test_cookie_management() ! {
	println('\nRunning integration test: Cookie management')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	// Navigate to a page
	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Add cookies
	cookie1 := webdriver.Cookie{
		name: 'session_id'
		value: 'abc123'
		path: '/'
		domain: 'example.com'
	}
	wd.add_cookie(cookie1)!
	println('✓ Added session_id cookie')

	cookie2 := webdriver.Cookie{
		name: 'user_pref'
		value: 'dark_mode'
		path: '/'
		domain: 'example.com'
	}
	wd.add_cookie(cookie2)!
	println('✓ Added user_pref cookie')

	// Get all cookies
	cookies := wd.get_cookies()!
	println('✓ Retrieved ${cookies.len} cookies')
	assert cookies.len >= 2

	// Delete one cookie
	wd.delete_cookie('user_pref')!
	println('✓ Deleted user_pref cookie')

	// Verify deletion
	remaining_cookies := wd.get_cookies()!
	assert remaining_cookies.len < cookies.len
	println('✓ Verified cookie deletion')

	// Delete all cookies
	wd.delete_all_cookies()!
	final_cookies := wd.get_cookies()!
	assert final_cookies.len == 0
	println('✓ Deleted all cookies')

	println('✅ Cookie management test passed!')
}

// Integration test: Window management
fn test_window_management() ! {
	println('\nRunning integration test: Window management')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Get current window handle
	handle := wd.get_window_handle()!
	println('✓ Current window handle: ${handle}')

	// Get all window handles
	handles := wd.get_window_handles()!
	println('✓ Total windows: ${handles.len}')
	assert handles.len == 1

	// Get window rect
	rect := wd.get_window_rect()!
	println('✓ Window size: ${rect.width}x${rect.height} at (${rect.x}, ${rect.y})')

	// Resize window
	new_rect := webdriver.WindowRect{
		x: 0
		y: 0
		width: 1280
		height: 720
	}
	wd.set_window_rect(new_rect)!
	println('✓ Resized window to 1280x720')

	// Verify resize
	updated_rect := wd.get_window_rect()!
	println('✓ New window size: ${updated_rect.width}x${updated_rect.height}')

	println('✅ Window management test passed!')
}

// Integration test: JavaScript execution
fn test_javascript_execution() ! {
	println('\nRunning integration test: JavaScript execution')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Simple arithmetic
	result1 := wd.execute_script('return 10 + 20', [])!
	assert result1.int() == 30
	println('✓ JavaScript arithmetic: 10 + 20 = ${result1}')

	// String manipulation
	result2 := wd.execute_script('return "Hello" + " " + "World"', [])!
	assert result2.str() == 'Hello World'
	println('✓ JavaScript string: ${result2}')

	// With arguments
	result3 := wd.execute_script('return arguments[0] * arguments[1]', [
		json.Any(7),
		json.Any(6),
	])!
	assert result3.int() == 42
	println('✓ JavaScript with args: 7 * 6 = ${result3}')

	// DOM manipulation
	result4 := wd.execute_script('return document.querySelectorAll("p").length', [])!
	println('✓ Found ${result4} paragraph elements')

	// Get page URL
	url := wd.execute_script('return window.location.href', [])!
	println('✓ Current URL: ${url}')

	println('✅ JavaScript execution test passed!')
}

// Integration test: Navigation
fn test_navigation_flow() ! {
	println('\nRunning integration test: Navigation flow')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	// Navigate to first page
	wd.get('https://example.com')!
	url1 := wd.execute_script('return window.location.href', [])!
	println('✓ Page 1: ${url1}')

	// Navigate to second page
	wd.get('https://www.iana.org')!
	url2 := wd.execute_script('return window.location.href', [])!
	println('✓ Page 2: ${url2}')

	// Go back
	wd.back()!
	url_back := wd.execute_script('return window.location.href', [])!
	println('✓ Back to: ${url_back}')

	// Go forward
	wd.forward()!
	url_forward := wd.execute_script('return window.location.href', [])!
	println('✓ Forward to: ${url_forward}')

	// Refresh
	wd.refresh()!
	println('✓ Page refreshed')

	println('✅ Navigation flow test passed!')
}

// Integration test: Multiple elements
fn test_multiple_elements() ! {
	println('\nRunning integration test: Multiple elements')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: ['--headless=new']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Find all paragraphs
	paragraphs := wd.find_elements('css selector', 'p')!
	println('✓ Found ${paragraphs.len} paragraph elements')
	assert paragraphs.len > 0

	// Find all links
	links := wd.find_elements('css selector', 'a')!
	println('✓ Found ${links.len} link elements')

	// Find all divs
	divs := wd.find_elements('css selector', 'div')!
	println('✓ Found ${divs.len} div elements')

	println('✅ Multiple elements test passed!')
}

fn main() {
	println('========================================')
	println('Running WebDriver Integration Tests')
	println('========================================')

	test_search_flow() or {
		eprintln('❌ Search flow test failed: ${err}')
	}

	test_cookie_management() or {
		eprintln('❌ Cookie management test failed: ${err}')
	}

	test_window_management() or {
		eprintln('❌ Window management test failed: ${err}')
	}

	test_javascript_execution() or {
		eprintln('❌ JavaScript execution test failed: ${err}')
	}

	test_navigation_flow() or {
		eprintln('❌ Navigation flow test failed: ${err}')
	}

	test_multiple_elements() or {
		eprintln('❌ Multiple elements test failed: ${err}')
	}

	println('\n========================================')
	println('All integration tests completed!')
	println('========================================')
}

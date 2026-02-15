module webdriver

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

// Test get_title() - Get the current page title
fn test_get_title() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to example.com
	wd.get('https://example.com')!

	// Get the page title
	title := wd.get_title()!

	// Verify the title
	assert title == 'Example Domain', 'Title should be "Example Domain", got "${title}"'

	println('✓ get_title() test passed')
}

// Test get_current_url() - Get the current page URL
fn test_get_current_url() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to example.com
	wd.get('https://example.com/')!

	// Get the current URL
	url := wd.get_current_url()!

	// Verify the URL
	assert url == 'https://example.com/', 'URL should be "https://example.com/", got "${url}"'

	println('✓ get_current_url() test passed')
}

// Test get_page_source() - Get the HTML source of the page
fn test_get_page_source() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to example.com
	wd.get('https://example.com')!

	// Get the page source
	source := wd.get_page_source()!

	// Verify source contains expected elements
	assert source.contains('<html'), 'Source should contain <html tag'
	assert source.contains('<head>'), 'Source should contain <head> tag'
	assert source.contains('<body>'), 'Source should contain <body> tag'
	assert source.contains('Example Domain'), 'Source should contain page title'
	assert source.contains('</html>'), 'Source should contain closing html tag'

	println('✓ get_page_source() test passed')
}

// Test page navigation and URL changes
fn test_navigation_and_url() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to first page
	wd.get('https://example.com')!
	url1 := wd.get_current_url()!
	assert url1.contains('example.com'), 'Should be on example.com'

	// Navigate to different page
	wd.get('https://www.iana.org/domains/reserved')!
	url2 := wd.get_current_url()!
	assert url2.contains('iana.org'), 'Should be on iana.org'
	assert url2 != url1, 'URL should have changed'

	// Navigate back
	wd.back()!
	url3 := wd.get_current_url()!
	assert url3.contains('example.com'), 'Should be back on example.com'

	println('✓ navigation_and_url() test passed')
}

// Test all page info methods together
fn test_page_info_workflow() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to a page
	wd.get('https://example.com')!

	// Get all page info
	title := wd.get_title()!
	url := wd.get_current_url()!
	source := wd.get_page_source()!

	// Verify all info is consistent
	assert title == 'Example Domain', 'Title check failed'
	assert url == 'https://example.com/', 'URL check failed'
	assert source.contains(title), 'Source should contain the title'
	assert source.contains('<h1>Example Domain</h1>'), 'Source should contain main heading'

	println('✓ page_info_workflow() test passed')
}

// Test page source contains expected structure
fn test_page_source_structure() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!
	source := wd.get_page_source()!

	// Check HTML document structure
	assert source.starts_with('<html'), 'Should start with <html tag'
	assert source.contains('<!DOCTYPE html>') || source.contains('<!doctype html>') || source.starts_with('<html'), 'Should have valid HTML structure'
	assert source.contains('<title>'), 'Should have title tag'
	assert source.contains('<meta'), 'Should have meta tags'

	// Check content - be flexible about exact text
	assert source.contains('Example Domain'), 'Should contain page content'
	// Just verify there's some body content, not specific text that might change
	assert source.contains('<body>') || source.contains('<body '), 'Should have body content'

	println('✓ page_source_structure() test passed')
}

// Test that get_title() works after page navigation
fn test_title_after_navigation() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// First page
	wd.get('https://example.com')!
	title1 := wd.get_title()!
	assert title1 == 'Example Domain'

	// Navigate to link on the page
	link := wd.find_element('css selector', 'a')!
	wd.click(link)!

	// Wait a bit for navigation
	wd.wait_for(fn (wd WebDriver) !bool {
		url := wd.get_current_url()!
		return url.contains('iana.org')
	}, 5000, 500)!

	// Get new title
	title2 := wd.get_title()!
	assert title2 != title1, 'Title should change after navigation'
	assert title2.len > 0, 'New title should not be empty'

	println('✓ title_after_navigation() test passed')
}

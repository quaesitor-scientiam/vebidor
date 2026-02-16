module main

import webdriver

fn main() {
	run() or {
		eprintln('Phase 6 Demo failed: ${err}')
		exit(1)
	}
}

fn run() ! {
	println('========================================')
	println('Phase 6: Expected Conditions & Waits')
	println('v-webdriver v2.1.0 Demo')
	println('========================================\n')

	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
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

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	println('✓ WebDriver session created\n')

	// Scenario 1: Configure timeouts
	println('Scenario 1: Timeout Configuration')
	println('Setting timeouts for robust automation...')

	wd.set_implicit_wait(10000)!
	wd.set_page_load_timeout(30000)!
	wd.set_script_timeout(15000)!

	timeouts := wd.get_timeouts()!
	println('  Implicit Wait: ${timeouts.implicit}ms')
	println('  Page Load: ${timeouts.page_load}ms')
	println('  Script Timeout: ${timeouts.script}ms')
	println('✅ Scenario 1 complete\n')

	// Scenario 2: Wait until element is present
	println('Scenario 2: Wait Until Element Present')
	println('Navigating and waiting for elements...')

	wd.get('https://example.com')!

	element := wd.wait_until_present('css selector', 'h1', 5000)!
	text := wd.get_text(element)!
	println('  Found element with text: "${text}"')
	println('✅ Scenario 2 complete\n')

	// Scenario 3: Wait until element is visible
	println('Scenario 3: Wait Until Element Visible')
	println('Waiting for visible elements...')

	visible_element := wd.wait_until_visible('css selector', 'p', 5000)!
	is_visible := wd.is_displayed(visible_element)!
	println('  Element is visible: ${is_visible}')

	para_text := wd.get_text(visible_element)!
	println('  Paragraph text preview: "${para_text[..50]}..."')
	println('✅ Scenario 3 complete\n')

	// Scenario 4: Wait until element is clickable
	println('Scenario 4: Wait Until Element Clickable')
	println('Waiting for clickable links...')

	link := wd.wait_until_clickable('css selector', 'a', 5000)!
	is_enabled := wd.is_enabled(link)!
	is_displayed := wd.is_displayed(link)!
	println('  Link is enabled: ${is_enabled}')
	println('  Link is displayed: ${is_displayed}')

	href := wd.get_attribute(link, 'href')!
	println('  Link href: ${href}')
	println('✅ Scenario 4 complete\n')

	// Scenario 5: Wait for specific text in element
	println('Scenario 5: Wait For Text in Element')
	println('Waiting for specific text to appear...')

	heading := wd.wait_for_text_in_element('css selector', 'h1', 'Example', 5000)!
	heading_text := wd.get_text(heading)!
	println('  Found heading with expected text: "${heading_text}"')
	println('✅ Scenario 5 complete\n')

	// Scenario 6: Demonstrate timeout behavior
	println('Scenario 6: Timeout Behavior')
	println('Attempting to find non-existent element...')

	// Try to find non-existent element - will timeout
	test_result := wd.wait_until_present('css selector', '#does-not-exist', 2000) or {
		println('  ✓ Correctly timed out after 2000ms')
		err_len := if err.msg().len > 80 { 80 } else { err.msg().len }
		println('  Error message: ${err.msg()[..err_len]}...')
		println('✅ Scenario 6 complete\n')
		// Return empty ElementRef to continue
		webdriver.ElementRef{ element_id: '' }
	}

	// If we got an element with ID, something went wrong
	if test_result.element_id != '' {
		println('  ✗ Error: Should have timed out')
		return error('Expected timeout did not occur')
	}

	// Scenario 7: Combined wait strategies
	println('Scenario 7: Combined Wait Strategies')
	println('Using multiple wait conditions together...')

	// Navigate to a new page
	wd.get('https://www.iana.org/domains/reserved')!

	// Wait for page to be loaded (implicit through page load timeout)
	title := wd.get_title()!
	println('  Page title: "${title}"')

	// Wait for clickable element
	_ := wd.wait_until_clickable('css selector', 'a', 5000)!
	println('  Found clickable link')

	// Wait for specific text
	content := wd.wait_for_text_in_element('css selector', 'h1', 'IANA', 5000)!
	content_text := wd.get_text(content)!
	println('  Found content with text: "${content_text}"')

	println('✅ Scenario 7 complete\n')

	// Summary
	println('========================================')
	println('✅ All Phase 6 Scenarios Complete!')
	println('========================================')
	println('\nPhase 6 Features Demonstrated:')
	println('  ✓ Timeout configuration (get/set)')
	println('  ✓ wait_until_present() - Element in DOM')
	println('  ✓ wait_until_visible() - Element visible')
	println('  ✓ wait_until_clickable() - Element interactive')
	println('  ✓ wait_for_text_in_element() - Text appears')
	println('  ✓ Timeout error handling')
	println('  ✓ Combined wait strategies')
	println('\nBenefits:')
	println('  • More reliable tests (no race conditions)')
	println('  • Better error messages on failure')
	println('  • Common Selenium patterns now available')
	println('  • Configurable timeouts for all scenarios')
}

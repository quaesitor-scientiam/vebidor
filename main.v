module main

import webdriver

fn main() {
	run() or {
		eprintln('WebDriver failed: ${err}')
		exit(1)
	}
}

fn run() ! {
	println('========================================')
	println('v-webdriver v2.0.0 - Feature Showcase')
	println('85% Selenium Feature Parity')
	println('========================================\n')

	mut caps := webdriver.Capabilities{
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
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	println('✓ WebDriver session created\n')

	// Configure timeouts (Phase 4)
	wd.set_implicit_wait(10000)!
	wd.set_page_load_timeout(30000)!
	println('✓ Timeouts configured (Phase 4)')

	// Navigate to page
	wd.get('https://example.com')!
	println('✓ Navigated to example.com')

	// Get page information (Phase 3)
	title := wd.get_title()!
	url := wd.get_current_url()!
	println('\nPage Information (Phase 3):')
	println('  Title: "${title}"')
	println('  URL: ${url}')

	// Find and inspect element (Phase 1)
	heading := wd.find_element('css selector', 'h1')!
	text := wd.get_text(heading)!
	tag := wd.get_tag_name(heading)!
	visible := wd.is_displayed(heading)!
	println('\nElement Properties (Phase 1):')
	println('  Tag: <${tag}>')
	println('  Text: "${text}"')
	println('  Visible: ${visible}')

	// Window management (Phase 4)
	wd.maximize_window()!
	println('\nWindow Management (Phase 4):')
	println('  ✓ Window maximized')

	// Create new tab and switch (Phase 4)
	new_tab := wd.new_window('tab')!
	println('  ✓ New tab created: ${new_tab.handle[..8]}...')

	wd.switch_to_window(new_tab.handle)!
	wd.get('https://www.iana.org/domains/reserved')!
	new_title := wd.get_title()!
	println('  ✓ Switched to new tab: "${new_title}"')

	// JavaScript execution
	result := wd.execute_script('return 2 + 2', [])!
	println('\nJavaScript Execution:')
	println('  2 + 2 = ${result.int()}')

	// Take screenshot
	screenshot := wd.screenshot()!
	println('\nScreenshot:')
	println('  ✓ Captured (${screenshot.len} bytes, base64)')

	println('\n========================================')
	println('✅ All v2.0.0 Features Demonstrated!')
	println('========================================')
	println('\nFeatures shown:')
	println('  ✓ Phase 1: Element Properties')
	println('  ✓ Phase 2: Alert Handling (see example_phase2.v)')
	println('  ✓ Phase 3: Page Information')
	println('  ✓ Phase 4: Window & Waits')
	println('\nSee example_phase1.v through example_phase4.v')
	println('for comprehensive demonstrations of each phase.')
}

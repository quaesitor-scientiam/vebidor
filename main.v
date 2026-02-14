module main

import webdriver

fn main() {
	run() or {
		eprintln('WebDriver failed: $err')
		exit(1)
	}
}

fn run() ! {
	mut caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: [
				'--headless=new',
				'--disable-gpu',
				'--disable-dev-shm-usage',
				'--no-sandbox',
				'--log-level=3'  // Suppress most warnings
			]
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	wd.get('https://example.com')!

	// Find the heading element
	heading := wd.find_element('css selector', 'h1')!
	println('Found heading element: ${heading.element_id}')

	// Get the page title
	title := wd.execute_script('return document.title', [])!
	println('Page title: ${title}')

	println('WebDriver test successful!')
}

// Dummy test function to satisfy V's test file detection
fn test_dummy() {
	// This file is not a test file, but V requires this
	// when test files exist in the same project
}

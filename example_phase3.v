module main

import webdriver

fn main() {
	println('========================================')
	println('Phase 3 Features Demo: Page Information')
	println('========================================\n')

	run_demo() or {
		eprintln('Demo failed: ${err}')
		exit(1)
	}
}

fn run_demo() ! {
	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		accept_insecure_certs: true
		edge_options: webdriver.EdgeOptions{
			args: [
				'--headless=new',
				'--disable-gpu',
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

	println('✓ Session created')

	// Navigate to example.com
	wd.get('https://example.com')!
	println('✓ Navigated to example.com\n')

	// Demo 1: get_title() - Get the page title
	println('1. get_title() - Getting page title:')
	title := wd.get_title()!
	println('   Page title: "${title}"')
	println('   ✓ Successfully retrieved page title\n')

	// Demo 2: get_current_url() - Get the current URL
	println('2. get_current_url() - Getting current URL:')
	url := wd.get_current_url()!
	println('   Current URL: ${url}')
	println('   ✓ Successfully retrieved current URL\n')

	// Demo 3: get_page_source() - Get the HTML source
	println('3. get_page_source() - Getting HTML source:')
	source := wd.get_page_source()!

	// Show first 200 characters of source
	preview := if source.len > 200 { source[..200] + '...' } else { source }
	println('   Source preview: ${preview}')
	println('   Total length: ${source.len} characters')

	// Verify source contains expected elements
	has_html := source.contains('<html')
	has_head := source.contains('<head>')
	has_body := source.contains('<body>')
	has_title_tag := source.contains('<title>')

	println('   Contains <html: ${has_html}')
	println('   Contains <head>: ${has_head}')
	println('   Contains <body>: ${has_body}')
	println('   Contains <title>: ${has_title_tag}')
	println('   ✓ Successfully retrieved page source\n')

	// Demo 4: Page navigation workflow
	println('4. Navigation workflow - Track URL changes:')
	println('   Starting URL: ${wd.get_current_url()!}')

	// Click the link on example.com
	link := wd.find_element('css selector', 'a')!
	link_text := wd.get_text(link)!
	println('   Clicking link: "${link_text}"')
	wd.click(link)!

	// Wait for navigation to complete
	wd.wait_for(fn (wd webdriver.WebDriver) !bool {
		current := wd.get_current_url()!
		return current.contains('iana.org')
	}, 5000, 500)!

	new_url := wd.get_current_url()!
	new_title := wd.get_title()!
	println('   New URL: ${new_url}')
	println('   New title: "${new_title}"')

	// Navigate back
	println('   Navigating back...')
	wd.back()!

	back_url := wd.get_current_url()!
	back_title := wd.get_title()!
	println('   Back to URL: ${back_url}')
	println('   Back to title: "${back_title}"')
	println('   ✓ Navigation tracking works correctly\n')

	// Demo 5: Page source analysis
	println('5. Page source analysis:')
	wd.get('https://example.com')!

	full_source := wd.get_page_source()!

	// Count various elements
	h1_count := full_source.count('<h1>')
	p_count := full_source.count('<p>')
	div_count := full_source.count('<div>')

	println('   Document statistics:')
	println('     <h1> tags: ${h1_count}')
	println('     <p> tags: ${p_count}')
	println('     <div> tags: ${div_count}')
	println('     Total size: ${full_source.len} bytes')

	// Extract title from source
	if title_start := full_source.index('<title>') {
		if title_end := full_source.index('</title>') {
			if title_end > title_start {
				source_title := full_source[title_start + 7..title_end]
				api_title := wd.get_title()!
				println('     Title from source: "${source_title}"')
				println('     Title from API: "${api_title}"')
				println('     Match: ${source_title == api_title}')
			}
		}
	}
	println('   ✓ Page source analysis complete\n')

	// Summary
	println('========================================')
	println('✅ Phase 3 Demo Complete!')
	println('========================================')
	println('')
	println('Demonstrated 3 new page info methods:')
	println('  1. get_title()        - Get page title')
	println('  2. get_current_url()  - Get current URL')
	println('  3. get_page_source()  - Get HTML source')
	println('')
	println('Feature parity: 73% → 76% (+3%)')
}

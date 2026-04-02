module main

import vebidor {webdriver}


fn main() {
	println('========================================')
	println('Phase 1 Features Demo: Element Properties')
	println('========================================\n')

	run_demo() or {
		eprintln('Demo failed: ${err}')
		exit(1)
	}
}

fn run_demo() ! {
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

	wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or { eprintln('Failed to quit: ${err}') }
	}

	println('✓ Session created')

	// Navigate to example.com
	wd.get('https://example.com')!
	println('✓ Navigated to example.com\n')

	// Demonstrate get_text()
	println('1. Getting element text:')
	heading := wd.find_element('css selector', 'h1')!
	text := wd.get_text(heading)!
	println('   H1 text: "${text}"')

	// Demonstrate get_tag_name()
	println('\n2. Getting tag name:')
	tag := wd.get_tag_name(heading)!
	println('   Tag name: ${tag}')

	// Demonstrate get_attribute()
	println('\n3. Getting attributes:')
	link := wd.find_element('css selector', 'a')!
	href := wd.get_attribute(link, 'href')!
	println('   Link href: ${href}')

	link_text := wd.get_text(link)!
	println('   Link text: "${link_text}"')

	// Demonstrate is_displayed()
	println('\n4. Checking if elements are displayed:')
	h1_visible := wd.is_displayed(heading)!
	println('   H1 visible: ${h1_visible}')

	link_visible := wd.is_displayed(link)!
	println('   Link visible: ${link_visible}')

	// Demonstrate is_enabled()
	println('\n5. Checking if elements are enabled:')
	link_enabled := wd.is_enabled(link)!
	println('   Link enabled: ${link_enabled}')

	// Create an input field to demonstrate clear() and get_property()
	println('\n6. Working with input fields:')
	wd.execute_script('
		const input = document.createElement("input");
		input.id = "demo-input";
		input.type = "text";
		input.value = "Initial value";
		input.placeholder = "Enter text here";
		document.body.appendChild(input);
	',
		[])!

	input := wd.find_element('css selector', '#demo-input')!

	// Get property
	initial_value := wd.get_property(input, 'value')!
	println('   Initial value: "${initial_value}"')

	placeholder := wd.get_attribute(input, 'placeholder')!
	println('   Placeholder: "${placeholder}"')

	// Clear the input
	wd.clear(input)!
	cleared_value := wd.get_property(input, 'value')!
	println('   After clear: "${cleared_value}"')

	// Send new text
	wd.send_keys(input, 'New text entered!')!
	new_value := wd.get_property(input, 'value')!
	println('   After typing: "${new_value}"')

	// Demonstrate is_selected() with checkbox
	println('\n7. Working with checkboxes:')
	wd.execute_script('
		const checkbox = document.createElement("input");
		checkbox.id = "demo-checkbox";
		checkbox.type = "checkbox";
		const label = document.createElement("label");
		label.textContent = "Accept terms";
		document.body.appendChild(checkbox);
		document.body.appendChild(label);
	',
		[])!

	checkbox := wd.find_element('css selector', '#demo-checkbox')!

	selected_before := wd.is_selected(checkbox)!
	println('   Checkbox selected before click: ${selected_before}')

	wd.click(checkbox)!

	selected_after := wd.is_selected(checkbox)!
	println('   Checkbox selected after click: ${selected_after}')

	// Summary
	println('\n========================================')
	println('✅ All Phase 1 features working!')
	println('========================================')
	println('\nNew methods demonstrated:')
	println('  • get_text() - Get element text content')
	println('  • get_attribute() - Get HTML attributes')
	println('  • get_property() - Get DOM properties')
	println('  • get_tag_name() - Get element tag name')
	println('  • is_displayed() - Check visibility')
	println('  • is_enabled() - Check if enabled')
	println('  • is_selected() - Check if selected')
	println('  • clear() - Clear input fields')
}

// Dummy test function
fn test_dummy() {}

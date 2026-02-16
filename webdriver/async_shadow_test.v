module webdriver

import x.json2 as json
import time

// Helper function to set up a test driver
fn setup_test_driver() !WebDriver {
	caps := Capabilities{
		browser_name: 'msedge'
		edge_options: EdgeOptions{
			args:   ['--headless=new', '--disable-gpu']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	wd := new_edge_driver('http://127.0.0.1:9515', caps)!
	return wd
}

fn test_execute_async_script_simple() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Simple async script with setTimeout
	script := 'var callback = arguments[arguments.length - 1]; setTimeout(function() { callback("async result"); }, 100);'
	result := wd.execute_async_script(script, []) or {
		eprintln('Failed to execute async script: ${err}')
		assert false
		return
	}

	println('✓ test_execute_async_script_simple: ${result}')
	assert result.str() == 'async result'
}

fn test_execute_async_script_with_args() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Async script that uses arguments
	script := '
		var value = arguments[0];
		var callback = arguments[arguments.length - 1];
		setTimeout(function() {
			callback(value * 2);
		}, 100);
	'

	result := wd.execute_async_script(script, [json.Any(42)]) or {
		eprintln('Failed to execute async script with args: ${err}')
		assert false
		return
	}

	println('✓ test_execute_async_script_with_args: ${result}')
	assert result.int() == 84
}

fn test_execute_async_script_promise() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Load a page first
	test_html := '<!DOCTYPE html><html><body>Test Page</body></html>'
	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Async script using Promise
	script := '
		var callback = arguments[arguments.length - 1];
		new Promise(function(resolve) {
			setTimeout(function() {
				resolve("promise result");
			}, 100);
		}).then(callback);
	'

	result := wd.execute_async_script(script, []) or {
		eprintln('Failed to execute async script with promise: ${err}')
		assert false
		return
	}

	println('✓ test_execute_async_script_promise: ${result}')
	assert result.str() == 'promise result'
}

fn test_execute_async_script_dom_operation() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Load a page with an element
	test_html := '<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body>
	<div id="content">Initial</div>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Async script that modifies DOM and returns the result
	script := '
		var callback = arguments[arguments.length - 1];
		setTimeout(function() {
			var el = document.getElementById("content");
			el.textContent = "Updated";
			callback(el.textContent);
		}, 100);
	'

	result := wd.execute_async_script(script, []) or {
		eprintln('Failed to execute async DOM script: ${err}')
		assert false
		return
	}

	println('✓ test_execute_async_script_dom_operation: ${result}')
	assert result.str() == 'Updated'
}

fn test_shadow_root_basic() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a page with Shadow DOM
	test_html := '<!DOCTYPE html>
<html>
<head><title>Shadow DOM Test</title></head>
<body>
	<div id="host"></div>
	<script>
		var host = document.getElementById("host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = "<p id=\\"shadow-para\\">Shadow DOM Content</p>";
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Give the script time to execute
	time.sleep(500 * time.millisecond)

	// Get the host element
	host := wd.find_element('css selector', '#host') or {
		eprintln('Failed to find host element: ${err}')
		assert false
		return
	}

	// Get the shadow root
	shadow := wd.get_shadow_root(host) or {
		eprintln('Failed to get shadow root: ${err}')
		assert false
		return
	}

	println('✓ test_shadow_root_basic: shadow_id=${shadow.shadow_id}')
	assert shadow.shadow_id.len > 0
}

fn test_find_element_in_shadow_root() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a page with Shadow DOM
	test_html := '<!DOCTYPE html>
<html>
<head><title>Shadow DOM Test</title></head>
<body>
	<div id="host"></div>
	<script>
		var host = document.getElementById("host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<style>
				p { color: red; }
			</style>
			<p id="shadow-para">Shadow Content</p>
			<button id="shadow-btn">Shadow Button</button>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Give the script time to execute
	time.sleep(500 * time.millisecond)

	// Get the shadow root
	host := wd.find_element('css selector', '#host') or {
		eprintln('Failed to find host: ${err}')
		assert false
		return
	}

	shadow := wd.get_shadow_root(host) or {
		eprintln('Failed to get shadow root: ${err}')
		assert false
		return
	}

	// Find element within shadow root
	shadow_para := wd.find_element_in_shadow_root(shadow, 'css selector', '#shadow-para') or {
		eprintln('Failed to find element in shadow root: ${err}')
		assert false
		return
	}

	// Get text from shadow DOM element
	text := wd.get_text(shadow_para) or {
		eprintln('Failed to get text from shadow element: ${err}')
		assert false
		return
	}

	println('✓ test_find_element_in_shadow_root: ${text}')
	assert text == 'Shadow Content'
}

fn test_find_elements_in_shadow_root() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a page with Shadow DOM containing multiple elements
	test_html := '<!DOCTYPE html>
<html>
<head><title>Shadow DOM Test</title></head>
<body>
	<div id="host"></div>
	<script>
		var host = document.getElementById("host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<ul>
				<li class="item">Item 1</li>
				<li class="item">Item 2</li>
				<li class="item">Item 3</li>
			</ul>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Give the script time to execute
	time.sleep(500 * time.millisecond)

	// Get the shadow root
	host := wd.find_element('css selector', '#host') or {
		eprintln('Failed to find host: ${err}')
		assert false
		return
	}

	shadow := wd.get_shadow_root(host) or {
		eprintln('Failed to get shadow root: ${err}')
		assert false
		return
	}

	// Find all elements within shadow root
	items := wd.find_elements_in_shadow_root(shadow, 'css selector', '.item') or {
		eprintln('Failed to find elements in shadow root: ${err}')
		assert false
		return
	}

	println('✓ test_find_elements_in_shadow_root: found ${items.len} items')
	assert items.len == 3
}

fn test_shadow_root_interaction() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a page with interactive Shadow DOM
	test_html :=
		'<!DOCTYPE html>
<html>
<head><title>Shadow DOM Test</title></head>
<body>
	<div id="host"></div>
	<script>
		var host = document.getElementById("host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<button id="shadow-btn">Click Me</button>
			<div id="result">Not clicked</div>
			<scr' +
		'ipt>
				shadowRoot.getElementById("shadow-btn").addEventListener("click", function() {
					shadowRoot.getElementById("result").textContent = "Clicked!";
				});
			</scr' +
		'ipt>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Give the script time to execute
	time.sleep(500 * time.millisecond)

	// Get the shadow root
	host := wd.find_element('css selector', '#host') or {
		eprintln('Failed to find host: ${err}')
		assert false
		return
	}

	shadow := wd.get_shadow_root(host) or {
		eprintln('Failed to get shadow root: ${err}')
		assert false
		return
	}

	// Find and click button in shadow root
	button := wd.find_element_in_shadow_root(shadow, 'css selector', '#shadow-btn') or {
		eprintln('Failed to find button in shadow root: ${err}')
		assert false
		return
	}

	wd.click(button) or {
		eprintln('Failed to click shadow button: ${err}')
		assert false
		return
	}

	// Wait a moment for the click to register
	time.sleep(300 * time.millisecond)

	// Check the result
	result := wd.find_element_in_shadow_root(shadow, 'css selector', '#result') or {
		eprintln('Failed to find result in shadow root: ${err}')
		assert false
		return
	}

	text := wd.get_text(result) or {
		eprintln('Failed to get text from result: ${err}')
		assert false
		return
	}

	println('✓ test_shadow_root_interaction: ${text}')
	assert text == 'Clicked!'
}

fn test_nested_shadow_roots() {
	wd := setup_test_driver() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	// Create a page with nested Shadow DOM
	test_html := '<!DOCTYPE html>
<html>
<head><title>Nested Shadow DOM Test</title></head>
<body>
	<div id="outer-host"></div>
	<script>
		var outerHost = document.getElementById("outer-host");
		var outerShadow = outerHost.attachShadow({mode: "open"});
		outerShadow.innerHTML = `
			<p>Outer Shadow</p>
			<div id="inner-host"></div>
		`;

		var innerHost = outerShadow.getElementById("inner-host");
		var innerShadow = innerHost.attachShadow({mode: "open"});
		innerShadow.innerHTML = `
			<p id="inner-para">Inner Shadow Content</p>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}') or {
		eprintln('Failed to load page: ${err}')
		assert false
		return
	}

	// Give the script time to execute
	time.sleep(500 * time.millisecond)

	// Get outer shadow root
	outer_host := wd.find_element('css selector', '#outer-host') or {
		eprintln('Failed to find outer host: ${err}')
		assert false
		return
	}

	outer_shadow := wd.get_shadow_root(outer_host) or {
		eprintln('Failed to get outer shadow root: ${err}')
		assert false
		return
	}

	// Find inner host within outer shadow
	inner_host := wd.find_element_in_shadow_root(outer_shadow, 'css selector', '#inner-host') or {
		eprintln('Failed to find inner host: ${err}')
		assert false
		return
	}

	// Get inner shadow root
	inner_shadow := wd.get_shadow_root(inner_host) or {
		eprintln('Failed to get inner shadow root: ${err}')
		assert false
		return
	}

	// Find element in nested shadow
	inner_para := wd.find_element_in_shadow_root(inner_shadow, 'css selector', '#inner-para') or {
		eprintln('Failed to find inner para: ${err}')
		assert false
		return
	}

	text := wd.get_text(inner_para) or {
		eprintln('Failed to get text from nested shadow: ${err}')
		assert false
		return
	}

	println('✓ test_nested_shadow_roots: ${text}')
	assert text == 'Inner Shadow Content'
}

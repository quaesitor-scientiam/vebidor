module main

import webdriver
import x.json2 as json
import time

fn main() {
	println('========================================')
	println('Phase 8 Features Demo: Async JS & Shadow DOM')
	println('========================================\n')

	run_demo() or {
		eprintln('Demo failed: ${err}')
		exit(1)
	}

	println('\n✓ All Phase 8 demonstrations completed successfully!')
}

fn run_demo() ! {
	// Setup driver
	println('[1/8] Setting up WebDriver...')
	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		edge_options: webdriver.EdgeOptions{
			args:   ['--headless=new', '--disable-gpu']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	mut wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	// Demo 1: Simple Async Script
	println('\n[2/8] Demo 1: Execute async script with setTimeout')
	println('───────────────────────────────────────────────────')

	script1 := 'var callback = arguments[arguments.length - 1]; setTimeout(function() { callback("Async operation complete!"); }, 200);'
	result1 := wd.execute_async_script(script1, [])!
	println('  Result: ${result1}')

	// Demo 2: Async Script with Arguments
	println('\n[3/8] Demo 2: Async script with arguments')
	println('──────────────────────────────────────────')

	script2 := '
		var multiplier = arguments[0];
		var number = arguments[1];
		var callback = arguments[arguments.length - 1];
		setTimeout(function() {
			callback(multiplier * number);
		}, 200);
	'
	result2 := wd.execute_async_script(script2, [json.Any(3), json.Any(14)])!
	println('  Input: 3 * 14')
	println('  Result: ${result2}')

	// Demo 3: Async Script with Promise
	println('\n[4/8] Demo 3: Async script using Promise')
	println('─────────────────────────────────────────')

	// Load a test page first
	test_html1 := '<!DOCTYPE html><html><head><title>Async Test</title></head><body><h1>Async Demo Page</h1></body></html>'
	wd.get('data:text/html;charset=utf-8,${test_html1}')!

	script3 := '
		var callback = arguments[arguments.length - 1];
		fetch("https://jsonplaceholder.typicode.com/users/1")
			.then(response => response.json())
			.then(data => callback(data.name))
			.catch(err => callback("Error: " + err));
	'

	// Note: This may fail in headless mode without network, so we'll use a simpler promise
	script3_simple := '
		var callback = arguments[arguments.length - 1];
		new Promise(function(resolve) {
			setTimeout(function() {
				resolve("Promise resolved successfully");
			}, 200);
		}).then(callback);
	'

	result3 := wd.execute_async_script(script3_simple, [])!
	println('  Result: ${result3}')

	// Demo 4: Async Script with DOM Manipulation
	println('\n[5/8] Demo 4: Async script with DOM manipulation')
	println('──────────────────────────────────────────────────')

	test_html2 := '<!DOCTYPE html>
<html>
<head><title>DOM Test</title></head>
<body>
	<div id="counter">0</div>
</body>
</html>'
	wd.get('data:text/html;charset=utf-8,${test_html2}')!

	script4 := '
		var callback = arguments[arguments.length - 1];
		var counter = 0;
		var interval = setInterval(function() {
			counter++;
			document.getElementById("counter").textContent = counter;
			if (counter >= 5) {
				clearInterval(interval);
				callback("Counter reached: " + counter);
			}
		}, 50);
	'

	result4 := wd.execute_async_script(script4, [])!
	println('  Result: ${result4}')

	// Demo 5: Shadow DOM Basics
	println('\n[6/8] Demo 5: Accessing Shadow DOM')
	println('────────────────────────────────────')

	test_html3 := '<!DOCTYPE html>
<html>
<head><title>Shadow DOM Test</title></head>
<body>
	<div id="host"></div>
	<script>
		var host = document.getElementById("host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<style>
				p { color: blue; font-weight: bold; }
			</style>
			<p id="shadow-text">This content is inside Shadow DOM!</p>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html3}')!
	time.sleep(500 * time.millisecond) // Wait for script to execute

	// Get the host element
	host := wd.find_element('css selector', '#host')!
	println('  Found host element')

	// Get the shadow root
	shadow := wd.get_shadow_root(host)!
	println('  Retrieved shadow root: ${shadow.shadow_id[..20]}...')

	// Find element within shadow root
	shadow_para := wd.find_element_in_shadow_root(shadow, 'css selector', '#shadow-text')!
	shadow_text := wd.get_text(shadow_para)!
	println('  Shadow DOM text: "${shadow_text}"')

	// Demo 6: Multiple Elements in Shadow DOM
	println('\n[7/8] Demo 6: Finding multiple elements in Shadow DOM')
	println('───────────────────────────────────────────────────────')

	test_html4 := '<!DOCTYPE html>
<html>
<head><title>Shadow DOM List</title></head>
<body>
	<div id="list-host"></div>
	<script>
		var host = document.getElementById("list-host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<style>
				.item { padding: 5px; margin: 2px; background: #f0f0f0; }
			</style>
			<ul>
				<li class="item">Shadow Item 1</li>
				<li class="item">Shadow Item 2</li>
				<li class="item">Shadow Item 3</li>
				<li class="item">Shadow Item 4</li>
			</ul>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html4}')!
	time.sleep(500 * time.millisecond)

	list_host := wd.find_element('css selector', '#list-host')!
	list_shadow := wd.get_shadow_root(list_host)!

	items := wd.find_elements_in_shadow_root(list_shadow, 'css selector', '.item')!
	println('  Found ${items.len} items in shadow root')

	for i, item in items {
		item_text := wd.get_text(item)!
		println('  Item ${i + 1}: ${item_text}')
	}

	// Demo 7: Interactive Shadow DOM
	println('\n[8/8] Demo 7: Interacting with Shadow DOM elements')
	println('───────────────────────────────────────────────────')

	test_html5 := '<!DOCTYPE html>
<html>
<head><title>Interactive Shadow DOM</title></head>
<body>
	<div id="interactive-host"></div>
	<script>
		var host = document.getElementById("interactive-host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<style>
				button { padding: 10px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; }
				#result { margin-top: 10px; font-weight: bold; }
			</style>
			<button id="shadow-btn">Click Me!</button>
			<div id="result">Not clicked yet</div>
		`;

		shadowRoot.getElementById("shadow-btn").addEventListener("click", function() {
			shadowRoot.getElementById("result").textContent = "Button clicked successfully!";
		});
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html5}')!
	time.sleep(500 * time.millisecond)

	interactive_host := wd.find_element('css selector', '#interactive-host')!
	interactive_shadow := wd.get_shadow_root(interactive_host)!

	// Find button and result in shadow DOM
	shadow_btn := wd.find_element_in_shadow_root(interactive_shadow, 'css selector', '#shadow-btn')!
	result_div := wd.find_element_in_shadow_root(interactive_shadow, 'css selector', '#result')!

	// Check initial state
	initial_text := wd.get_text(result_div)!
	println('  Initial state: "${initial_text}"')

	// Click the button in shadow DOM
	wd.click(shadow_btn)!
	time.sleep(300 * time.millisecond)

	// Check updated state
	updated_text := wd.get_text(result_div)!
	println('  After click: "${updated_text}"')

	// Demo 8: Combining Async + Shadow DOM
	println('\n[Bonus] Combining async script with Shadow DOM')
	println('────────────────────────────────────────────────')

	test_html6 := '<!DOCTYPE html>
<html>
<head><title>Combined Test</title></head>
<body>
	<div id="combined-host"></div>
	<script>
		var host = document.getElementById("combined-host");
		var shadowRoot = host.attachShadow({mode: "open"});
		shadowRoot.innerHTML = `
			<div id="async-result">Waiting...</div>
		`;
	</script>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html6}')!
	time.sleep(500 * time.millisecond)

	// Use async script to modify shadow DOM content
	combined_host := wd.find_element('css selector', '#combined-host')!
	combined_shadow := wd.get_shadow_root(combined_host)!

	async_script := '
		var shadowHost = arguments[0];
		var callback = arguments[arguments.length - 1];

		setTimeout(function() {
			var shadowRoot = shadowHost.shadowRoot;
			var resultDiv = shadowRoot.getElementById("async-result");
			resultDiv.textContent = "Async operation modified Shadow DOM!";
			callback(resultDiv.textContent);
		}, 200);
	'

	combined_result := wd.execute_async_script(async_script, [
		json.Any(json.encode(combined_host)),
	])!
	println('  Async script result: ${combined_result}')

	// Verify the change
	async_result_div := wd.find_element_in_shadow_root(combined_shadow, 'css selector',
		'#async-result')!
	final_text := wd.get_text(async_result_div)!
	println('  Shadow DOM content: "${final_text}"')

	println('\n✓ Phase 8 async JavaScript and Shadow DOM demonstration complete!')
}

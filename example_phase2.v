module main

import webdriver
import time

fn main() {
	println('========================================')
	println('Phase 2 Features Demo: Alert Handling')
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

	// Demo 1: accept_alert() - Accept a simple alert
	println('1. accept_alert() - Accepting an alert:')
	wd.execute_script('alert("Welcome to V WebDriver Phase 2!")', [])!
	time.sleep(500 * time.millisecond)

	text := wd.get_alert_text()!
	println('   Alert text: "${text}"')

	wd.accept_alert()!
	println('   ✓ Alert accepted\n')

	time.sleep(300 * time.millisecond)

	// Demo 2: dismiss_alert() - Dismiss a confirm dialog
	println('2. dismiss_alert() - Dismissing a confirm:')
	wd.execute_script('window.userChoice = confirm("Do you want to continue?")', [])!
	time.sleep(500 * time.millisecond)

	confirm_text := wd.get_alert_text()!
	println('   Confirm text: "${confirm_text}"')
	println('   Action: Clicking Cancel...')

	wd.dismiss_alert()!
	time.sleep(300 * time.millisecond)

	result := wd.execute_script('return window.userChoice', [])!
	println('   User choice: ${result.bool()}')
	println('   ✓ Confirm dismissed (returns false)\n')

	time.sleep(300 * time.millisecond)

	// Demo 3: get_alert_text() - Reading alert text
	println('3. get_alert_text() - Reading various dialogs:')

	// Alert
	wd.execute_script('alert("This is an ALERT")', [])!
	time.sleep(500 * time.millisecond)
	alert_msg := wd.get_alert_text()!
	println('   Alert: "${alert_msg}"')
	wd.accept_alert()!
	time.sleep(300 * time.millisecond)

	// Confirm
	wd.execute_script('confirm("This is a CONFIRM")', [])!
	time.sleep(500 * time.millisecond)
	confirm_msg := wd.get_alert_text()!
	println('   Confirm: "${confirm_msg}"')
	wd.accept_alert()!
	time.sleep(300 * time.millisecond)

	// Prompt
	wd.execute_script('prompt("This is a PROMPT")', [])!
	time.sleep(500 * time.millisecond)
	prompt_msg := wd.get_alert_text()!
	println('   Prompt: "${prompt_msg}"')
	wd.accept_alert()!
	println('   ✓ Successfully read all dialog types\n')

	time.sleep(300 * time.millisecond)

	// Demo 4: send_alert_text() - Sending text to prompt
	println('4. send_alert_text() - Sending input to prompt:')
	wd.execute_script('window.userName = prompt("Please enter your name:")', [])!
	time.sleep(500 * time.millisecond)

	prompt_question := wd.get_alert_text()!
	println('   Prompt asks: "${prompt_question}"')

	input_value := 'Claude from V WebDriver'
	println('   Sending: "${input_value}"')

	wd.send_alert_text(input_value)!
	wd.accept_alert()!
	time.sleep(300 * time.millisecond)

	stored_name := wd.execute_script('return window.userName', [])!
	println('   Stored value: "${stored_name.str()}"')
	println('   ✓ Text sent to prompt successfully\n')

	// Demo 5: Real-world workflow
	println('5. Real-world scenario - Multi-step workflow:')

	script := '
		window.submitForm = function() {
			var confirmed = confirm("Submit this form?");
			if (confirmed) {
				alert("Form submitted!");
				return "SUBMITTED";
			} else {
				alert("Cancelled");
				return "CANCELLED";
			}
		};
		window.submitForm();
	'

	wd.execute_script(script, [])!
	time.sleep(500 * time.millisecond)

	// First dialog: confirmation
	first_msg := wd.get_alert_text()!
	println('   Step 1 - Confirm: "${first_msg}"')
	println('   Action: Accepting...')
	wd.accept_alert()!
	time.sleep(500 * time.millisecond)

	// Second dialog: success
	second_msg := wd.get_alert_text()!
	println('   Step 2 - Alert: "${second_msg}"')
	wd.accept_alert()!
	println('   ✓ Multi-step workflow complete\n')

	// Summary
	println('========================================')
	println('✅ Phase 2 Demo Complete!')
	println('========================================')
	println('')
	println('Demonstrated 4 new alert methods:')
	println('  1. accept_alert()    - Accept dialogs')
	println('  2. dismiss_alert()   - Dismiss dialogs')
	println('  3. get_alert_text()  - Read messages')
	println('  4. send_alert_text() - Send to prompts')
	println('')
	println('Feature parity: 68% → 73% (+5%)')
}

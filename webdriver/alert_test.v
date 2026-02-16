module webdriver

import time
import x.json2 as json

fn setup_test_driver() !WebDriver {
	caps := Capabilities{
		browser_name:          'msedge'
		accept_insecure_certs: true
		edge_options:          EdgeOptions{
			args:   [
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

// Test accept_alert() - Accept a simple alert dialog
fn test_accept_alert() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	// Navigate to a page
	wd.get('https://example.com')!

	// Trigger an alert using JavaScript
	wd.execute_script('alert("Test Alert Message")', [])!

	// Small delay to ensure alert is present
	time.sleep(500 * time.millisecond)

	// Get the alert text to verify it's there
	text := wd.get_alert_text()!
	assert text == 'Test Alert Message', 'Alert text should match'

	// Accept the alert
	wd.accept_alert()!

	println('✓ accept_alert() test passed')
}

// Test dismiss_alert() - Dismiss a confirm dialog
fn test_dismiss_alert() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Trigger a confirm dialog
	wd.execute_script('confirm("Are you sure?")', [])!

	time.sleep(500 * time.millisecond)

	// Verify alert is present
	text := wd.get_alert_text()!
	assert text == 'Are you sure?', 'Confirm text should match'

	// Dismiss the alert (click Cancel)
	wd.dismiss_alert()!

	println('✓ dismiss_alert() test passed')
}

// Test get_alert_text() - Get text from various dialog types
fn test_get_alert_text() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Test with alert
	wd.execute_script('alert("Hello, World!")', [])!
	time.sleep(500 * time.millisecond)

	text := wd.get_alert_text()!
	assert text == 'Hello, World!', 'Should get correct alert text'

	wd.accept_alert()!

	// Test with confirm
	wd.execute_script('confirm("Proceed?")', [])!
	time.sleep(500 * time.millisecond)

	text2 := wd.get_alert_text()!
	assert text2 == 'Proceed?', 'Should get correct confirm text'

	wd.accept_alert()!

	println('✓ get_alert_text() test passed')
}

// Test send_alert_text() - Send text to a prompt dialog
fn test_send_alert_text() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Create a prompt dialog with JavaScript
	wd.execute_script('window.promptResult = prompt("Enter your name:")', [])!
	time.sleep(500 * time.millisecond)

	// Verify prompt text
	text := wd.get_alert_text()!
	assert text == 'Enter your name:', 'Prompt text should match'

	// Send text to the prompt
	wd.send_alert_text('Claude')!

	// Accept the prompt
	wd.accept_alert()!

	time.sleep(500 * time.millisecond)

	// Verify the result was stored
	result := wd.execute_script('return window.promptResult', [])!
	assert result.str() == 'Claude', 'Prompt should receive the text'

	println('✓ send_alert_text() test passed')
}

// Test alert workflow - Complete alert handling scenario
fn test_alert_workflow() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Scenario 1: Simple alert
	wd.execute_script('alert("Step 1 complete")', [])!
	time.sleep(500 * time.millisecond)
	assert wd.get_alert_text()! == 'Step 1 complete'
	wd.accept_alert()!

	time.sleep(300 * time.millisecond)

	// Scenario 2: Confirm dialog - accept
	wd.execute_script('window.confirmResult1 = confirm("Continue?")', [])!
	time.sleep(500 * time.millisecond)
	assert wd.get_alert_text()! == 'Continue?'
	wd.accept_alert()!
	time.sleep(300 * time.millisecond)
	result1 := wd.execute_script('return window.confirmResult1', [])!
	assert result1.bool() == true, 'Accept should return true'

	// Scenario 3: Confirm dialog - dismiss
	wd.execute_script('window.confirmResult2 = confirm("Are you sure?")', [])!
	time.sleep(500 * time.millisecond)
	wd.dismiss_alert()!
	time.sleep(300 * time.millisecond)
	result2 := wd.execute_script('return window.confirmResult2', [])!
	assert result2.bool() == false, 'Dismiss should return false'

	// Scenario 4: Prompt dialog
	wd.execute_script('window.userName = prompt("Username:")', [])!
	time.sleep(500 * time.millisecond)
	wd.send_alert_text('testuser')!
	wd.accept_alert()!
	time.sleep(300 * time.millisecond)
	result3 := wd.execute_script('return window.userName', [])!
	assert result3.str() == 'testuser', 'Prompt should capture input'

	println('✓ alert_workflow() test passed')
}

// Test empty prompt - Accept without sending text
fn test_empty_prompt() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Create prompt and accept without entering text
	wd.execute_script('window.emptyResult = prompt("Enter something:")', [])!
	time.sleep(500 * time.millisecond)

	wd.accept_alert()!
	time.sleep(300 * time.millisecond)

	// Should return empty string when accepted with no input
	result := wd.execute_script('return window.emptyResult', [])!
	assert result.str() == '', 'Empty prompt should return empty string'

	println('✓ empty_prompt() test passed')
}

// Test dismissed prompt - Should return null
fn test_dismissed_prompt() ! {
	mut wd := setup_test_driver()!
	defer {
		wd.quit() or {}
	}

	wd.get('https://example.com')!

	// Create prompt and dismiss it
	wd.execute_script('window.cancelledResult = prompt("Enter value:")', [])!
	time.sleep(500 * time.millisecond)

	wd.dismiss_alert()!
	time.sleep(300 * time.millisecond)

	// Should return null when dismissed
	result := wd.execute_script('return window.cancelledResult', [])!
	// In JSON, null is represented as null
	assert result.str() == 'null' || result is json.Null, 'Dismissed prompt should return null'

	println('✓ dismissed_prompt() test passed')
}

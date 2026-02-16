module webdriver

import time

// Expected Conditions - Common wait patterns for WebDriver
// These helpers provide convenient ways to wait for specific conditions
// before proceeding with test steps, improving test reliability.

// wait_until_clickable waits for an element to be both visible and enabled
// This is the most commonly used wait condition in Selenium tests
// W3C Implementation: Combines is_displayed() and is_enabled() checks
pub fn (wd WebDriver) wait_until_clickable(using string, value string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(using, value, timeout_ms, 500, fn (wd &WebDriver, el ElementRef) !bool {
		visible := wd.is_displayed(el) or { return false }
		enabled := wd.is_enabled(el) or { return false }
		return visible && enabled
	})!
}

// wait_until_visible waits for an element to be present in the DOM and visible
// Useful when elements are loaded dynamically or become visible after page load
// W3C Implementation: Uses is_displayed() check
pub fn (wd WebDriver) wait_until_visible(using string, value string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(using, value, timeout_ms, 500, fn (wd &WebDriver, el ElementRef) !bool {
		return wd.is_displayed(el) or { false }
	})!
}

// wait_until_present waits for an element to exist in the DOM
// Doesn't check visibility - just that the element can be found
// Useful for elements that might be hidden but need to exist
// W3C Implementation: Simply waits for find_element() to succeed
pub fn (wd WebDriver) wait_until_present(using string, value string, timeout_ms int) !ElementRef {
	start := time.now()
	mut last_error := ''

	for {
		element := wd.find_element(using, value) or {
			last_error = err.msg()
			if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
				return error('Timeout waiting for element to be present (${using}: ${value}) after ${timeout_ms}ms. Last error: ${last_error}')
			}
			time.sleep(500 * time.millisecond)
			continue
		}

		return element
	}

	return error('Unreachable')
}

// wait_for_text_in_element waits for an element to contain specific text
// Case-sensitive substring match
// Useful for waiting for dynamic content to load
// W3C Implementation: Uses get_text() and string contains check
pub fn (wd WebDriver) wait_for_text_in_element(using string, value string, text string, timeout_ms int) !ElementRef {
	return wd.wait_for_condition(using, value, timeout_ms, 500, fn [text] (wd &WebDriver, el ElementRef) !bool {
		elem_text := wd.get_text(el) or { return false }
		return elem_text.contains(text)
	})!
}

// wait_for_condition is a generic helper for custom wait conditions
// Allows building custom expected conditions with any boolean check
// This is a lower-level helper used by the other wait methods
fn (wd WebDriver) wait_for_condition(using string, value string, timeout_ms int, interval_ms int, condition fn (wd &WebDriver, el ElementRef) !bool) !ElementRef {
	start := time.now()
	mut last_error := ''

	for {
		// Try to find the element
		element := wd.find_element(using, value) or {
			last_error = 'Element not found: ${err.msg()}'
			if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
				return error('Timeout waiting for element (${using}: ${value}) after ${timeout_ms}ms. ${last_error}')
			}
			time.sleep(interval_ms * time.millisecond)
			continue
		}

		// Check if condition is met
		condition_met := condition(&wd, element) or {
			last_error = 'Condition check failed: ${err.msg()}'
			false
		}

		if condition_met {
			return element
		}

		// Check timeout
		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('Timeout waiting for condition on element (${using}: ${value}) after ${timeout_ms}ms. ${last_error}')
		}

		time.sleep(interval_ms * time.millisecond)
	}

	return error('Unreachable')
}

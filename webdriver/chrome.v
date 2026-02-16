module webdriver

// Create a new Chrome WebDriver session
// url: ChromeDriver endpoint (e.g., 'http://127.0.0.1:9515')
// caps: Browser capabilities including ChromeOptions
pub fn new_chrome_driver(url string, caps Capabilities) !WebDriver {
	mut final_caps := caps
	if _ := final_caps.browser_name {
		// Keep existing browser_name
	} else {
		final_caps.browser_name = 'chrome'
	}

	return new_session(url, final_caps)
}

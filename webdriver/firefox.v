module webdriver

// Create a new Firefox WebDriver session
// base_url: GeckoDriver endpoint (e.g., 'http://127.0.0.1:4444')
// caps: Browser capabilities including FirefoxOptions
pub fn new_firefox_driver(base_url string, caps Capabilities) !WebDriver {
	mut final_caps := caps
	if _ := final_caps.browser_name {
		// Keep existing browser_name
	} else {
		final_caps.browser_name = 'firefox'
	}

	return new_session(base_url, final_caps)
}

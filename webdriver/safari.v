module webdriver

// Create a new Safari WebDriver session
// base_url: SafariDriver endpoint (e.g., 'http://127.0.0.1:4445')
// caps: Browser capabilities including SafariOptions
pub fn new_safari_driver(base_url string, caps Capabilities) !WebDriver {
	mut final_caps := caps
	if _ := final_caps.browser_name {
		// Keep existing browser_name
	} else {
		final_caps.browser_name = 'safari'
	}

	return new_session(base_url, final_caps)
}

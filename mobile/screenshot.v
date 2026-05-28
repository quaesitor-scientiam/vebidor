module mobile

import encoding.base64
import os

// capture_screenshot returns the current screen as a base64-encoded PNG
// string, exactly as WDA serves it. Mirrors `webdriver.WebDriver.screenshot`
// for the mobile side.
pub fn (s MobileSession) capture_screenshot() !string {
	resp := s.get_request[string]('/session/${s.session_id}/screenshot')!
	return resp.value
}

// save_screenshot grabs a screenshot and writes it to `path` as a PNG.
pub fn (s MobileSession) save_screenshot(path string) ! {
	b64 := s.capture_screenshot()!
	data := base64.decode(b64)
	mut f := os.create(path)!
	defer {
		f.close()
	}
	f.write(data)!
}

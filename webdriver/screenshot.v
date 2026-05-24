module webdriver

import os
import encoding.base64

// screenshot captures the current viewport as a base64-encoded PNG.
// W3C Endpoint: GET /session/{session id}/screenshot
pub fn (wd WebDriver) screenshot() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/screenshot')!
	return resp.value
}

// element_screenshot captures a single element as a base64-encoded PNG.
// W3C Endpoint: GET /session/{session id}/element/{element id}/screenshot
pub fn (wd WebDriver) element_screenshot(el ElementRef) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/screenshot')!
	return resp.value
}

// save_screenshot captures the viewport and writes it to a PNG file.
pub fn (wd WebDriver) save_screenshot(path string) ! {
	save_png_base64(path, wd.screenshot()!)!
}

// save_png_base64 decodes a base64 PNG payload and writes it to disk.
fn save_png_base64(path string, b64 string) ! {
	bytes := base64.decode(b64)
	os.write_file(path, bytes.bytestr())!
}

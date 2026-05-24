module webdriver

import x.json2 as json

// BiDi screenshot capture (per browsing context). Works reliably in headless
// and is the visual-capture primitive used for screenshot-on-failure and as a
// frame source for tracing.

// capture_screenshot returns a base64-encoded PNG of the given context.
pub fn (mut b BiDi) capture_screenshot(context string) !string {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	res := b.send('browsingContext.captureScreenshot', json.Any(p))!
	return (res.as_map()['data'] or { json.Any('') }).str()
}

// save_screenshot captures the context and writes it to a PNG file.
pub fn (mut b BiDi) save_screenshot(context string, path string) ! {
	write_base64_file(path, b.capture_screenshot(context)!)!
}

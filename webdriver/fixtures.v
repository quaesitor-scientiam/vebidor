module webdriver

// Test-runner fixtures: convenience wrappers that handle browser
// setup/teardown so `v test` functions stay focused on assertions.

// BrowserFn is a test body that receives a launched browser.
pub type BrowserFn = fn (mut b Browser) !

// with_browser launches a browser, runs `body`, and always closes the browser
// afterward (even if `body` errors). Any error from `body` is propagated.
pub fn with_browser(kind BrowserKind, opts LaunchOptions, body BrowserFn) ! {
	mut b := launch(kind, opts)!
	defer {
		b.close()
	}
	body(mut b)!
}

// with_edge is with_browser specialized to Edge.
pub fn with_edge(opts LaunchOptions, body BrowserFn) ! {
	with_browser(.edge, opts, body)!
}

// run_or_screenshot runs `body`; on failure it saves a screenshot to `path`
// (best effort) and re-raises the error — handy for debugging failed tests.
pub fn (mut b Browser) run_or_screenshot(path string, body BrowserFn) ! {
	body(mut b) or {
		b.wd.save_screenshot(path) or {}
		return err
	}
}

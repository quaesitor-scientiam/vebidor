// vebidor.mobile — native V client for WebDriverAgent (iOS) and the
// UiAutomator2 server (Android). Same wire as Appium uses (W3C JSON over
// HTTP), but talked to directly. Out-of-process, no Node hop.
//
// This is Mob-1 (foundations): module structure and the public types that
// later phases fill in. `launch_ios()` and `launch_android()` currently
// error with a pointer to MOBILE_PLAN.md.
module mobile

import vebidor.webdriver

// Platform tags a session with which mobile backend it is talking to. The
// cross-platform `get_by_*` selectors (Mob-4) dispatch on this.
pub enum Platform {
	ios
	android
}

// MobileSession is the lifetime root for a running mobile automation session
// — the equivalent of `webdriver.Browser` for the web side. Holds the
// platform, the local HTTP base URL of the backend (WDA at 8100, UiA2 at
// 6790 by default), the session id returned by the backend's `/session`
// endpoint, and the Transport used to talk to it.
//
// Shares `webdriver.Transport` with the web side so HTTP plumbing has a
// single owner.
@[heap]
pub struct MobileSession {
pub:
	platform   Platform
	base_url   string
	session_id string
	transport  webdriver.Transport = webdriver.HttpTransport{}
}

// close ends the backend session and tears down any bridge processes the
// launcher spawned. Mob-2 / Mob-3 will populate this; for now it is a
// no-op so callers can `defer s.close()` from Mob-1 onwards.
pub fn (mut s MobileSession) close() {
	// Implementation lands with the backends (Mob-2 iOS, Mob-3 Android).
}

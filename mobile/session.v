// vebidor.mobile — native V client for WebDriverAgent (iOS) and the
// UiAutomator2 server (Android). Same wire as Appium uses (W3C JSON over
// HTTP), but talked to directly. Out-of-process, no Node hop.
//
// Mob-2: iOS WDA client end-to-end (this file holds the session type; the
// HTTP wrappers live in wda.v, locator/actions in locator.v / actions.v,
// the simulator/real-device bridge in bridges_ios.v).
module mobile

import os
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
pub mut:
	// Bridge process the launcher spawned (e.g. `xcodebuild test-without-
	// building` for the iOS Simulator, `adb shell am instrument` for
	// Android). `nil` when the session was opened against an already-running
	// backend.
	bridge_proc &os.Process = unsafe { nil }
	owns_bridge bool
}

// close ends the backend session (DELETE /session/{id}) and, if the launcher
// spawned a bridge process, kills it. Idempotent — safe to defer.
pub fn (mut s MobileSession) close() {
	if s.session_id.len > 0 {
		s.delete_void('/session/${s.session_id}') or {}
	}
	if s.owns_bridge && !isnil(s.bridge_proc) {
		s.bridge_proc.signal_kill()
		s.bridge_proc.wait()
		s.bridge_proc.close()
	}
}

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
	// Bridge processes the launcher spawned. iOS Simulator adds one
	// (`xcodebuild test-without-building`); iOS real device adds two
	// (`go-ios runwda` + `go-ios forward`); Android adds one
	// (`adb shell am instrument`). Empty when the session was opened
	// against an already-running backend.
	bridge_procs []&os.Process
	owns_bridge  bool

	// Shell commands run during close() after bridge processes are killed.
	// Android uses this to release `adb forward` and force-stop the
	// UiAutomator2-server instrumentation. iOS doesn't need it.
	on_close_cmds []string
}

// close ends the backend session (DELETE /session/{id}), kills any bridge
// processes the launcher spawned, then runs the optional on_close_cmds
// (for adb forward cleanup, etc.). Idempotent — safe to defer.
pub fn (mut s MobileSession) close() {
	if s.session_id.len > 0 {
		s.delete_void('/session/${s.session_id}') or {}
	}
	if s.owns_bridge {
		for mut p in s.bridge_procs {
			p.signal_kill()
			p.wait()
			p.close()
		}
	}
	for cmd in s.on_close_cmds {
		os.execute(cmd)
	}
}

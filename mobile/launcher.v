module mobile

import os

// IOSLaunchMode selects how `launch_ios` finds (or starts) WebDriverAgent.
//
//   - `.attach`    — connect to a WDA that's already running at `wda_url`.
//                    Same behavior as Mob-2 first cut. Use this when you
//                    manage WDA yourself (CI, Appium-style setups).
//   - `.simulator` — boot the named iOS Simulator + spawn WDA via
//                    `xcodebuild test-without-building` against the
//                    provided .xctestrun. macOS host required.
//   - `.device`    — install WDA on a real iPhone via `go-ios install` (if
//                    the .ipa is provided), then `go-ios runwda` + port
//                    forward. macOS host + signed WDA .ipa required.
pub enum IOSLaunchMode {
	attach
	simulator
	device
}

// IOSOptions configures `launch_ios`.
//
// Required by mode:
//   `.attach`    — none (wda_url defaults to http://localhost:8100).
//   `.simulator` — `udid` + `wda_xctestrun`.
//   `.device`    — `udid` + `wda_ipa` (for first install).
pub struct IOSOptions {
pub:
	mode      IOSLaunchMode = .attach
	udid      string
	bundle_id string

	// Connection point. Used as-is by `.attach`; set automatically from
	// `wda_port` for the spawn modes.
	wda_url string = 'http://localhost:8100'

	// Spawn-mode configuration.
	wda_port             int = 8100
	wda_xctestrun        string // path to WebDriverAgentRunner_*.xctestrun (.simulator)
	wda_ipa              string // path to WebDriverAgentRunner.ipa        (.device)
	boot_sim             bool = true
	wda_ready_timeout_ms int  = 60_000

	// .device options
	app_path    string
	install_app bool
}

// AndroidOptions configures `launch_android`. `udid` matches what
// `adb devices` reports. `app_package` and `app_activity` identify the
// app under test; `apk_path` + `install_app` drive the install step in
// the Mob-3 lifecycle.
pub struct AndroidOptions {
pub:
	udid         string
	app_package  string
	app_activity string
	apk_path     string
	install_app  bool
}

// launch_ios opens a session against WebDriverAgent and returns a
// MobileSession. The launch mode (attach / simulator / device) controls
// whether WDA is expected to be already running or spawned by the
// launcher itself.
pub fn launch_ios(opts IOSOptions) !MobileSession {
	match opts.mode {
		.attach { return launch_ios_attach(opts) }
		.simulator { return launch_ios_simulator(opts) }
		.device { return launch_ios_device(opts) }
	}
}

// launch_ios_attach connects to an already-running WDA at `wda_url`.
fn launch_ios_attach(opts IOSOptions) !MobileSession {
	wda_url := if opts.wda_url.len > 0 { opts.wda_url } else { 'http://localhost:8100' }
	check_wda_reachable(wda_url)!
	return new_ios_session(wda_url, opts.bundle_id)
}

// launch_ios_simulator boots the named Simulator (idempotent), spawns
// `xcodebuild test-without-building`, polls /status until WDA answers,
// then opens a session. The xcodebuild process handle is stored on the
// returned MobileSession so close() kills it cleanly.
fn launch_ios_simulator(opts IOSOptions) !MobileSession {
	if opts.boot_sim {
		boot_simulator(opts.udid)!
	}
	proc := start_wda_simulator(opts.udid, opts.wda_xctestrun)!
	mut procs := [proc]

	port := if opts.wda_port > 0 { opts.wda_port } else { 8100 }
	base_url := 'http://localhost:${port}'

	wait_for_wda(base_url, opts.wda_ready_timeout_ms) or {
		kill_all(mut procs)
		return error('WDA failed to come up on ${base_url}: ${err.msg()}')
	}

	mut s := new_ios_session(base_url, opts.bundle_id) or {
		kill_all(mut procs)
		return err
	}
	s.bridge_procs = procs
	s.owns_bridge = true
	return s
}

// launch_ios_device runs `go-ios runwda` + `go-ios forward 8100 8100`
// against a real device, polls /status until WDA answers, then opens a
// session. Both process handles are stored on the returned MobileSession
// so close() kills both.
fn launch_ios_device(opts IOSOptions) !MobileSession {
	port := if opts.wda_port > 0 { opts.wda_port } else { 8100 }
	mut procs := start_wda_device(opts.udid, opts.wda_ipa, port)!

	base_url := 'http://localhost:${port}'

	wait_for_wda(base_url, opts.wda_ready_timeout_ms) or {
		kill_all(mut procs)
		return error('WDA failed to come up on ${base_url}: ${err.msg()}')
	}

	mut s := new_ios_session(base_url, opts.bundle_id) or {
		kill_all(mut procs)
		return err
	}
	s.bridge_procs = procs
	s.owns_bridge = true
	return s
}

// kill_all is the cleanup hook used when a bridge spawn succeeds but a
// later step (wait_for_wda / session create) fails. Without it the
// processes would outlive the launcher and have to be killed by hand.
fn kill_all(mut procs []&os.Process) {
	for mut p in procs {
		p.signal_kill()
		p.close()
	}
}

// launch_android opens a session against the UiAutomator2 server on an
// Android device or emulator. Backend lands in Mob-3 (see MOBILE_PLAN.md).
pub fn launch_android(opts AndroidOptions) !MobileSession {
	return error('vebidor.mobile.launch_android: Android backend lands in Mob-3 (UiAutomator2 client). See MOBILE_PLAN.md.')
}

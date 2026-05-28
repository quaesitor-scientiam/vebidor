module mobile

// IOSOptions configures `launch_ios`. `udid` may be a real-device UDID
// (e.g. `00008110-001A1D2E0E80801E`) or an iOS Simulator UDID returned by
// `xcrun simctl list devices`. `app_path` is the .ipa (real device) or .app
// (Simulator) of the application under test; combined with `install_app` it
// drives the install step in the (forthcoming Mob-2.1) auto-launch bridge.
//
// `wda_url` points at a WebDriverAgent that's already running. In Mob-2
// the launcher does NOT spawn WDA — see bridges_ios.v for the rationale
// and how to start WDA.
pub struct IOSOptions {
pub:
	udid        string
	bundle_id   string
	app_path    string
	install_app bool
	wda_url     string = 'http://localhost:8100'
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

// launch_ios opens a session against WebDriverAgent on iOS Simulator or a
// real iPhone, returning a MobileSession. WDA must already be running —
// `bridges_ios.check_wda_reachable` issues a helpful error with launch
// instructions otherwise. Auto-launch (Mob-2.1) will spawn WDA itself.
pub fn launch_ios(opts IOSOptions) !MobileSession {
	wda_url := if opts.wda_url.len > 0 { opts.wda_url } else { 'http://localhost:8100' }
	check_wda_reachable(wda_url)!
	return new_ios_session(wda_url, opts.bundle_id)
}

// launch_android opens a session against the UiAutomator2 server on an
// Android device or emulator. Backend lands in Mob-3 (see MOBILE_PLAN.md).
pub fn launch_android(opts AndroidOptions) !MobileSession {
	return error('vebidor.mobile.launch_android: Android backend lands in Mob-3 (UiAutomator2 client). See MOBILE_PLAN.md.')
}

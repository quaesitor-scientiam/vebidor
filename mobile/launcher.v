module mobile

// IOSOptions configures `launch_ios`. `udid` may be a real-device UDID
// (e.g. `00008110-001A1D2E0E80801E`) or an iOS Simulator UDID returned by
// `xcrun simctl list devices`. `app_path` is the .ipa (real device) or .app
// (Simulator) of the application under test; combined with `install_app` it
// drives the install step in the Mob-2 lifecycle.
pub struct IOSOptions {
pub:
	udid        string
	bundle_id   string
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

// launch_ios opens a session against WebDriverAgent on iOS Simulator or a
// real iPhone, returning a `MobileSession`.
//
// Backend lands in Mob-2 (see MOBILE_PLAN.md). For now this returns a
// descriptive error so callers can wire up call sites without waiting for
// the implementation.
pub fn launch_ios(opts IOSOptions) !MobileSession {
	return error('vebidor.mobile.launch_ios: iOS backend lands in Mob-2 (WDA client). See MOBILE_PLAN.md.')
}

// launch_android opens a session against the UiAutomator2 server on an
// Android device or emulator, returning a `MobileSession`.
//
// Backend lands in Mob-3 (see MOBILE_PLAN.md). For now this returns a
// descriptive error so callers can wire up call sites without waiting for
// the implementation.
pub fn launch_android(opts AndroidOptions) !MobileSession {
	return error('vebidor.mobile.launch_android: Android backend lands in Mob-3 (UiAutomator2 client). See MOBILE_PLAN.md.')
}

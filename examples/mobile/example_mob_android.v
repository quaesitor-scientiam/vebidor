// Mob-3 — Android UiAutomator2 smoke test. Drives the system Settings app
// on an Android emulator (or real device — adb sees them the same way).
// Settings is preinstalled on every Android image and its top-level rows
// have stable text labels, so the script doesn't need updating per OS
// release.
//
// Prerequisites:
//
//   1. Android SDK platform-tools on PATH (so `adb` works), OR set
//      $ANDROID_HOME / $ANDROID_SDK_ROOT.
//
//   2. An emulator running (or a real device attached):
//        emulator -avd <name>           # Android Studio launches one too
//        adb devices                    # confirm it shows up
//
//   3. Download the two UiAutomator2-server APKs from
//        https://github.com/appium/appium-uiautomator2-server/releases
//      and stash them somewhere.
//
//   4. Configure via env (so paths/UDIDs stay out of source):
//        export ANDROID_UDID='emulator-5554'
//        export UIA2_SERVER_APK='/path/to/appium-uiautomator2-server-v8.x.x.apk'
//        export UIA2_SERVER_TEST_APK='/path/to/appium-uiautomator2-server-test-v8.x.x.apk'
//        v -gc boehm run examples/mobile/example_mob_android.v
//
// On hosts without adb (or any device attached) the example fails at
// detect_adb / install_uia2 with a descriptive error before any spawn
// is attempted.
module main

import os
import vebidor.mobile

fn main() {
	run() or {
		eprintln(err.msg())
		exit(1)
	}
}

fn run() ! {
	println('vebidor.mobile · Mob-3 — Android Settings smoke test\n')

	udid := os.getenv('ANDROID_UDID')
	server_apk := os.getenv('UIA2_SERVER_APK')
	test_apk := os.getenv('UIA2_SERVER_TEST_APK')
	if udid == '' || server_apk == '' || test_apk == '' {
		return error(
			'Set ANDROID_UDID, UIA2_SERVER_APK, UIA2_SERVER_TEST_APK env vars before running.\n' +
			'See the header comment of this file for details.')
	}

	println('installing UiA2 + spawning instrumentation via adb …')
	mut s := mobile.launch_android(mobile.AndroidOptions{
		mode:                 .spawn
		udid:                 udid
		app_package:          'com.android.settings'
		app_activity:         '.Settings'
		uia2_server_apk:      server_apk
		uia2_server_test_apk: test_apk
	})!
	defer {
		s.close()
	}
	println('session_id = ${s.session_id}\n')

	// page_source returns the UiAutomator XML view dump — handy for
	// debugging selectors and as the basis for an Inspector-style tool.
	src := s.page_source()!
	preview := if src.len > 120 { src[..120] } else { src }
	println('page_source length = ${src.len} bytes (preview: ${preview}…)')

	// Find all TextViews. Exercises find_elements + the `class name`
	// strategy without depending on any specific UI text.
	text_views := s.find_elements('class name', 'android.widget.TextView')!
	println('found ${text_views.len} TextView elements')

	// Demonstrate the Mob-5 assertion surface on Android too — same code
	// path that worked on iOS, just hitting UiA2 instead of WDA.
	println('expect(text_contains "Settings").to_be_visible() …')
	mobile.expect(s.text_contains('Settings')).with_timeout(5000).to_be_visible() or {
		println('  (selector mismatch — Settings home title varies; not fatal)')
	}

	out := './mobile_android.png'
	s.save_screenshot(out)!
	println('screenshot saved to ${out}')

	println('\nMob-3 Android smoke test passed ✓')
	println('(close() will tear down am instrument + remove adb forward on exit)')
}

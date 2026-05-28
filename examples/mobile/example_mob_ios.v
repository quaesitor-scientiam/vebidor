// Mob-2 iOS example. Drives the iOS Settings app on the iOS Simulator —
// chosen because Settings is preinstalled on every iOS version and its top-
// level rows ("General", "Display & Brightness", "About", …) have stable
// XCUITest labels, so the script doesn't need updating per OS release.
//
// Prerequisites (macOS host, Mob-2 first cut):
//
//   1. Boot a Simulator:
//        xcrun simctl boot 'iPhone 15'
//
//   2. Start WebDriverAgent against it:
//        xcodebuild test-without-building \
//          -xctestrun <path>/WebDriverAgentRunner.xctestrun \
//          -destination 'platform=iOS Simulator,name=iPhone 15'
//      (auto-launch lands in Mob-2.1 — see MOBILE_PLAN.md)
//
//   3. Run this example:
//        v -gc boehm run examples/mobile/example_mob_ios.v
//
// On non-macOS hosts (or anywhere WDA isn't running) the example will fail
// at check_wda_reachable with full launch instructions in the error.
module main

import vebidor.mobile

fn main() {
	run() or {
		eprintln(err.msg())
		exit(1)
	}
}

fn run() ! {
	println('vebidor.mobile · Mob-2 — iOS Settings smoke test\n')

	mut s := mobile.launch_ios(mobile.IOSOptions{
		bundle_id: 'com.apple.Preferences'
		wda_url:   'http://localhost:8100'
	})!
	defer {
		s.close()
	}
	println('session_id = ${s.session_id}')

	// Page source is the XCUITest element tree — handy for debugging
	// selectors. Print a small preview so the run leaves visible context.
	src := s.page_source()!
	preview := if src.len > 120 { src[..120] } else { src }
	println('page_source length = ${src.len} bytes (preview: ${preview}…)')

	// Find the "General" row by its accessibility label — auto-waits for
	// it to be present / displayed / enabled before tapping.
	general := s.label('General')
	println('tapping General …')
	general.tap()!

	// After the tap, the General screen pushes; "About" is the first row.
	about := s.label('About')
	println('waiting for About to appear …')
	about_el := about.wait_for()!
	println('  resolved (element id: ${about_el.element_id})')

	// Leave a visible artifact.
	out := './mobile_settings.png'
	s.save_screenshot(out)!
	println('screenshot saved to ${out}')

	println('\nMob-2 iOS smoke test passed ✓')
}

// Mob-5 — assertions + gestures example. Drives the iOS Settings app to
// exercise the new `mobile.expect()` polling assertions and the W3C-actions
// gesture surface (long_press / swipe_* / drag_to / scroll_into_view).
//
// Reuses the same setup as example_mob_ios_sim.v:
//
//     export IOS_SIM_UDID='AAAA-BBBB-…'
//     export WDA_XCTESTRUN='/Users/…/WebDriverAgentRunner_iphonesimulator17.0-x86_64.xctestrun'
//     v -gc boehm run examples/mobile/example_mob_assertions.v
//
// On non-macOS hosts the example exits at boot_simulator with the same
// "Simulator only available on macOS hosts" error as the Sim launcher.
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
	println('vebidor.mobile · Mob-5 — assertions + gestures smoke test\n')

	udid := os.getenv('IOS_SIM_UDID')
	xctestrun := os.getenv('WDA_XCTESTRUN')
	if udid == '' || xctestrun == '' {
		return error('Set IOS_SIM_UDID and WDA_XCTESTRUN env vars before running.\n' +
			'See examples/mobile/example_mob_ios_sim.v for details.')
	}

	mut s := mobile.launch_ios(mobile.IOSOptions{
		mode:          .simulator
		udid:          udid
		bundle_id:     'com.apple.Preferences'
		wda_xctestrun: xctestrun
	})!
	defer {
		s.close()
	}
	println('session_id = ${s.session_id}\n')

	// --- assertions ---------------------------------------------------
	println('expect(General).to_be_visible() …')
	mobile.expect(s.label('General')).to_be_visible()!

	println('expect(General).to_be_enabled() …')
	mobile.expect(s.label('General')).to_be_enabled()!

	println('expect(NonexistentRow).not().to_be_visible() …')
	mobile.expect(s.label('NonexistentRowXYZ')).not().to_be_visible()!

	// Push into General to exercise to_contain_text on the next screen.
	println('tap General …')
	s.label('General').tap()!

	println('expect(About).to_be_visible().with_timeout(5000) …')
	mobile.expect(s.label('About')).with_timeout(5000).to_be_visible()!

	println('expect(About).to_contain_text("About") …')
	mobile.expect(s.label('About')).to_contain_text('About')!

	// --- gestures -----------------------------------------------------
	// Swipe up over the General list to scroll down. Use the table view
	// itself — its "name" is usually empty, so locate by class.
	println('\nswipe_up over the General table …')
	table := s.class_chain('**/XCUIElementTypeTable')
	table.swipe_up() or { println('  (table not found or swipe_up failed: ${err.msg()})') }

	// Long-press on About — usually a no-op on this row, but proves the
	// gesture round-trips.
	println('long_press(700) on About …')
	s.label('About').long_press(700) or { println('  (long_press failed: ${err.msg()})') }

	// scroll_into_view on a row that's already visible should be a no-op.
	// Useful as a smoke check that the WDA scrollToVisible extension is
	// reachable.
	println('scroll_into_view on About …')
	s.label('About').scroll_into_view() or { println('  (scroll_into_view failed: ${err.msg()})') }

	out := './mobile_assertions.png'
	s.save_screenshot(out)!
	println('\nscreenshot saved to ${out}')
	println('\nMob-5 assertions + gestures smoke test passed ✓')
}

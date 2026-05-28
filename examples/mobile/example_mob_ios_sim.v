// Mob-2.1 — iOS Simulator auto-launch example.
//
// Same flow as example_mob_ios.v (Settings → General → About → screenshot)
// but vebidor spawns WebDriverAgent itself instead of expecting it to be
// already running:
//
//   1. `xcrun simctl boot <udid>` (idempotent — fine if already booted).
//   2. `xcodebuild test-without-building -xctestrun <path>
//        -destination "platform=iOS Simulator,id=<udid>"`.
//   3. Polls WDA's /status until it answers, then opens a session.
//   4. On `close()`, kills the xcodebuild process.
//
// Configure via environment so paths/UDIDs stay out of source control:
//
//     export IOS_SIM_UDID='AAAA-BBBB-…'   # `xcrun simctl list devices`
//     export WDA_XCTESTRUN='/Users/.../WebDriverAgentRunner_iphonesimulator17.0-x86_64.xctestrun'
//     v -gc boehm run examples/mobile/example_mob_ios_sim.v
//
// One-time WDA build (until something like this is in the bridge itself):
//
//     git clone https://github.com/appium/WebDriverAgent
//     cd WebDriverAgent
//     xcodebuild -project WebDriverAgent.xcodeproj \
//       -scheme WebDriverAgentRunner \
//       -destination 'platform=iOS Simulator,name=iPhone 15' \
//       build-for-testing
//     # the .xctestrun lands in DerivedData/.../Build/Products/
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
	println('vebidor.mobile · Mob-2.1 — iOS Simulator auto-launch smoke test\n')

	udid := os.getenv('IOS_SIM_UDID')
	xctestrun := os.getenv('WDA_XCTESTRUN')
	if udid == '' || xctestrun == '' {
		return error('Set IOS_SIM_UDID and WDA_XCTESTRUN env vars before running.\n' +
			'See the header comment of this file for details.')
	}

	println('booting Simulator + spawning WDA via xcodebuild …')
	mut s := mobile.launch_ios(mobile.IOSOptions{
		mode:          .simulator
		udid:          udid
		bundle_id:     'com.apple.Preferences'
		wda_xctestrun: xctestrun
		// boot_sim defaults to true; wda_port defaults to 8100;
		// wda_ready_timeout_ms defaults to 60s.
	})!
	defer {
		s.close()
	}
	println('session_id = ${s.session_id}')

	src := s.page_source()!
	preview := if src.len > 120 { src[..120] } else { src }
	println('page_source length = ${src.len} bytes (preview: ${preview}…)')

	general := s.label('General')
	println('tapping General …')
	general.tap()!

	about := s.label('About')
	println('waiting for About to appear …')
	about_el := about.wait_for()!
	println('  resolved (element id: ${about_el.element_id})')

	out := './mobile_settings_sim.png'
	s.save_screenshot(out)!
	println('screenshot saved to ${out}')

	println('\nMob-2.1 Simulator auto-launch passed ✓')
	println('(close() will tear down xcodebuild on exit)')
}

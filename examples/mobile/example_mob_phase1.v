// Cheap status-check example: confirms the `vebidor.mobile` module compiles
// and shows what each backend's launch function reports in its current
// state. Both backends are real after Mob-3 — they error with
// WDA / UiA2 launch instructions when the underlying server isn't
// reachable, instead of a "not yet implemented" stub.
//
// For actual end-to-end smoke tests see:
//
//     examples/mobile/example_mob_ios_sim.v  — iOS Simulator auto-launch
//     examples/mobile/example_mob_android.v  — Android emulator / device
//     examples/mobile/example_mob_assertions.v — assertions + gestures
module main

import vebidor.mobile

fn main() {
	println('vebidor.mobile · backend status check\n')

	mobile.launch_ios(mobile.IOSOptions{
		bundle_id: 'com.example.MyApp'
	}) or { println('launch_ios → ${err.msg().all_before('\n')}') }

	mobile.launch_android(mobile.AndroidOptions{
		udid:        'emulator-5554'
		app_package: 'com.example.myapp'
	}) or { println('launch_android → ${err.msg().all_before('\n')}') }

	println('\nBoth launches reported their current backend status. ✓')
}

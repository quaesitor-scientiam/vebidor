// Cheap status-check example: confirms the `vebidor.mobile` module compiles
// and shows what each backend's launch function does in its current state.
//
// After Mob-2, `launch_ios` is real — it errors with WDA launch instructions
// when WDA isn't reachable, instead of a "not yet implemented" stub.
// `launch_android` remains a stub until Mob-3 lands.
//
// For an actual end-to-end iOS smoke test (Settings app on the Simulator)
// see `example_mob_ios.v`.
module main

import vebidor.mobile

fn main() {
	println('vebidor.mobile · backend status check\n')

	// Mob-2: real backend. Errors with launch instructions if WDA isn't up.
	mobile.launch_ios(mobile.IOSOptions{
		bundle_id: 'com.example.MyApp'
	}) or { println('launch_ios → ${err.msg().all_before('\n')}') }

	// Mob-3: still a stub.
	mobile.launch_android(mobile.AndroidOptions{
		udid:        'emulator-5554'
		app_package: 'com.example.myapp'
	}) or { println('launch_android → ${err.msg()}') }

	println('\nBoth launches reported their current backend status. ✓')
}

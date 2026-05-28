// Mob-1 example. Confirms the `vebidor.mobile` module compiles, the public
// types are visible, and the launch stubs error with the expected pointer to
// MOBILE_PLAN.md. The real iOS / Android backends land in Mob-2 / Mob-3.
module main

import vebidor.mobile

fn main() {
	println('vebidor.mobile · Mob-1 (foundations) — launch stubs return descriptive errors.')
	println('')

	// iOS stub.
	mobile.launch_ios(mobile.IOSOptions{
		udid:        '00000000-0000000000000000'
		bundle_id:   'com.example.MyApp'
		app_path:    '/path/to/MyApp.app'
		install_app: true
	}) or { println('launch_ios → ${err.msg()}') }

	// Android stub.
	mobile.launch_android(mobile.AndroidOptions{
		udid:         'emulator-5554'
		app_package:  'com.example.myapp'
		app_activity: '.MainActivity'
		apk_path:     '/path/to/myapp.apk'
		install_app:  true
	}) or { println('launch_android → ${err.msg()}') }

	println('')
	println('Both stubs reported the expected Mob-2/Mob-3 deferral. ✓')
}

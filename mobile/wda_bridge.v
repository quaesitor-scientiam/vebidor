module mobile

import os
import time
import vebidor.webdriver

// iOS bridge.
//
// Mob-2 first cut connected to an ALREADY-running WebDriverAgent. Mob-2.1
// (this file's expansion) spawns WDA itself:
//
//   - Simulator mode: `xcrun simctl boot <udid>` (idempotent) then
//     `xcodebuild test-without-building -xctestrun <path> -destination …`.
//   - Real-device mode: `go-ios install` (idempotent if already present)
//     then `go-ios runwda` and `go-ios forward 8100 8100` in parallel.
//
// In both cases the bridge polls WDA's /status until it answers HTTP, then
// hands the process handle(s) back to MobileSession so close() can tear
// them down. Spawned children inherit our stdio so WDA progress shows in
// the terminal (helpful for diagnostics).

// check_wda_reachable hits WDA's `/status` endpoint to confirm the server
// is up. Returns a clear error with launch instructions if not — much
// nicer than a cryptic "connection refused" out of `launch_ios`. Used by
// the `.attach` launch mode.
pub fn check_wda_reachable(base_url string) ! {
	transport := webdriver.HttpTransport{}
	resp := transport.execute('GET', '${base_url}/status', '', '') or {
		return error('WebDriverAgent unreachable at ${base_url}.\n' + '\n' +
			'Start WDA before calling launch_ios. For iOS Simulator:\n' +
			'  xcodebuild test-without-building \\\n' +
			'    -xctestrun <path>/WebDriverAgentRunner.xctestrun \\\n' +
			'    -destination "platform=iOS Simulator,id=<udid>"\n' + '\n' +
			'For a real device (via go-ios):\n' + '  ios install --path WebDriverAgentRunner.ipa --udid <udid>\n' + '  ios runwda --udid <udid> &\n' + '  ios forward 8100 8100 --udid <udid>\n' + '\n' + 'Or call `launch_ios(IOSOptions{ mode: .simulator, … })` to spawn WDA automatically.\n' + 'Underlying error: ${err.msg()}')
	}
	if resp.status_code >= 400 {
		return error('WDA at ${base_url} responded ${resp.status_code} on /status — is it healthy?')
	}
}

// wait_for_wda polls /status until it answers 2xx or `timeout_ms` elapses.
// Used after spawning xcodebuild/go-ios so the launcher only returns once
// WDA is actually serving HTTP. Connection errors are treated as "not yet"
// so the startup transient (connection refused while WDA boots) doesn't
// bail us early.
pub fn wait_for_wda(base_url string, timeout_ms int) ! {
	transport := webdriver.HttpTransport{}
	start := time.now()
	for {
		if resp := transport.execute('GET', '${base_url}/status', '', '') {
			if resp.status_code < 400 {
				return
			}
		}
		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('WDA at ${base_url} did not respond within ${timeout_ms}ms')
		}
		time.sleep(500 * time.millisecond)
	}
}

// is_macos returns true on macOS hosts. xcrun, xcodebuild, and Simulator
// only exist on macOS; bridge functions that need them refuse on other
// hosts with a useful error.
fn is_macos() bool {
	return os.user_os() == 'macos'
}

// command_on_path returns true if `cmd` resolves on PATH. Used to detect
// `go-ios` before attempting to invoke it.
fn command_on_path(cmd string) bool {
	probe := if is_macos() || os.user_os() == 'linux' { 'which ${cmd}' } else { 'where ${cmd}' }
	res := os.execute(probe)
	return res.exit_code == 0
}

// boot_simulator brings the named Simulator UDID into the Booted state.
// Idempotent — already-booted Simulators are treated as success.
pub fn boot_simulator(udid string) ! {
	if !is_macos() {
		return error('Simulator only available on macOS hosts (current: ${os.user_os()}).')
	}
	if udid == '' {
		return error('boot_simulator: udid required (use `xcrun simctl list devices` to find one).')
	}
	res := os.execute('xcrun simctl boot ${udid}')
	if res.exit_code == 0 {
		return
	}
	// `Unable to boot device in current state: Booted` is what simctl says
	// when the device is already running — that's fine.
	if res.output.contains('Booted') || res.output.contains('current state: Booted') {
		return
	}
	return error('xcrun simctl boot ${udid} failed (exit ${res.exit_code}): ${res.output.trim_space()}')
}

// start_wda_simulator spawns `xcodebuild test-without-building` against the
// given Simulator UDID + .xctestrun file. Returns the process handle so the
// caller can kill it on close(). WDA usually starts listening within ~5s
// on a warm Simulator and ~20s on a cold one.
pub fn start_wda_simulator(udid string, xctestrun string) !&os.Process {
	if !is_macos() {
		return error('xcodebuild only available on macOS hosts (current: ${os.user_os()}).')
	}
	if udid == '' {
		return error('start_wda_simulator: udid required.')
	}
	if xctestrun == '' {
		return error(
			'start_wda_simulator: xctestrun path required. Build WebDriverAgentRunner once with\n' +
			'  xcodebuild -project WebDriverAgent.xcodeproj -scheme WebDriverAgentRunner \\\n' +
			'    -destination "platform=iOS Simulator,name=iPhone 15" build-for-testing\n' +
			'then point IOSOptions.wda_xctestrun at the WebDriverAgentRunner_*.xctestrun produced.')
	}
	if !os.exists(xctestrun) {
		return error('xctestrun file not found: ${xctestrun}')
	}
	mut p := os.new_process('xcodebuild')
	p.set_args([
		'test-without-building',
		'-xctestrun',
		xctestrun,
		'-destination',
		'platform=iOS Simulator,id=${udid}',
	])
	p.set_redirect_stdio()
	p.run()
	return p
}

// start_wda_device spawns `go-ios runwda` + `go-ios forward 8100 8100`
// against a real device. Returns both process handles as a slice (runwda
// first, forward second) so the caller can kill them on close(). If `ipa`
// is provided and exists, attempts an idempotent install first (go-ios
// skips already-installed builds).
pub fn start_wda_device(udid string, ipa string, port int) ![]&os.Process {
	if !is_macos() {
		return error('Real-device flow requires a macOS host for code signing (current: ${os.user_os()}).')
	}
	if udid == '' {
		return error('start_wda_device: udid required.')
	}
	if !command_on_path('ios') {
		return error('go-ios not found on PATH. Install with `brew install go-ios` or see https://github.com/danielpaulus/go-ios.')
	}
	if ipa != '' && os.exists(ipa) {
		// Idempotent — go-ios skips a build that's already installed at the
		// same version. Ignore exit code; real failures surface later in
		// runwda.
		os.execute('ios install --path ${ipa} --udid ${udid}')
	}
	mut runwda := os.new_process('ios')
	runwda.set_args(['runwda', '--udid', udid])
	runwda.set_redirect_stdio()
	runwda.run()

	// Give runwda a beat to spin up before the forward — not strictly
	// required (forward is just a TCP proxy), but it lines the terminal
	// output up nicely.
	time.sleep(500 * time.millisecond)

	mut forward := os.new_process('ios')
	forward.set_args(['forward', port.str(), port.str(), '--udid', udid])
	forward.set_redirect_stdio()
	forward.run()

	return [runwda, forward]
}

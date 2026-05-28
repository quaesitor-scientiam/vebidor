module mobile

import vebidor.webdriver

// iOS bridge — Mob-2 first cut.
//
// This phase connects to a WebDriverAgent that's ALREADY running, rather
// than spawning one. That keeps the wire code (wda.v / locator.v / etc.)
// landable and reviewable on its own, and matches how Appium Inspector
// users already operate. The bridge that auto-builds and auto-launches WDA
// — via `xcodebuild test-without-building` for Simulator or `go-ios` for
// real devices — lands in Mob-2.1.
//
// Practically: start WDA before calling `launch_ios`. For an iOS Simulator
// it's a single command from the appium-webdriveragent repo:
//
//     xcodebuild test-without-building \
//       -xctestrun <path>/WebDriverAgentRunner.xctestrun \
//       -destination 'platform=iOS Simulator,id=<udid>'
//
// For a real device, use `go-ios`:
//
//     ios install --path WebDriverAgentRunner.ipa --udid <udid>
//     ios runwda --udid <udid> &
//     ios forward 8100 8100 --udid <udid>

// check_wda_reachable hits WDA's `/status` endpoint to confirm the server
// is up. Returns a clear error with launch instructions if not — much
// nicer than a cryptic "connection refused" out of `launch_ios`.
pub fn check_wda_reachable(base_url string) ! {
	transport := webdriver.HttpTransport{}
	resp := transport.execute('GET', '${base_url}/status', '', '') or {
		return error('WebDriverAgent unreachable at ${base_url}.\n' + '\n' +
			'Start WDA before calling launch_ios. For iOS Simulator:\n' +
			'  xcodebuild test-without-building \\\n' +
			'    -xctestrun <path>/WebDriverAgentRunner.xctestrun \\\n' +
			'    -destination "platform=iOS Simulator,id=<udid>"\n' + '\n' +
			'For a real device (via go-ios):\n' + '  ios install --path WebDriverAgentRunner.ipa --udid <udid>\n' + '  ios runwda --udid <udid> &\n' + '  ios forward 8100 8100 --udid <udid>\n' + '\n' + 'Auto-launch lands in Mob-2.1 — see MOBILE_PLAN.md.\n' + 'Underlying error: ${err.msg()}')
	}
	if resp.status_code >= 400 {
		return error('WDA at ${base_url} responded ${resp.status_code} on /status — is it healthy?')
	}
}

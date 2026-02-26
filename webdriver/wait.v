module webdriver

import time
import x.json2 as json

pub fn (wd WebDriver) wait_for(condition fn (WebDriver) !bool, timeout_ms int, interval_ms int) ! {
	start := time.now()
	for {
		ok := condition(wd) or { false }
		if ok {
			return
		}
		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('wait_for: timeout after ${timeout_ms}ms')
		}
		time.sleep(interval_ms * time.millisecond)
	}
}

// set_implicit_wait - Set the implicit wait timeout
// W3C Endpoint: POST /session/{session id}/timeouts
pub fn (wd WebDriver) set_implicit_wait(milliseconds int) ! {
	mut payload := map[string]json.Any{}
	payload['implicit'] = json.Any(milliseconds)
	wd.post_void('/session/${wd.session_id}/timeouts', json.Any(payload))!
}

// set_page_load_timeout - Set the page load timeout
// W3C Endpoint: POST /session/{session id}/timeouts
pub fn (wd WebDriver) set_page_load_timeout(milliseconds int) ! {
	mut payload := map[string]json.Any{}
	payload['pageLoad'] = json.Any(milliseconds)
	wd.post_void('/session/${wd.session_id}/timeouts', json.Any(payload))!
}

// set_script_timeout - Set the script execution timeout
// W3C Endpoint: POST /session/{session id}/timeouts
pub fn (wd WebDriver) set_script_timeout(milliseconds int) ! {
	mut payload := map[string]json.Any{}
	payload['script'] = json.Any(milliseconds)
	wd.post_void('/session/${wd.session_id}/timeouts', json.Any(payload))!
}

// get_timeouts - Get the current timeout configuration
// Returns the current timeouts (implicit, page_load, script) in milliseconds
// W3C Endpoint: GET /session/{session id}/timeouts
// Note: Timeouts struct is defined in capabiities.v
pub fn (wd WebDriver) get_timeouts() !Timeouts {
	resp := wd.get_request[Timeouts]('/session/${wd.session_id}/timeouts')!
	return resp.value
}

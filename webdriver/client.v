module webdriver

import net.http
import x.json2 as json

pub struct WebDriver {
pub:
	base_url   string
	session_id string
	logger     ?Logger
}

fn (wd WebDriver) log(msg string) {
	if logger := wd.logger {
		logger.log(msg)
	}
}

// new_session - Create a new WebDriver session (shared helper for all browsers)
pub fn new_session(base_url string, caps Capabilities) !WebDriver {
	params := caps.to_session_params()
	body := json.encode(params)

	resp := http.post('${base_url}/session', body) or {
		return error('Failed to connect to WebDriver at ${base_url}\n' +
			'Make sure the WebDriver is running.\n' + 'Error: ${err}')
	}

	if resp.status_code >= 400 {
		err := parse_error(resp.body) or {
			return error('Failed to create session (${resp.status_code}): ${resp.body}')
		}
		return error(err.str())
	}

	parsed := json.decode[WebDriverResponse[map[string]json.Any]](resp.body) or {
		return error('Invalid session response: ${err}')
	}

	sid := parsed.value['sessionId'] or { return error('Missing sessionId in response') }

	return WebDriver{
		base_url:   base_url
		session_id: sid.str()
	}
}

// Close the session and quit the browser
pub fn (wd WebDriver) quit() ! {
	wd.delete_void('/session/${wd.session_id}')!
}

// Navigate to a URL
pub fn (wd WebDriver) get(url string) ! {
	mut payload := map[string]json.Any{}
	payload['url'] = json.Any(url)
	wd.post_void('/session/${wd.session_id}/url', payload)!
}

pub fn (wd WebDriver) back() ! {
	wd.post_void('/session/${wd.session_id}/back', map[string]json.Any{})!
}

pub fn (wd WebDriver) forward() ! {
	wd.post_void('/session/${wd.session_id}/forward', map[string]json.Any{})!
}

pub fn (wd WebDriver) refresh() ! {
	wd.post_void('/session/${wd.session_id}/refresh', map[string]json.Any{})!
}

// Get the current page title
// W3C Endpoint: GET /session/{session id}/title
pub fn (wd WebDriver) get_title() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/title')!
	return resp.value
}

// Get the current page URL
// W3C Endpoint: GET /session/{session id}/url
pub fn (wd WebDriver) get_current_url() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/url')!
	return resp.value
}

// Get the HTML source of the current page
// W3C Endpoint: GET /session/{session id}/source
pub fn (wd WebDriver) get_page_source() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/source')!
	return resp.value
}

fn (wd WebDriver) post[T](path string, payload json.Any) !WebDriverResponse[T] {
	body := json.encode(payload)

	mut req := http.Request{
		method: .post
		url:    '${wd.base_url}${path}'
		data:   body
	}
	req.add_header(.content_type, 'application/json')

	resp := req.do() or { return error('POST ${path} failed: ${err}') }

	if resp.status_code >= 400 {
		err := parse_error(resp.body) or {
			return error('Failed to parse error for ${path}: ${err}')
		}
		return error(err.str())
	}

	return json.decode[WebDriverResponse[T]](resp.body) or {
		return error('Invalid response for ${path}: ${err}')
	}
}

fn (wd WebDriver) get_request[T](path string) !WebDriverResponse[T] {
	resp := http.get('${wd.base_url}${path}') or { return error('GET ${path} failed: ${err}') }

	if resp.status_code >= 400 {
		err := parse_error(resp.body) or {
			return error('Failed to parse error for ${path}: ${err}')
		}
		return error(err.str())
	}

	return json.decode[WebDriverResponse[T]](resp.body) or {
		return error('Invalid response for ${path}: ${err}')
	}
}

fn (wd WebDriver) post_void(path string, payload json.Any) ! {
	body := json.encode(payload)

	mut req := http.Request{
		method: .post
		url:    '${wd.base_url}${path}'
		data:   body
	}
	req.add_header(.content_type, 'application/json')

	resp := req.do() or { return error('POST ${path} failed: ${err}') }

	if resp.status_code >= 400 {
		err := parse_error(resp.body) or {
			return error('POST ${path} failed (${resp.status_code}): ${resp.body}')
		}
		return error(err.str())
	}
}

fn (wd WebDriver) delete_void(path string) ! {
	_ := http.Request{
		method: .delete
		url:    '${wd.base_url}${path}'
	}.do() or { return error('DELETE ${path} failed: ${err}') }
}

pub fn (wd WebDriver) click_at(x int, y int) ! {
	src := mouse('mouse', [
		pointer_move(x, y, 0),
		pointer_down(0),
		pointer_up(0),
	])
	wd.perform_actions([src])!
}

pub fn (wd WebDriver) double_click(el ElementRef) ! {
	src := mouse('mouse', [
		pointer_move(0, 0, 0),
		pointer_down(0),
		pointer_up(0),
		pause(50),
		pointer_down(0),
		pointer_up(0),
	])
	wd.perform_actions([src])!
}

pub fn (wd WebDriver) drag_and_drop(from ElementRef, to ElementRef) ! {
	src := mouse('mouse', [
		pointer_move(0, 0, 0),
		pointer_down(0),
		pause(100),
		pointer_move(200, 0, 200),
		pointer_up(0),
	])
	wd.perform_actions([src])!
}

pub fn (wd WebDriver) scroll_by(dx int, dy int) ! {
	src := wheel('wheel', [
		wheel_scroll(0, 0, dx, dy),
	])
	wd.perform_actions([src])!
}

pub fn (wd WebDriver) edge_browser_version() !string {
	resp := wd.post[map[string]json.Any]('/session/${wd.session_id}/ms:browserVersion',
		map[string]json.Any{})!
	return resp.value['version'] or { 'unknown' }.str()
}

// Network conditions (throttling)
pub fn (wd WebDriver) set_network_conditions(c EdgeNetworkConditions) ! {
	encoded := json.encode(c)
	decoded := json.decode[json.Any](encoded) or {
		return error('Failed to encode network conditions: ${err}')
	}
	wd.post_void('/session/${wd.session_id}/ms:networkConditions', decoded)!
}

pub fn (wd WebDriver) emulate_device(d EdgeDeviceEmulation) ! {
	encoded := json.encode(d)
	decoded := json.decode[json.Any](encoded) or {
		return error('Failed to encode device emulation: ${err}')
	}
	wd.post_void('/session/${wd.session_id}/ms:emulation', decoded)!
}

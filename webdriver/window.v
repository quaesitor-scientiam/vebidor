module webdriver

import x.json2 as json

pub struct WindowRect {
pub mut:
	x      int
	y      int
	width  int
	height int
}

pub fn (wd WebDriver) get_window_handle() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/window')!
	return resp.value
}

pub fn (wd WebDriver) get_window_handles() ![]string {
	resp := wd.get_request[[]string]('/session/${wd.session_id}/window/handles')!
	return resp.value
}

pub fn (wd WebDriver) close() ! {
	wd.delete_void('/session/${wd.session_id}/window')!
}

pub fn (wd WebDriver) get_window_rect() !WindowRect {
	resp := wd.get_request[WindowRect]('/session/${wd.session_id}/window/rect')!
	return resp.value
}

pub fn (wd WebDriver) set_window_rect(rect WindowRect) ! {
	encoded := json.encode(rect)
	decoded := json.decode[json.Any](encoded) or {
		return error('Failed to encode window rect: ${err}')
	}
	wd.post_void('/session/${wd.session_id}/window/rect', decoded)!
}

// switch_to_window - Switch to a different window or tab
// W3C Endpoint: POST /session/{session id}/window
pub fn (wd WebDriver) switch_to_window(handle string) ! {
	mut payload := map[string]json.Any{}
	payload['handle'] = json.Any(handle)
	wd.post_void('/session/${wd.session_id}/window', json.Any(payload))!
}

// NewWindowResult - Result returned when creating a new window
pub struct NewWindowResult {
pub:
	handle string
	type_  string @[json: 'type']
}

// new_window - Create a new window or tab
// W3C Endpoint: POST /session/{session id}/window/new
pub fn (wd WebDriver) new_window(window_type string) !NewWindowResult {
	mut payload := map[string]json.Any{}
	payload['type'] = json.Any(window_type) // 'tab' or 'window'
	resp := wd.post[NewWindowResult]('/session/${wd.session_id}/window/new', json.Any(payload))!
	return resp.value
}

// maximize_window - Maximize the current window
// W3C Endpoint: POST /session/{session id}/window/maximize
pub fn (wd WebDriver) maximize_window() ! {
	wd.post_void('/session/${wd.session_id}/window/maximize', map[string]json.Any{})!
}

// minimize_window - Minimize the current window
// W3C Endpoint: POST /session/{session id}/window/minimize
pub fn (wd WebDriver) minimize_window() ! {
	wd.post_void('/session/${wd.session_id}/window/minimize', map[string]json.Any{})!
}

// fullscreen_window - Fullscreen the current window
// W3C Endpoint: POST /session/{session id}/window/fullscreen
pub fn (wd WebDriver) fullscreen_window() ! {
	wd.post_void('/session/${wd.session_id}/window/fullscreen', map[string]json.Any{})!
}

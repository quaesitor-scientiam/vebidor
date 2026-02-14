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

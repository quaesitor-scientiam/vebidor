module webdriver

import net
import net.http
import net.urllib
import strings
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

// wd_do performs an HTTP request to an EdgeDriver endpoint over raw TCP.
// Unlike http.Request.do(), it stops reading as soon as Content-Length bytes
// of body have been received, avoiding the 30-second read-timeout stall that
// occurs in V's stdlib HTTP client when the server uses HTTP keep-alive and
// never closes the connection.
fn wd_do(method string, url_str string, content_type string, body string) !http.Response {
	u := urllib.parse(url_str)!
	host := u.hostname()
	port := u.port().int()
	p := u.escaped_path().trim_left('/')
	path := if u.query().len > 0 { '/${p}?${u.query().encode()}' } else { '/${p}' }

	// Build HTTP/1.1 request
	mut rq := strings.new_builder(256)
	rq.write_string('${method} ${path} HTTP/1.1\r\n')
	rq.write_string('Host: ${host}:${port}\r\n')
	rq.write_string('User-Agent: vebidor\r\n')
	if content_type.len > 0 {
		rq.write_string('Content-Type: ${content_type}\r\n')
	}
	rq.write_string('Content-Length: ${body.len}\r\n')
	rq.write_string('\r\n')
	rq.write_string(body)

	// Connect and send
	mut conn := net.dial_tcp('${host}:${port}')!
	conn.write(rq.str().bytes())!

	// Read response, stopping as soon as we have received Content-Length body bytes.
	// We never make a final read call after the body is complete, so we never stall
	// waiting for the server to close a keep-alive connection.
	mut chunk := [4096]u8{}
	cp := unsafe { &chunk[0] }
	mut resp_bytes := []u8{cap: 4096}
	mut hdr_end := -1 // byte offset where the body begins (after \r\n\r\n)
	mut clen := -1    // value of Content-Length header

	for {
		n := conn.read_ptr(cp, 4096) or { break }
		if n <= 0 {
			break
		}
		resp_bytes << chunk[..n]

		// Locate end-of-headers on first pass
		if hdr_end < 0 {
			s := resp_bytes.bytestr()
			idx := s.index_('\r\n\r\n')
			if idx >= 0 {
				hdr_end = idx + 4
				for line in s[..idx].split('\r\n') {
					if line.to_lower().starts_with('content-length:') {
						clen = line.all_after(':').trim_space().int()
						break
					}
				}
			}
		}

		// Stop as soon as the complete body has arrived
		if hdr_end >= 0 && clen >= 0 && resp_bytes.len - hdr_end >= clen {
			break
		}
	}

	conn.close() or {}
	return http.parse_response(resp_bytes.bytestr())!
}

// new_session - Create a new WebDriver session (shared helper for all browsers)
pub fn new_session(base_url string, caps Capabilities) !WebDriver {
	params := caps.to_session_params()
	body := json.encode(params)

	resp := wd_do('POST', '${base_url}/session', 'application/json', body) or {
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

// quit - Close the session and quit the browser
pub fn (wd WebDriver) quit() ! {
	wd.delete_void('/session/${wd.session_id}')!
}

// get - Navigate to a URL
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

// get_title - Get the current page title
// W3C Endpoint: GET /session/{session id}/title
pub fn (wd WebDriver) get_title() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/title')!
	return resp.value
}

// get_current_url - Get the current page URL
// W3C Endpoint: GET /session/{session id}/url
pub fn (wd WebDriver) get_current_url() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/url')!
	return resp.value
}

// get_page_source - Get the HTML source of the current page
// W3C Endpoint: GET /session/{session id}/source
pub fn (wd WebDriver) get_page_source() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/source')!
	return resp.value
}

fn (wd WebDriver) post[T](path string, payload json.Any) !WebDriverResponse[T] {
	body := json.encode(payload)

	resp := wd_do('POST', '${wd.base_url}${path}', 'application/json', body) or {
		return error('POST ${path} failed: ${err}')
	}

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
	resp := wd_do('GET', '${wd.base_url}${path}', '', '') or {
		return error('GET ${path} failed: ${err}')
	}

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

	resp := wd_do('POST', '${wd.base_url}${path}', 'application/json', body) or {
		return error('POST ${path} failed: ${err}')
	}

	if resp.status_code >= 400 {
		err := parse_error(resp.body) or {
			return error('POST ${path} failed (${resp.status_code}): ${resp.body}')
		}
		return error(err.str())
	}
}

fn (wd WebDriver) delete_void(path string) ! {
	wd_do('DELETE', '${wd.base_url}${path}', '', '') or {
		return error('DELETE ${path} failed: ${err}')
	}
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

// set_network_conditions - Network conditions (throttling)
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

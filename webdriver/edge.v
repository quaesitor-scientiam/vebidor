module webdriver

import os

// find_edge_binary returns the path to the msedge.exe binary.
// Checks EDGE_BINARY env var first, then common install locations.
pub fn find_edge_binary() !string {
	env_path := os.getenv('EDGE_BINARY')
	if env_path != '' && os.exists(env_path) {
		return env_path
	}
	candidates := [
		r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
		r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
	]
	for path in candidates {
		if os.exists(path) {
			return path
		}
	}
	return error('msedge.exe not found; set EDGE_BINARY env var to its location')
}

pub struct EdgeNetworkConditions {
pub:
	offline             bool
	latency             int
	download_throughput int
	upload_throughput   int
}

pub struct EdgeDeviceEmulation {
pub:
	width  int
	height int
	scale  f32
}

// new_edge_driver - Create a new Edge WebDriver session
// base_url: EdgeDriver endpoint (e.g., 'http://127.0.0.1:9515')
// caps: Browser capabilities including EdgeOptions
pub fn new_edge_driver(base_url string, caps Capabilities) !WebDriver {
	mut final_caps := caps
	if _ := final_caps.browser_name {
		// Keep existing browser_name
	} else {
		final_caps.browser_name = 'msedge'
	}
	return new_session(base_url, final_caps)
}

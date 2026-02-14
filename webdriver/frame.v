module webdriver

import x.json2 as json

pub fn (wd WebDriver) switch_to_frame(el ?ElementRef) ! {
	mut payload := map[string]json.Any{}
	if el == none {
		payload['id'] = json.Any(0) // null-ish placeholder; adjust if you want explicit null
	} else {
		payload['id'] = json.Any(json.map_from(el))
	}
	wd.post_void('/session/${wd.session_id}/frame', payload)!
}

pub fn (wd WebDriver) switch_to_parent_frame() ! {
	wd.post_void('/session/${wd.session_id}/frame/parent', map[string]json.Any{})!
}

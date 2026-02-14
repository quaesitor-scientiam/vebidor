module webdriver

import x.json2 as json

pub fn (wd WebDriver) screenshot() !string {
	resp := wd.post[string]('/session/${wd.session_id}/screenshot', map[string]json.Any{})!
	return resp.value
}

pub fn (wd WebDriver) element_screenshot(el ElementRef) !string {
	resp := wd.post[string]('/session/${wd.session_id}/element/${el.element_id}/screenshot',
		map[string]json.Any{})!
	return resp.value
}

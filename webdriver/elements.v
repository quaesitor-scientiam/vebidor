module webdriver

import x.json2 as json

pub fn (wd WebDriver) find_element(using string, value string) !ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[ElementRef]('/session/${wd.session_id}/element', json.Any(params))!
	return resp.value
}

pub fn (wd WebDriver) find_elements(using string, value string) ![]ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[[]ElementRef]('/session/${wd.session_id}/elements', json.Any(params))!
	return resp.value
}

pub fn (wd WebDriver) click(el ElementRef) ! {
	wd.post_void('/session/${wd.session_id}/element/${el.element_id}/click', map[string]json.Any{})!
}

pub fn (wd WebDriver) send_keys(el ElementRef, text string) ! {
	mut chars := []json.Any{}
	for r in text.runes() {
		chars << json.Any(r.str())
	}
	mut payload := map[string]json.Any{}
	payload['text'] = json.Any(text)
	payload['value'] = json.Any(chars)
	wd.post_void('/session/${wd.session_id}/element/${el.element_id}/value', payload)!
}

// Get the visible text of an element
pub fn (wd WebDriver) get_text(el ElementRef) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/text')!
	return resp.value
}

// Get the value of an element's attribute
pub fn (wd WebDriver) get_attribute(el ElementRef, name string) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/attribute/${name}')!
	return resp.value
}

// Get the value of an element's property
pub fn (wd WebDriver) get_property(el ElementRef, name string) !json.Any {
	resp := wd.get_request[json.Any]('/session/${wd.session_id}/element/${el.element_id}/property/${name}')!
	return resp.value
}

// Check if an element is displayed (visible)
pub fn (wd WebDriver) is_displayed(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/displayed')!
	return resp.value
}

// Check if an element is enabled
pub fn (wd WebDriver) is_enabled(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/enabled')!
	return resp.value
}

// Check if an element is selected (for checkboxes, radio buttons, options)
pub fn (wd WebDriver) is_selected(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/selected')!
	return resp.value
}

// Get the tag name of an element
pub fn (wd WebDriver) get_tag_name(el ElementRef) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/name')!
	return resp.value
}

// Clear the text of an input or textarea element
pub fn (wd WebDriver) clear(el ElementRef) ! {
	wd.post_void('/session/${wd.session_id}/element/${el.element_id}/clear', map[string]json.Any{})!
}

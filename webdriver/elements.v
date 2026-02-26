module webdriver

import x.json2 as json

// ElementRect represents the position and size of an element
pub struct ElementRect {
pub:
	x      f64
	y      f64
	width  f64
	height f64
}

// ShadowRoot represents a shadow DOM root
pub struct ShadowRoot {
pub:
	shadow_id string @[json: 'shadow-6066-11e4-a52e-4f735466cecf']
}

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

// get_text - Get the visible text of an element
pub fn (wd WebDriver) get_text(el ElementRef) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/text')!
	return resp.value
}

// get_attribute - Get the value of an element's attribute
pub fn (wd WebDriver) get_attribute(el ElementRef, name string) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/attribute/${name}')!
	return resp.value
}

// get_property - Get the value of an element's property
pub fn (wd WebDriver) get_property(el ElementRef, name string) !json.Any {
	resp := wd.get_request[json.Any]('/session/${wd.session_id}/element/${el.element_id}/property/${name}')!
	return resp.value
}

// is_displayed - Check if an element is displayed (visible)
pub fn (wd WebDriver) is_displayed(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/displayed')!
	return resp.value
}

// is_enabled - Check if an element is enabled
pub fn (wd WebDriver) is_enabled(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/enabled')!
	return resp.value
}

// is_selected - Check if an element is selected (for checkboxes, radio buttons, options)
pub fn (wd WebDriver) is_selected(el ElementRef) !bool {
	resp := wd.get_request[bool]('/session/${wd.session_id}/element/${el.element_id}/selected')!
	return resp.value
}

// get_tag_name - Get the tag name of an element
pub fn (wd WebDriver) get_tag_name(el ElementRef) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/name')!
	return resp.value
}

// clear - Clears the text of an input or textarea element
pub fn (wd WebDriver) clear(el ElementRef) ! {
	wd.post_void('/session/${wd.session_id}/element/${el.element_id}/clear', map[string]json.Any{})!
}

// submit - This method submits the form containing the given element
// If the element is not a form or inside a form, this will throw an error
// W3C Note: This is a convenience method that uses JavaScript
pub fn (wd WebDriver) submit(el ElementRef) ! {
	// Find the form element - if el is a form, use it, otherwise find the parent form
	script := 'var form = arguments[0].form || arguments[0]; if (form.tagName === "FORM") { form.submit(); } else { throw new Error("Element is not a form or inside a form"); }'
	wd.execute_script(script, [json.Any(json.encode(el))])!
}

// get_element_rect - Get the bounding rectangle of an element
// Returns the element's position (x, y) and size (width, height) in pixels
// W3C Endpoint: GET /session/{session id}/element/{element id}/rect
pub fn (wd WebDriver) get_element_rect(el ElementRef) !ElementRect {
	resp := wd.get_request[ElementRect]('/session/${wd.session_id}/element/${el.element_id}/rect')!
	return resp.value
}

// get_css_value - Get the computed CSS value of an element property
// Returns the computed value of the specified CSS property
// W3C Endpoint: GET /session/{session id}/element/{element id}/css/{property name}
// Example: get_css_value(element, 'color') returns 'rgba(0, 0, 0, 1)'
pub fn (wd WebDriver) get_css_value(el ElementRef, property_name string) !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/element/${el.element_id}/css/${property_name}')!
	return resp.value
}

// get_shadow_root - Get the shadow root of an element
// Returns a ShadowRoot object that can be used to find elements within the shadow DOM
// W3C Endpoint: GET /session/{session id}/element/{element id}/shadow
// Example: shadow := wd.get_shadow_root(host_element)!
pub fn (wd WebDriver) get_shadow_root(el ElementRef) !ShadowRoot {
	resp := wd.get_request[ShadowRoot]('/session/${wd.session_id}/element/${el.element_id}/shadow')!
	return resp.value
}

// find_element_in_shadow_root - Find an element within a shadow root
// Uses the same locator strategies as find_element (css selector, xpath, etc.)
// W3C Endpoint: POST /session/{session id}/shadow/{shadow id}/element
// Example: element := wd.find_element_in_shadow_root(shadow, 'css selector', '.inner-element')!
pub fn (wd WebDriver) find_element_in_shadow_root(shadow ShadowRoot, using string, value string) !ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[ElementRef]('/session/${wd.session_id}/shadow/${shadow.shadow_id}/element',
		json.Any(params))!
	return resp.value
}

// find_elements_in_shadow_root - Find all elements within a shadow root matching the locator
// W3C Endpoint: POST /session/{session id}/shadow/{shadow id}/elements
// Example: elements := wd.find_elements_in_shadow_root(shadow, 'css selector', '.items')!
pub fn (wd WebDriver) find_elements_in_shadow_root(shadow ShadowRoot, using string, value string) ![]ElementRef {
	mut params := map[string]json.Any{}
	params['using'] = json.Any(using)
	params['value'] = json.Any(value)
	resp := wd.post[[]ElementRef]('/session/${wd.session_id}/shadow/${shadow.shadow_id}/elements',
		json.Any(params))!
	return resp.value
}

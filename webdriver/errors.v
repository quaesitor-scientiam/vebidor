module webdriver

import x.json2 as json

pub enum WebDriverErrorType {
	no_such_element
	no_such_window
	no_such_frame
	stale_element_reference
	element_not_interactable
	invalid_argument
	timeout
	javascript_error
	unknown_error
}

pub struct WebDriverError {
pub:
	kind    WebDriverErrorType
	message string
}

pub fn (err WebDriverError) str() string {
	return '${err.kind}: ${err.message}'
}

pub fn parse_error(body string) !WebDriverError {
	// Try to decode the WebDriver error structure
	decoded := json.decode[map[string]json.Any](body) or {
		return error('Invalid WebDriver error response: ${err}')
	}

	if 'value' !in decoded {
		return error('Unknown WebDriver error')
	}

	val := decoded['value'] or { return error('Invalid error payload') }

	err_name := val.as_map()['error'] or { 'unknown error' }.str()
	msg := val.as_map()['message'] or { '' }.str()

	kind := match err_name {
		'no such element' { WebDriverErrorType.no_such_element }
		'no such window' { WebDriverErrorType.no_such_window }
		'no such frame' { WebDriverErrorType.no_such_frame }
		'stale element reference' { WebDriverErrorType.stale_element_reference }
		'element not interactable' { WebDriverErrorType.element_not_interactable }
		'invalid argument' { WebDriverErrorType.invalid_argument }
		'timeout' { WebDriverErrorType.timeout }
		'javascript error' { WebDriverErrorType.javascript_error }
		else { WebDriverErrorType.unknown_error }
	}

	return WebDriverError{
		kind:    kind
		message: msg
	}
}

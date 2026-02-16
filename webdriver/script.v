module webdriver

import x.json2 as json

pub fn (wd WebDriver) execute_script(script string, args []json.Any) !json.Any {
	mut params := map[string]json.Any{}
	params['script'] = json.Any(script)
	params['args'] = json.Any(args)
	resp := wd.post[json.Any]('/session/${wd.session_id}/execute/sync', json.Any(params))!
	return resp.value
}

// Execute asynchronous JavaScript in the current browsing context
// The script should call the callback (last argument) when complete
// W3C Endpoint: POST /session/{session id}/execute/async
// Example: execute_async_script('setTimeout(arguments[arguments.length - 1], 1000)', [])
pub fn (wd WebDriver) execute_async_script(script string, args []json.Any) !json.Any {
	mut params := map[string]json.Any{}
	params['script'] = json.Any(script)
	params['args'] = json.Any(args)
	resp := wd.post[json.Any]('/session/${wd.session_id}/execute/async', json.Any(params))!
	return resp.value
}

module webdriver

import x.json2 as json

pub fn (wd WebDriver) execute_script(script string, args []json.Any) !json.Any {
	mut params := map[string]json.Any{}
	params['script'] = json.Any(script)
	params['args'] = json.Any(args)
	resp := wd.post[json.Any]('/session/${wd.session_id}/execute/sync', json.Any(params))!
	return resp.value
}

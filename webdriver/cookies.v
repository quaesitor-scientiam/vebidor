module webdriver

import x.json2 as json

pub struct Cookie {
pub mut:
	name      string
	value     string
	path      ?string
	domain    ?string
	secure    ?bool
	http_only ?bool @[json: 'httpOnly']
}

pub fn (wd WebDriver) get_cookies() ![]Cookie {
	resp := wd.get_request[[]Cookie]('/session/${wd.session_id}/cookie')!
	return resp.value
}

pub fn (wd WebDriver) add_cookie(cookie Cookie) ! {
	mut payload := map[string]json.Any{}
	payload['cookie'] = json.Any(json.map_from(cookie))
	wd.post_void('/session/${wd.session_id}/cookie', payload)!
}

pub fn (wd WebDriver) delete_cookie(name string) ! {
	wd.delete_void('/session/${wd.session_id}/cookie/${name}')!
}

pub fn (wd WebDriver) delete_all_cookies() ! {
	wd.delete_void('/session/${wd.session_id}/cookie')!
}

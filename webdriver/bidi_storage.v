module webdriver

import x.json2 as json

// BiDi `storage` module: cookie access plus the cookieChanged event (reacting
// to cookie mutations), which the Classic cookie API cannot offer.

// get_cookies returns the cookies visible to the session as a raw JSON array.
pub fn (mut b BiDi) get_cookies() !json.Any {
	res := b.send('storage.getCookies', json.Any(map[string]json.Any{}))!
	return res.as_map()['cookies'] or { json.Any([]json.Any{}) }
}

// set_cookie sets a cookie for a domain (value is sent as a string BytesValue).
pub fn (mut b BiDi) set_cookie(name string, value string, domain string) ! {
	mut bytes_value := map[string]json.Any{}
	bytes_value['type'] = json.Any('string')
	bytes_value['value'] = json.Any(value)

	mut cookie := map[string]json.Any{}
	cookie['name'] = json.Any(name)
	cookie['value'] = json.Any(bytes_value)
	cookie['domain'] = json.Any(domain)

	mut p := map[string]json.Any{}
	p['cookie'] = json.Any(cookie)
	b.send('storage.setCookie', json.Any(p))!
}

// delete_cookies removes all cookies matching no filter (i.e. all of them).
pub fn (mut b BiDi) delete_cookies() ! {
	b.send('storage.deleteCookies', json.Any(map[string]json.Any{}))!
}

// on_cookie_changed subscribes to storage.cookieChanged and invokes the handler
// with the raw event params for each change.
pub fn (mut b BiDi) on_cookie_changed(handler BiDiEventHandler) ! {
	b.on('storage.cookieChanged', handler)
	b.subscribe(['storage.cookieChanged'])!
}

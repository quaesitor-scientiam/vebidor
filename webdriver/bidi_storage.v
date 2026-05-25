module webdriver

import x.json2 as json

// BiDi `storage` module: cookie access plus the cookieChanged event (reacting
// to cookie mutations), which the Classic cookie API cannot offer.
//
// Cookie operations are partition-aware: pass a CookiePartition to scope them to
// a specific user context (browser.newContext equivalent) or browsing context.
// With no partition they operate on the default partition.

// CookiePartition selects the storage partition for a cookie operation. Leave
// both fields empty for the default partition. `user_context` scopes to a user
// context (from create_user_context); `context` scopes to a browsing context id.
@[params]
pub struct CookiePartition {
pub:
	user_context string
	context      string
}

// descriptor builds the BiDi PartitionDescriptor, or none for the default.
fn (p CookiePartition) descriptor() ?json.Any {
	if p.context != '' {
		return json.Any({
			'type':    json.Any('context')
			'context': json.Any(p.context)
		})
	}
	if p.user_context != '' {
		return json.Any({
			'type':        json.Any('storageKey')
			'userContext': json.Any(p.user_context)
		})
	}
	return none
}

// get_cookies returns the cookies in a partition as a raw JSON array.
// Examples:
//   bidi.get_cookies()!                          // default partition
//   bidi.get_cookies(user_context: uc)!          // a specific user context
pub fn (mut b BiDi) get_cookies(partition CookiePartition) !json.Any {
	mut params := map[string]json.Any{}
	if d := partition.descriptor() {
		params['partition'] = d
	}
	res := b.send('storage.getCookies', json.Any(params))!
	return res.as_map()['cookies'] or { json.Any([]json.Any{}) }
}

// set_cookie sets a cookie for a domain (value sent as a string BytesValue),
// optionally scoped to a partition.
pub fn (mut b BiDi) set_cookie(name string, value string, domain string, partition CookiePartition) ! {
	mut bytes_value := map[string]json.Any{}
	bytes_value['type'] = json.Any('string')
	bytes_value['value'] = json.Any(value)

	mut cookie := map[string]json.Any{}
	cookie['name'] = json.Any(name)
	cookie['value'] = json.Any(bytes_value)
	cookie['domain'] = json.Any(domain)

	mut p := map[string]json.Any{}
	p['cookie'] = json.Any(cookie)
	if d := partition.descriptor() {
		p['partition'] = d
	}
	b.send('storage.setCookie', json.Any(p))!
}

// delete_cookies removes all cookies in a partition (no filter).
pub fn (mut b BiDi) delete_cookies(partition CookiePartition) ! {
	mut params := map[string]json.Any{}
	if d := partition.descriptor() {
		params['partition'] = d
	}
	b.send('storage.deleteCookies', json.Any(params))!
}

// on_cookie_changed subscribes to storage.cookieChanged and invokes the handler
// with the raw event params for each change.
pub fn (mut b BiDi) on_cookie_changed(handler BiDiEventHandler) ! {
	b.on('storage.cookieChanged', handler)
	b.subscribe(['storage.cookieChanged'])!
}

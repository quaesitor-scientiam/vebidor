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

// StorageState is a serializable snapshot of a partition's cookies (Playwright
// storageState, cookie portion). Capture it from an authenticated context and
// apply it to a fresh one to reuse a session without logging in again.
//
// Note: this currently captures cookies only. localStorage/sessionStorage are
// not yet included (they require per-origin script evaluation); read those via
// evaluate() in a navigated context if needed.
pub struct StorageState {
pub:
	cookies json.Any // raw cookie array as returned by get_cookies
}

// storage_state captures the cookies of a partition.
pub fn (mut b BiDi) storage_state(partition CookiePartition) !StorageState {
	return StorageState{
		cookies: b.get_cookies(partition)!
	}
}

// add_cookies re-adds a set of cookies (as returned by get_cookies/storage_state)
// to a partition. Each cookie is rebuilt from only the writable fields —
// get_cookies returns read-only/extension fields (size, goog:* metadata) that
// storage.setCookie accepts but then silently drops the cookie over, so they
// must be stripped for a faithful round-trip.
pub fn (mut b BiDi) add_cookies(cookies json.Any, partition CookiePartition) ! {
	descriptor := partition.descriptor()
	for c in cookies.as_array() {
		cm := c.as_map()
		mut cookie := map[string]json.Any{}
		cookie['name'] = cm['name'] or { continue }
		cookie['value'] = cm['value'] or { continue }
		cookie['domain'] = cm['domain'] or { json.Any('') }
		if v := cm['path'] {
			cookie['path'] = v
		}
		if v := cm['httpOnly'] {
			cookie['httpOnly'] = v
		}
		if v := cm['expiry'] {
			cookie['expiry'] = v
		}
		// Preserve secure; carry sameSite only when it isn't the invalid
		// None-without-Secure combo (browsers reject that on set).
		secure := if v := cm['secure'] { v.bool() } else { false }
		if secure {
			cookie['secure'] = json.Any(true)
		}
		if v := cm['sameSite'] {
			ss := v.str()
			if ss != '' && !(ss.to_lower() == 'none' && !secure) {
				cookie['sameSite'] = v
			}
		}
		mut p := map[string]json.Any{}
		p['cookie'] = json.Any(cookie)
		if d := descriptor {
			p['partition'] = d
		}
		b.send('storage.setCookie', json.Any(p))!
	}
}

// apply_storage_state restores a captured StorageState's cookies into a
// partition (e.g. a freshly created user context), reusing a logged-in session.
pub fn (mut b BiDi) apply_storage_state(state StorageState, partition CookiePartition) ! {
	b.add_cookies(state.cookies, partition)!
}

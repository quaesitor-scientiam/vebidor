module webdriver

import x.json2 as json

// BiDi `browser`/`browsingContext` helpers for isolated user contexts — the
// equivalent of Playwright's browser.newContext(): independent cookies and
// storage within a single browser instance.

// create_user_context creates a new isolated user context (cookie/storage jar)
// and returns its id.
pub fn (mut b BiDi) create_user_context() !string {
	res := b.send('browser.createUserContext', json.Any(map[string]json.Any{}))!
	return (res.as_map()['userContext'] or { json.Any('') }).str()
}

// remove_user_context removes a user context and closes its contexts.
pub fn (mut b BiDi) remove_user_context(user_context string) ! {
	mut p := map[string]json.Any{}
	p['userContext'] = json.Any(user_context)
	b.send('browser.removeUserContext', json.Any(p))!
}

// create_context opens a new top-level browsing context (tab). Pass a
// user_context id to open it inside an isolated context, or '' for the default.
pub fn (mut b BiDi) create_context(user_context string) !string {
	mut p := map[string]json.Any{}
	p['type'] = json.Any('tab')
	if user_context != '' {
		p['userContext'] = json.Any(user_context)
	}
	res := b.send('browsingContext.create', json.Any(p))!
	return (res.as_map()['context'] or { json.Any('') }).str()
}

// close_context closes a top-level browsing context (tab).
pub fn (mut b BiDi) close_context(context string) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	b.send('browsingContext.close', json.Any(p))!
}

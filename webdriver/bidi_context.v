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

// get_user_contexts returns the ids of all user contexts.
pub fn (mut b BiDi) get_user_contexts() ![]string {
	res := b.send('browser.getUserContexts', json.Any(map[string]json.Any{}))!
	mut ids := []string{}
	if ucs := res.as_map()['userContexts'] {
		for uc in ucs.as_array() {
			if id := uc.as_map()['userContext'] {
				ids << id.str()
			}
		}
	}
	return ids
}

// set_viewport overrides a context's viewport size (device emulation).
pub fn (mut b BiDi) set_viewport(context string, width int, height int) ! {
	mut vp := map[string]json.Any{}
	vp['width'] = json.Any(width)
	vp['height'] = json.Any(height)
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['viewport'] = json.Any(vp)
	b.send('browsingContext.setViewport', json.Any(p))!
}

// set_device_pixel_ratio overrides a context's device pixel ratio.
pub fn (mut b BiDi) set_device_pixel_ratio(context string, ratio f64) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['devicePixelRatio'] = json.Any(ratio)
	b.send('browsingContext.setViewport', json.Any(p))!
}

// print_pdf renders a context to PDF and returns base64-encoded bytes.
pub fn (mut b BiDi) print_pdf(context string) !string {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	res := b.send('browsingContext.print', json.Any(p))!
	return (res.as_map()['data'] or { json.Any('') }).str()
}

// save_pdf renders a context to PDF and writes it to a file.
pub fn (mut b BiDi) save_pdf(context string, path string) ! {
	write_base64_file(path, b.print_pdf(context)!)!
}

// traverse_history moves a context back (negative) or forward (positive) in its
// history by `delta` entries.
pub fn (mut b BiDi) traverse_history(context string, delta int) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['delta'] = json.Any(delta)
	b.send('browsingContext.traverseHistory', json.Any(p))!
}

// activate brings a context (tab) to the foreground.
pub fn (mut b BiDi) activate(context string) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	b.send('browsingContext.activate', json.Any(p))!
}

// handle_user_prompt accepts or dismisses an open alert/confirm/prompt dialog,
// optionally supplying text for a prompt.
pub fn (mut b BiDi) handle_user_prompt(context string, accept bool, user_text string) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['accept'] = json.Any(accept)
	if user_text != '' {
		p['userText'] = json.Any(user_text)
	}
	b.send('browsingContext.handleUserPrompt', json.Any(p))!
}

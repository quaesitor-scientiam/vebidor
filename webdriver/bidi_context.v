module webdriver

import x.json2 as json

// BiDi `browser`/`browsingContext` helpers for isolated user contexts — the
// equivalent of Playwright's browser.newContext(): independent cookies and
// storage within a single browser instance.

// UserContextOptions configures a new user context (Playwright newContext-style
// per-context settings). All fields optional; omit for a plain isolated context.
@[params]
pub struct UserContextOptions {
pub:
	accept_insecure_certs ?bool
	proxy_type            string // 'manual' | 'system' | 'direct' | 'autodetect' | 'pac'
	http_proxy            string // host:port, used when proxy_type == 'manual'
	ssl_proxy             string // host:port, used when proxy_type == 'manual'
}

// create_user_context creates a new isolated user context (cookie/storage jar)
// and returns its id. Pass UserContextOptions for a per-context proxy or
// insecure-cert policy:
//   bidi.create_user_context(proxy_type: 'manual', http_proxy: '127.0.0.1:8080')!
pub fn (mut b BiDi) create_user_context(opts UserContextOptions) !string {
	mut params := map[string]json.Any{}
	if aic := opts.accept_insecure_certs {
		params['acceptInsecureCerts'] = json.Any(aic)
	}
	if opts.proxy_type != '' {
		mut proxy := map[string]json.Any{}
		proxy['proxyType'] = json.Any(opts.proxy_type)
		if opts.http_proxy != '' {
			proxy['httpProxy'] = json.Any(opts.http_proxy)
		}
		if opts.ssl_proxy != '' {
			proxy['sslProxy'] = json.Any(opts.ssl_proxy)
		}
		params['proxy'] = json.Any(proxy)
	}
	res := b.send('browser.createUserContext', json.Any(params))!
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

// --- per-context conveniences (emulation / permissions modules) ---
//
// These map to newer BiDi modules whose support varies by browser/driver. If a
// driver hasn't implemented them, the call returns a clear "unknown command"
// error (see status() to probe readiness) rather than failing silently.

// set_geolocation overrides geolocation for a user context (Playwright
// context.setGeolocation). Pass an empty user_context to leave it to the driver
// default. BiDi module: emulation.setGeolocationOverride.
pub fn (mut b BiDi) set_geolocation(user_context string, latitude f64, longitude f64, accuracy f64) ! {
	mut coords := map[string]json.Any{}
	coords['latitude'] = json.Any(latitude)
	coords['longitude'] = json.Any(longitude)
	coords['accuracy'] = json.Any(accuracy)
	mut p := map[string]json.Any{}
	p['coordinates'] = json.Any(coords)
	if user_context != '' {
		p['userContexts'] = json.Any([json.Any(user_context)])
	}
	b.send('emulation.setGeolocationOverride', json.Any(p))!
}

// set_permission grants/denies a permission for an origin, optionally scoped to
// a user context (Playwright context.grantPermissions). `state` is
// 'granted' | 'denied' | 'prompt'. BiDi module: permissions.setPermission.
pub fn (mut b BiDi) set_permission(name string, state string, origin string, user_context string) ! {
	mut desc := map[string]json.Any{}
	desc['name'] = json.Any(name)
	mut p := map[string]json.Any{}
	p['descriptor'] = json.Any(desc)
	p['state'] = json.Any(state)
	p['origin'] = json.Any(origin)
	if user_context != '' {
		p['userContext'] = json.Any(user_context)
	}
	b.send('permissions.setPermission', json.Any(p))!
}

// set_locale overrides the locale (BCP 47, e.g. 'fr-FR') for a browsing context.
// BiDi module: emulation.setLocaleOverride (driver-dependent — probe with supports()).
pub fn (mut b BiDi) set_locale(context string, locale string) ! {
	mut p := map[string]json.Any{}
	p['locale'] = json.Any(locale)
	p['contexts'] = json.Any([json.Any(context)])
	b.send('emulation.setLocaleOverride', json.Any(p))!
}

// set_timezone overrides the timezone (IANA, e.g. 'America/New_York') for a
// browsing context. BiDi module: emulation.setTimezoneOverride.
pub fn (mut b BiDi) set_timezone(context string, timezone string) ! {
	mut p := map[string]json.Any{}
	p['timezone'] = json.Any(timezone)
	p['contexts'] = json.Any([json.Any(context)])
	b.send('emulation.setTimezoneOverride', json.Any(p))!
}

// set_screen_orientation overrides the screen orientation for a browsing context.
// natural is 'portrait' | 'landscape'; orientation_type is one of
// 'portrait-primary' | 'portrait-secondary' | 'landscape-primary' |
// 'landscape-secondary'. BiDi module: emulation.setScreenOrientationOverride.
pub fn (mut b BiDi) set_screen_orientation(context string, natural string, orientation_type string) ! {
	mut so := map[string]json.Any{}
	so['natural'] = json.Any(natural)
	so['type'] = json.Any(orientation_type)
	mut p := map[string]json.Any{}
	p['screenOrientation'] = json.Any(so)
	p['contexts'] = json.Any([json.Any(context)])
	b.send('emulation.setScreenOrientationOverride', json.Any(p))!
}

// BiDiStatus reports whether the remote end is ready for new sessions.
pub struct BiDiStatus {
pub:
	ready   bool
	message string
}

// status queries session.status — a readiness probe. Combined with the clear
// "unknown command" errors from optional modules (geolocation/permissions),
// this lets callers detect what the connected driver actually supports rather
// than assuming uniform BiDi conformance across browsers.
pub fn (mut b BiDi) status() !BiDiStatus {
	res := b.send('session.status', json.Any(map[string]json.Any{}))!
	m := res.as_map()
	return BiDiStatus{
		ready:   (m['ready'] or { json.Any(false) }).bool()
		message: (m['message'] or { json.Any('') }).str()
	}
}

// supports reports whether the driver implements a BiDi command, by issuing it
// and checking the error is not "unknown command". Useful to feature-detect the
// optional modules (emulation, permissions) before relying on them.
pub fn (mut b BiDi) supports(method string, params json.Any) bool {
	b.send(method, params) or { return !err.msg().contains('unknown command') }
	return true
}

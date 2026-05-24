module webdriver

import x.json2 as json

// BiDi `network` module: request/response observation and interception/mocking
// (Playwright `page.route` style). Interception requires a BiDi session.
//
// Concurrency: route/observer handlers run on spawned threads (see BiDi dispatch),
// so a route handler may freely call continue_request/fulfill/abort, each of
// which issues its own BiDi command and waits for the reply.

// NetworkEvent is a request or response observed on the network.
pub struct NetworkEvent {
pub:
	request_id string
	url        string
	method     string // set for requests
	status     int    // set for responses
}

// RouteHandler decides what to do with an intercepted request. It MUST resolve
// every request it receives via continue_request(), fulfill(), or abort(),
// otherwise the page will hang waiting on that request.
pub type RouteHandler = fn (req InterceptedRequest)

// InterceptedRequest is a blocked request awaiting a routing decision.
pub struct InterceptedRequest {
pub:
	bidi       &BiDi
	request_id string
	url        string
	method     string
}

// add_intercept registers a network interception for the given phases and
// returns its intercept id. With no urlPatterns it matches all requests.
fn (mut b BiDi) add_intercept(phases []string) !string {
	mut arr := []json.Any{}
	for p in phases {
		arr << json.Any(p)
	}
	mut params := map[string]json.Any{}
	params['phases'] = json.Any(arr)
	res := b.send('network.addIntercept', json.Any(params))!
	return (res.as_map()['intercept'] or { json.Any('') }).str()
}

// route intercepts every outgoing request (beforeRequestSent) and invokes
// `handler`. The handler must resolve each request (continue/fulfill/abort).
// Call this before navigating so the intercept is in place.
pub fn (mut b BiDi) route(handler RouteHandler) ! {
	b.add_intercept(['beforeRequestSent'])!
	bptr := voidptr(&b)
	b.on('network.beforeRequestSent', fn [bptr, handler] (params json.Any) {
		bref := unsafe { &BiDi(bptr) }
		m := params.as_map()
		rq := (m['request'] or { json.Any(map[string]json.Any{}) }).as_map()
		req := InterceptedRequest{
			bidi:       bref
			request_id: (rq['request'] or { json.Any('') }).str()
			url:        (rq['url'] or { json.Any('') }).str()
			method:     (rq['method'] or { json.Any('') }).str()
		}
		handler(req)
	})
	b.subscribe(['network.beforeRequestSent'])!
}

// continue_request lets a blocked request proceed unmodified.
pub fn (r InterceptedRequest) continue_request() ! {
	mut p := map[string]json.Any{}
	p['request'] = json.Any(r.request_id)
	mut b := r.bidi
	b.send('network.continueRequest', json.Any(p))!
}

// abort fails a blocked request (Playwright route.abort()).
pub fn (r InterceptedRequest) abort() ! {
	mut p := map[string]json.Any{}
	p['request'] = json.Any(r.request_id)
	mut b := r.bidi
	b.send('network.failRequest', json.Any(p))!
}

// fulfill responds to a blocked request with a mock response (Playwright
// route.fulfill()).
pub fn (r InterceptedRequest) fulfill(status int, content_type string, body string) ! {
	mut b := r.bidi
	provide_response(mut b, r.request_id, status, content_type, body)!
}

// provide_response is the shared network.provideResponse implementation used by
// both request- and response-phase interception.
fn provide_response(mut b BiDi, request_id string, status int, content_type string, body string) ! {
	mut header_value := map[string]json.Any{}
	header_value['type'] = json.Any('string')
	header_value['value'] = json.Any(content_type)
	mut header := map[string]json.Any{}
	header['name'] = json.Any('Content-Type')
	header['value'] = json.Any(header_value)

	mut body_value := map[string]json.Any{}
	body_value['type'] = json.Any('string')
	body_value['value'] = json.Any(body)

	mut p := map[string]json.Any{}
	p['request'] = json.Any(request_id)
	p['statusCode'] = json.Any(status)
	p['reasonPhrase'] = json.Any('OK')
	p['headers'] = json.Any([json.Any(header)])
	p['body'] = json.Any(body_value)

	b.send('network.provideResponse', json.Any(p))!
}

// on_auth installs an auth handler that answers every HTTP authentication
// challenge (network.authRequired) with the given credentials. Equivalent to
// Selenium's NetworkInterceptor basic-auth handler.
pub fn (mut b BiDi) on_auth(username string, password string) ! {
	b.add_intercept(['authRequired'])!
	bptr := voidptr(&b)
	b.on('network.authRequired', fn [bptr, username, password] (params json.Any) {
		mut bref := unsafe { &BiDi(bptr) }
		rq := (params.as_map()['request'] or { json.Any(map[string]json.Any{}) }).as_map()
		rid := (rq['request'] or { json.Any('') }).str()
		mut creds := map[string]json.Any{}
		creds['type'] = json.Any('password')
		creds['username'] = json.Any(username)
		creds['password'] = json.Any(password)
		mut p := map[string]json.Any{}
		p['request'] = json.Any(rid)
		p['action'] = json.Any('provideCredentials')
		p['credentials'] = json.Any(creds)
		bref.send('network.continueWithAuth', json.Any(p)) or {}
	})
	b.subscribe(['network.authRequired'])!
}

// ResponseRouteHandler decides what to do with an intercepted response.
pub type ResponseRouteHandler = fn (resp InterceptedResponse)

// InterceptedResponse is a response paused at the responseStarted phase.
pub struct InterceptedResponse {
pub:
	bidi       &BiDi
	request_id string
	url        string
	status     int
}

// route_response intercepts responses (responseStarted phase) so headers/status
// can be inspected before the body is delivered. The handler must resolve each
// response via continue_response(), fulfill(), or abort().
pub fn (mut b BiDi) route_response(handler ResponseRouteHandler) ! {
	b.add_intercept(['responseStarted'])!
	bptr := voidptr(&b)
	b.on('network.responseStarted', fn [bptr, handler] (params json.Any) {
		bref := unsafe { &BiDi(bptr) }
		m := params.as_map()
		rq := (m['request'] or { json.Any(map[string]json.Any{}) }).as_map()
		rp := (m['response'] or { json.Any(map[string]json.Any{}) }).as_map()
		resp := InterceptedResponse{
			bidi:       bref
			request_id: (rq['request'] or { json.Any('') }).str()
			url:        (rq['url'] or { json.Any('') }).str()
			status:     (rp['status'] or { json.Any(0) }).int()
		}
		handler(resp)
	})
	b.subscribe(['network.responseStarted'])!
}

// continue_response lets a paused response proceed. The observed status and a
// matching reason phrase are echoed back: some drivers (e.g. EdgeDriver) reject
// continueResponse without a valid statusCode/reasonPhrase even though the spec
// marks them optional.
pub fn (r InterceptedResponse) continue_response() ! {
	mut p := map[string]json.Any{}
	p['request'] = json.Any(r.request_id)
	if r.status > 0 {
		p['statusCode'] = json.Any(r.status)
		p['reasonPhrase'] = json.Any(reason_phrase(r.status))
	}
	mut b := r.bidi
	b.send('network.continueResponse', json.Any(p))!
}

// reason_phrase returns a standard HTTP reason phrase for a status code.
fn reason_phrase(status int) string {
	return match status {
		200 { 'OK' }
		201 { 'Created' }
		202 { 'Accepted' }
		204 { 'No Content' }
		301 { 'Moved Permanently' }
		302 { 'Found' }
		303 { 'See Other' }
		304 { 'Not Modified' }
		307 { 'Temporary Redirect' }
		308 { 'Permanent Redirect' }
		400 { 'Bad Request' }
		401 { 'Unauthorized' }
		403 { 'Forbidden' }
		404 { 'Not Found' }
		500 { 'Internal Server Error' }
		502 { 'Bad Gateway' }
		503 { 'Service Unavailable' }
		else { 'OK' }
	}
}

// abort fails the response's request.
pub fn (r InterceptedResponse) abort() ! {
	mut p := map[string]json.Any{}
	p['request'] = json.Any(r.request_id)
	mut b := r.bidi
	b.send('network.failRequest', json.Any(p))!
}

// fulfill replaces the response with a mock one.
pub fn (r InterceptedResponse) fulfill(status int, content_type string, body string) ! {
	mut b := r.bidi
	provide_response(mut b, r.request_id, status, content_type, body)!
}

// on_request observes outgoing requests (no interception/blocking).
pub fn (mut b BiDi) on_request(handler fn (ev NetworkEvent)) ! {
	b.on('network.beforeRequestSent', fn [handler] (params json.Any) {
		m := params.as_map()
		rq := (m['request'] or { json.Any(map[string]json.Any{}) }).as_map()
		handler(NetworkEvent{
			request_id: (rq['request'] or { json.Any('') }).str()
			url:        (rq['url'] or { json.Any('') }).str()
			method:     (rq['method'] or { json.Any('') }).str()
		})
	})
	b.subscribe(['network.beforeRequestSent'])!
}

// on_response observes completed responses.
pub fn (mut b BiDi) on_response(handler fn (ev NetworkEvent)) ! {
	b.on('network.responseCompleted', fn [handler] (params json.Any) {
		m := params.as_map()
		resp := (m['response'] or { json.Any(map[string]json.Any{}) }).as_map()
		handler(NetworkEvent{
			request_id: (resp['request'] or { json.Any('') }).str()
			url:        (resp['url'] or { json.Any('') }).str()
			status:     (resp['status'] or { json.Any(0) }).int()
		})
	})
	b.subscribe(['network.responseCompleted'])!
}

module webdriver

// Transport-agnostic command result. Both the HTTP (WebDriver Classic)
// transport and the BiDi (WebSocket) transport return this shape so the
// generic decode helpers on WebDriver don't care how the bytes arrived.
//
// This file owns the small, protocol-agnostic transport surface so that
// future siblings (e.g. `vebidor.mobile` talking to WebDriverAgent or the
// UiAutomator2 server, both of which speak HTTP JSON) can import these
// types without dragging Classic-WebDriver semantics.
pub struct Response {
pub:
	status_code int
	body        string
}

// Transport abstracts the mechanism used to talk to the browser/driver.
// HttpTransport implements WebDriver Classic over HTTP today; a
// WebDriver-BiDi transport over a WebSocket satisfies the same interface,
// letting both coexist behind a single WebDriver type.
pub interface Transport {
	execute(method string, url string, content_type string, body string) !Response
}

// HttpTransport speaks WebDriver Classic: one HTTP round-trip per command.
// The actual HTTP send lives in `wd_do` (`client.v`) — both files are in the
// same module so the forward reference is fine.
pub struct HttpTransport {}

fn (t HttpTransport) execute(method string, url string, content_type string, body string) !Response {
	resp := wd_do(method, url, content_type, body)!
	return Response{
		status_code: resp.status_code
		body:        resp.body
	}
}

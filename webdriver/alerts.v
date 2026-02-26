module webdriver

import x.json2 as json

// accept_alert - Accept an alert, confirm, or prompt dialog
// W3C Endpoint: POST /session/{session id}/alert/accept
pub fn (wd WebDriver) accept_alert() ! {
	wd.post_void('/session/${wd.session_id}/alert/accept', map[string]json.Any{})!
}

// dismiss_alert - Dismiss an alert, confirm, or prompt dialog
// W3C Endpoint: POST /session/{session id}/alert/dismiss
pub fn (wd WebDriver) dismiss_alert() ! {
	wd.post_void('/session/${wd.session_id}/alert/dismiss', map[string]json.Any{})!
}

// get_alert_text - Get the text from an alert, confirm, or prompt dialog
// W3C Endpoint: GET /session/{session id}/alert/text
pub fn (wd WebDriver) get_alert_text() !string {
	resp := wd.get_request[string]('/session/${wd.session_id}/alert/text')!
	return resp.value
}

// send_alert_text - Send text to a prompt dialog
// W3C Endpoint: POST /session/{session id}/alert/text
pub fn (wd WebDriver) send_alert_text(text string) ! {
	mut payload := map[string]json.Any{}
	payload['text'] = json.Any(text)
	wd.post_void('/session/${wd.session_id}/alert/text', json.Any(payload))!
}

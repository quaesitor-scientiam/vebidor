module webdriver

import x.json2 as json

pub struct ActionItem {
	pub:
	kind     string  @[json: 'type'] // keyDown, keyUp, pointerMove, pause, etc.
	value    ?string
	duration ?int
	x        ?int
	y        ?int
	button   ?int
	delta_x  ?int
	delta_y  ?int
	delta_z  ?int
}

pub struct ActionSource {
	pub:
	kind    string        @[json: 'type'] // key, pointer, wheel
	id      string
	actions []ActionItem
}

pub struct ActionsPayload {
	pub:
	actions []ActionSource
}

// builders

pub fn key_down(key string) ActionItem {
	return ActionItem{
		kind: 'keyDown'
		value: key
	}
}

pub fn key_up(key string) ActionItem {
	return ActionItem{
		kind: 'keyUp'
		value: key
	}
}

pub fn pause(ms int) ActionItem {
	return ActionItem{
		kind: 'pause'
		duration: ms
	}
}

pub fn pointer_move(x int, y int, duration int) ActionItem {
	return ActionItem{
		kind: 'pointerMove'
		x: x
		y: y
		duration: duration
	}
}

pub fn pointer_down(button int) ActionItem {
	return ActionItem{
		kind: 'pointerDown'
		button: button
	}
}

pub fn pointer_up(button int) ActionItem {
	return ActionItem{
		kind: 'pointerUp'
		button: button
	}
}

pub fn keyboard(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind: 'key'
		id: id
		actions: actions
	}
}

pub fn mouse(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind: 'pointer'
		id: id
		actions: actions
	}
}

pub fn wheel(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind: 'wheel'
		id: id
		actions: actions
	}
}

pub fn wheel_scroll(x int, y int, delta_x int, delta_y int) ActionItem {
	return ActionItem{
		kind: 'scroll'
		x: x
		y: y
		delta_x: delta_x
		delta_y: delta_y
	}
}

// send to WebDriver

pub fn (wd WebDriver) perform_actions(sources []ActionSource) ! {
	// Create the payload with actions array
	payload := ActionsPayload{
		actions: sources
	}
	// Encode the entire payload to JSON, then decode to json.Any
	// This is needed because the payload has complex nested structures
	encoded := json.encode(payload)
	decoded := json.decode[json.Any](encoded) or {
		return error('Failed to encode actions: ${err}')
	}
	wd.post_void('/session/${wd.session_id}/actions', decoded)!
}

pub fn (wd WebDriver) release_actions() ! {
	wd.delete_void('/session/${wd.session_id}/actions')!
}

// convenience

pub fn (wd WebDriver) type_text(text string) ! {
	mut items := []ActionItem{}
	for r in text.runes() {
		ch := r.str()
		items << key_down(ch)
		items << key_up(ch)
	}
	src := keyboard('keyboard', items)
	wd.perform_actions([src])!
}

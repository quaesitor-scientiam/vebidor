module webdriver

import x.json2 as json

pub struct ActionItem {
pub:
	kind     string @[json: 'type'] // keyDown, keyUp, pointerMove, pause, etc.
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
	kind    string @[json: 'type'] // key, pointer, wheel
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
		kind:  'keyDown'
		value: key
	}
}

pub fn key_up(key string) ActionItem {
	return ActionItem{
		kind:  'keyUp'
		value: key
	}
}

pub fn pause(ms int) ActionItem {
	return ActionItem{
		kind:     'pause'
		duration: ms
	}
}

pub fn pointer_move(x int, y int, duration int) ActionItem {
	return ActionItem{
		kind:     'pointerMove'
		x:        x
		y:        y
		duration: duration
	}
}

pub fn pointer_down(button int) ActionItem {
	return ActionItem{
		kind:   'pointerDown'
		button: button
	}
}

pub fn pointer_up(button int) ActionItem {
	return ActionItem{
		kind:   'pointerUp'
		button: button
	}
}

pub fn keyboard(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind:    'key'
		id:      id
		actions: actions
	}
}

pub fn mouse(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind:    'pointer'
		id:      id
		actions: actions
	}
}

pub fn wheel(id string, actions []ActionItem) ActionSource {
	return ActionSource{
		kind:    'wheel'
		id:      id
		actions: actions
	}
}

pub fn wheel_scroll(x int, y int, delta_x int, delta_y int) ActionItem {
	return ActionItem{
		kind:    'scroll'
		x:       x
		y:       y
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

// Advanced Actions - Phase 7

// context_click -Perform a context click (right-click) on an element
// This moves to the element's center and clicks the right mouse button (button 2)
pub fn (wd WebDriver) context_click(el ElementRef) ! {
	// Get element center position
	rect := wd.get_element_rect(el)!
	x := int(rect.x + rect.width / 2)
	y := int(rect.y + rect.height / 2)

	// Build action sequence: move to element, right-click (button 2)
	actions := [
		pointer_move(x, y, 0),
		pointer_down(2), // Right button = 2
		pointer_up(2),
	]
	src := mouse('mouse', actions)
	wd.perform_actions([src])!
}

// click_and_hold - Click and hold the left mouse button on an element
// The button remains pressed until release_held_button() is called
// This is useful for drag operations or interactive UI elements
pub fn (wd WebDriver) click_and_hold(el ElementRef) ! {
	// Get element center position
	rect := wd.get_element_rect(el)!
	x := int(rect.x + rect.width / 2)
	y := int(rect.y + rect.height / 2)

	// Move to element and press down (but don't release)
	actions := [
		pointer_move(x, y, 0),
		pointer_down(0), // Left button = 0, keep pressed
	]
	src := mouse('mouse', actions)
	wd.perform_actions([src])!
}

// release_held_button - Release the held mouse button
// This should be called after click_and_hold() to release the button
pub fn (wd WebDriver) release_held_button() ! {
	actions := [
		pointer_up(0), // Release left button
	]
	src := mouse('mouse', actions)
	wd.perform_actions([src])!
}

// drag_and_drop_to_element - Drag an element and drop it onto another element
// This performs a drag-and-drop operation from source to target
// Duration of 500ms is used for the drag motion (smooth movement)
pub fn (wd WebDriver) drag_and_drop_to_element(source ElementRef, target ElementRef) ! {
	// Get source and target center positions
	source_rect := wd.get_element_rect(source)!
	target_rect := wd.get_element_rect(target)!

	source_x := int(source_rect.x + source_rect.width / 2)
	source_y := int(source_rect.y + source_rect.height / 2)
	target_x := int(target_rect.x + target_rect.width / 2)
	target_y := int(target_rect.y + target_rect.height / 2)

	// Drag and drop: move to source, press, move to target, release
	actions := [
		pointer_move(source_x, source_y, 0),
		pointer_down(0),
		pointer_move(target_x, target_y, 500), // 500ms smooth drag
		pointer_up(0),
	]
	src := mouse('mouse', actions)
	wd.perform_actions([src])!
}

// drag_and_drop_by_offset - Drag an element by a specific pixel offset
// x_offset: horizontal pixels to drag (positive = right, negative = left)
// y_offset: vertical pixels to drag (positive = down, negative = up)
// Duration of 500ms is used for the drag motion
pub fn (wd WebDriver) drag_and_drop_by_offset(el ElementRef, x_offset int, y_offset int) ! {
	// Get element center position
	rect := wd.get_element_rect(el)!

	start_x := int(rect.x + rect.width / 2)
	start_y := int(rect.y + rect.height / 2)
	end_x := start_x + x_offset
	end_y := start_y + y_offset

	// Drag by offset: move to element, press, move by offset, release
	actions := [
		pointer_move(start_x, start_y, 0),
		pointer_down(0),
		pointer_move(end_x, end_y, 500), // 500ms smooth drag
		pointer_up(0),
	]
	src := mouse('mouse', actions)
	wd.perform_actions([src])!
}

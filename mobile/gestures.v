module mobile

import x.json2 as json

// Touch gestures. The W3C `/actions` endpoint takes one or more input
// sources (we use a single touch pointer for the gestures here) and an
// `actions` array that describes the gesture sequence: pointerMove,
// pointerDown, pause, pointerMove (interpolated), pointerUp.
//
// Three element-relative gestures (`long_press`, `swipe_*`, `drag_to`)
// compute the target coordinates from the element's rect first; three
// screen-relative ones (`tap_at`, `long_press_at`, `swipe`) take raw
// coordinates. `scroll_into_view` calls WDA's `scrollToVisible`
// extension because the W3C actions API can't express "scroll until X".

// tap_at sends a tap at the screen coordinate (x, y). No actionability
// check — the caller is responsible for knowing what's under the point.
pub fn (s MobileSession) tap_at(x int, y int) ! {
	body := touch_sequence([
		act_pointer_move(x, y, 0),
		act_pointer_down(),
		act_pause(50),
		act_pointer_up(),
	])
	s.post_void('/session/${s.session_id}/actions', body)!
}

// long_press_at sends a touch-and-hold at the screen coordinate for
// `duration_ms` milliseconds.
pub fn (s MobileSession) long_press_at(x int, y int, duration_ms int) ! {
	body := touch_sequence([
		act_pointer_move(x, y, 0),
		act_pointer_down(),
		act_pause(duration_ms),
		act_pointer_up(),
	])
	s.post_void('/session/${s.session_id}/actions', body)!
}

// swipe drags a finger from (from_x, from_y) to (to_x, to_y) over
// `duration_ms` milliseconds. The move is interpolated by the OS, so
// longer durations produce slower (and more reliably inertial) swipes.
pub fn (s MobileSession) swipe(from_x int, from_y int, to_x int, to_y int, duration_ms int) ! {
	body := touch_sequence([
		act_pointer_move(from_x, from_y, 0),
		act_pointer_down(),
		act_pause(50),
		act_pointer_move(to_x, to_y, duration_ms),
		act_pointer_up(),
	])
	s.post_void('/session/${s.session_id}/actions', body)!
}

// long_press auto-waits for the locator to be actionable, then issues a
// long press at its center for `duration_ms` ms (use 500–800ms for a
// typical context-menu trigger).
pub fn (l MobileLocator) long_press(duration_ms int) ! {
	el := l.wait_until_actionable()!
	rect := l.session.element_rect(el)!
	cx, cy := rect_center(rect)
	l.session.long_press_at(cx, cy, duration_ms)!
}

// swipe_up swipes upward over the element's center (content scrolls up
// into view, like a flick to scroll down a list).
pub fn (l MobileLocator) swipe_up() ! {
	el := l.wait_for()!
	rect := l.session.element_rect(el)!
	cx, cy := rect_center(rect)
	dy := int(rect.height * 0.6)
	l.session.swipe(cx, cy, cx, cy - dy, 300)!
}

// swipe_down swipes downward over the element's center.
pub fn (l MobileLocator) swipe_down() ! {
	el := l.wait_for()!
	rect := l.session.element_rect(el)!
	cx, cy := rect_center(rect)
	dy := int(rect.height * 0.6)
	l.session.swipe(cx, cy, cx, cy + dy, 300)!
}

// swipe_left swipes leftward over the element's center.
pub fn (l MobileLocator) swipe_left() ! {
	el := l.wait_for()!
	rect := l.session.element_rect(el)!
	cx, cy := rect_center(rect)
	dx := int(rect.width * 0.6)
	l.session.swipe(cx, cy, cx - dx, cy, 300)!
}

// swipe_right swipes rightward over the element's center.
pub fn (l MobileLocator) swipe_right() ! {
	el := l.wait_for()!
	rect := l.session.element_rect(el)!
	cx, cy := rect_center(rect)
	dx := int(rect.width * 0.6)
	l.session.swipe(cx, cy, cx + dx, cy, 300)!
}

// drag_to performs a drag from this element's center to the target
// element's center. Useful for reorderable lists, drag-and-drop, etc.
pub fn (l MobileLocator) drag_to(target MobileLocator) ! {
	src_el := l.wait_until_actionable()!
	tgt_el := target.wait_for()!
	src_rect := l.session.element_rect(src_el)!
	tgt_rect := target.session.element_rect(tgt_el)!
	src_cx, src_cy := rect_center(src_rect)
	tgt_cx, tgt_cy := rect_center(tgt_rect)
	l.session.swipe(src_cx, src_cy, tgt_cx, tgt_cy, 600)!
}

// scroll_into_view tells WDA to scroll the element into the visible area
// — uses WDA's `scrollToVisible` extension, which walks up the parent
// chain looking for a scroll view and scrolls it the right way. Most
// reliable way to bring a long-list row on-screen.
pub fn (l MobileLocator) scroll_into_view() ! {
	el := l.wait_for()!
	l.session.post_void('/session/${l.session.session_id}/wda/element/${el.element_id}/scrollToVisible',
		json.Any(map[string]json.Any{}))!
}

// rect_center returns the integer center coordinates of an ElementRect.
fn rect_center(r ElementRect) (int, int) {
	return int(r.x + r.width / 2), int(r.y + r.height / 2)
}

// touch_sequence wraps a list of pointer actions in the W3C
// /actions request body shape:
//
//   { "actions": [
//       { "id": "finger1", "type": "pointer",
//         "parameters": { "pointerType": "touch" },
//         "actions": [ ...steps... ] }
//   ]}
fn touch_sequence(steps []json.Any) json.Any {
	mut params := map[string]json.Any{}
	params['pointerType'] = json.Any('touch')

	mut source := map[string]json.Any{}
	source['id'] = json.Any('finger1')
	source['type'] = json.Any('pointer')
	source['parameters'] = json.Any(params)
	source['actions'] = json.Any(steps)

	mut req := map[string]json.Any{}
	req['actions'] = json.Any([json.Any(source)])
	return json.Any(req)
}

// act_pointer_move builds a `pointerMove` step. `duration_ms` is how long
// the move takes to interpolate (0 for instant; higher values for
// natural-feeling swipes).
fn act_pointer_move(x int, y int, duration_ms int) json.Any {
	mut m := map[string]json.Any{}
	m['type'] = json.Any('pointerMove')
	m['duration'] = json.Any(duration_ms)
	m['x'] = json.Any(x)
	m['y'] = json.Any(y)
	return json.Any(m)
}

// act_pointer_down builds a `pointerDown` step.
fn act_pointer_down() json.Any {
	mut m := map[string]json.Any{}
	m['type'] = json.Any('pointerDown')
	m['button'] = json.Any(0)
	return json.Any(m)
}

// act_pointer_up builds a `pointerUp` step.
fn act_pointer_up() json.Any {
	mut m := map[string]json.Any{}
	m['type'] = json.Any('pointerUp')
	m['button'] = json.Any(0)
	return json.Any(m)
}

// act_pause builds a `pause` step that holds the pointer in place for
// `duration_ms` milliseconds.
fn act_pause(duration_ms int) json.Any {
	mut m := map[string]json.Any{}
	m['type'] = json.Any('pause')
	m['duration'] = json.Any(duration_ms)
	return json.Any(m)
}

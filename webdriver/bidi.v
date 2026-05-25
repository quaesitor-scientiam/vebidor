module webdriver

import net.websocket
import sync
import time
import log
import x.json2 as json

// WebDriver-BiDi transport (Phase 3).
//
// BiDi is the W3C bidirectional protocol: JSON commands and events over a
// single WebSocket, rather than one HTTP round-trip per command. It unlocks
// capabilities WebDriver Classic cannot offer — event subscriptions, console
// streaming, network interception (Phase 4), and isolated contexts.
//
// A BiDi connection is obtained from a Classic session that was created with
// `webSocketUrl: true`; the driver returns a `webSocketUrl` that we connect to.
// Classic (HTTP) and BiDi coexist on the same session: use Classic for the
// existing command surface and BiDi for the event-driven features.

// BiDiEventHandler is invoked (on the listener thread) with an event's params.
pub type BiDiEventHandler = fn (params json.Any)

@[heap]
pub struct BiDi {
mut:
	ws            &websocket.Client = unsafe { nil }
	mu            &sync.Mutex       = unsafe { nil }
	next_id       int               = 1
	pending       map[int]chan string           // command id -> channel receiving the raw reply
	handlers      map[string][]BiDiEventHandler // spawned handlers (may call send())
	sync_handlers map[string][]BiDiEventHandler // inline handlers (must not call send())
pub:
	url string
pub mut:
	timeout_ms int = default_timeout_ms
}

// bidi_connect opens a BiDi WebSocket connection and starts its listener.
pub fn bidi_connect(ws_url string) !&BiDi {
	// Quiet the websocket library's INFO chatter; surface only real errors.
	mut quiet := &log.Log{}
	quiet.set_level(.error)
	mut ws := websocket.new_client(ws_url, logger: quiet)!
	mut b := &BiDi{
		ws:  ws
		mu:  sync.new_mutex()
		url: ws_url
	}
	ws.on_message_ref(bidi_on_message, b)
	ws.connect()!
	spawn b.listen()
	return b
}

// bidi opens a BiDi connection for this session. The session must have been
// created with `webSocketUrl: true` in its capabilities.
pub fn (wd WebDriver) bidi() !&BiDi {
	if wd.web_socket_url == '' {
		return error('this session has no BiDi socket; create it with web_socket_url: true (or LaunchOptions{ bidi: true })')
	}
	return bidi_connect(wd.web_socket_url)!
}

// listen runs the WebSocket read loop (spawned on its own thread).
fn (mut b BiDi) listen() {
	b.ws.listen() or {}
}

// close shuts down the BiDi connection.
pub fn (mut b BiDi) close() {
	b.ws.close(1000, 'closing') or {}
}

// bidi_on_message is the WebSocket message callback; it routes each frame to a
// waiting command or to event handlers.
fn bidi_on_message(mut c websocket.Client, msg &websocket.Message, v voidptr) ! {
	if msg.opcode != .text_frame {
		return
	}
	mut b := unsafe { &BiDi(v) }
	b.handle_raw(msg.payload.bytestr())
}

// handle_raw parses one incoming JSON message and dispatches it.
fn (mut b BiDi) handle_raw(raw string) {
	parsed := json.decode[json.Any](raw) or { return }
	m := parsed.as_map()

	// Events carry type=="event" and no id.
	if tv := m['type'] {
		if tv.str() == 'event' {
			method := (m['method'] or { json.Any('') }).str()
			params := m['params'] or { json.Any(map[string]json.Any{}) }
			b.mu.lock()
			sync_hs := b.sync_handlers[method].clone()
			hs := b.handlers[method].clone()
			b.mu.unlock()
			// Sync handlers run inline on the listener thread — for cheap,
			// high-frequency observers (e.g. network status) that must NOT call
			// send(). Async handlers run on their own thread so they may call
			// send() (e.g. interception continue/fulfill/abort) without
			// deadlocking the listener that delivers send()'s reply.
			for h in sync_hs {
				h(params)
			}
			for h in hs {
				spawn h(params)
			}
			return
		}
	}

	// Otherwise it's a command reply (success or error), keyed by id.
	if idv := m['id'] {
		id := idv.int()
		b.mu.lock()
		ch := b.pending[id] or {
			b.mu.unlock()
			return
		}
		b.mu.unlock()
		ch <- raw
	}
}

// send issues a BiDi command and blocks until its reply arrives or it times out.
pub fn (mut b BiDi) send(method string, params json.Any) !json.Any {
	b.mu.lock()
	id := b.next_id
	b.next_id++
	ch := chan string{cap: 1}
	b.pending[id] = ch
	b.mu.unlock()

	mut cmd := map[string]json.Any{}
	cmd['id'] = json.Any(id)
	cmd['method'] = json.Any(method)
	cmd['params'] = params
	b.ws.write_string(json.encode(cmd)) or {
		b.mu.lock()
		b.pending.delete(id)
		b.mu.unlock()
		return error('BiDi write failed for ${method}: ${err}')
	}

	mut raw := ''
	mut got := false
	tmo := time.Duration(b.timeout_ms) * time.millisecond
	select {
		r := <-ch {
			raw = r
			got = true
		}
		tmo {
			got = false
		}
	}

	b.mu.lock()
	b.pending.delete(id)
	b.mu.unlock()

	if !got {
		return error('BiDi ${method} timed out after ${b.timeout_ms}ms')
	}

	reply := json.decode[json.Any](raw) or { return error('BiDi ${method}: invalid reply: ${err}') }
	rm := reply.as_map()
	if tv := rm['type'] {
		if tv.str() == 'error' {
			code := (rm['error'] or { json.Any('') }).str()
			emsg := (rm['message'] or { json.Any('') }).str()
			return error('BiDi error for ${method} (${code}): ${emsg}')
		}
	}
	return rm['result'] or { json.Any(map[string]json.Any{}) }
}

// subscribe asks the driver to start emitting the named global events.
pub fn (mut b BiDi) subscribe(events []string) ! {
	mut arr := []json.Any{}
	for e in events {
		arr << json.Any(e)
	}
	mut p := map[string]json.Any{}
	p['events'] = json.Any(arr)
	b.send('session.subscribe', json.Any(p))!
}

// unsubscribe stops the named global events.
pub fn (mut b BiDi) unsubscribe(events []string) ! {
	mut arr := []json.Any{}
	for e in events {
		arr << json.Any(e)
	}
	mut p := map[string]json.Any{}
	p['events'] = json.Any(arr)
	b.send('session.unsubscribe', json.Any(p))!
}

// on registers a handler for a BiDi event method (e.g. 'log.entryAdded').
// Call subscribe([...]) to make the driver actually emit the event.
pub fn (mut b BiDi) on(event string, handler BiDiEventHandler) {
	b.mu.lock()
	b.handlers[event] << handler
	b.mu.unlock()
}

// on_sync registers a handler that runs INLINE on the listener thread (no
// per-event thread spawn). Use it for cheap, high-frequency observation such as
// network status tracking. The handler MUST NOT call send()/route/fulfill (it
// would deadlock the listener that delivers the reply) and must return quickly.
// For handlers that issue BiDi commands, use on() instead.
pub fn (mut b BiDi) on_sync(event string, handler BiDiEventHandler) {
	b.mu.lock()
	b.sync_handlers[event] << handler
	b.mu.unlock()
}

// wait_for_event subscribes to an event and blocks until the next one arrives
// (or the timeout elapses), returning its params. Note: the temporary handler
// stays registered after returning.
pub fn (mut b BiDi) wait_for_event(event string, timeout_ms int) !json.Any {
	ch := chan json.Any{cap: 1}
	b.on_sync(event, fn [ch] (params json.Any) {
		select {
			ch <- params {}
			else {}
		}
	})
	b.subscribe([event])!

	mut out := json.Any('')
	mut got := false
	tmo := time.Duration(timeout_ms) * time.millisecond
	select {
		v := <-ch {
			out = v
			got = true
		}
		tmo {}
	}
	if !got {
		return error('wait_for_event ${event} timed out after ${timeout_ms}ms')
	}
	return out
}

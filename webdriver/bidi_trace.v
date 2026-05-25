module webdriver

import os
import sync
import time
import x.json2 as json

// Lightweight tracing: records console, network, and (optionally) other BiDi
// events with timestamps and writes them to a JSON file. This is the V analogue
// of Playwright tracing — a chronological activity log you can inspect after a
// run — without the full binary trace-viewer format.

// TraceEvent is one recorded entry.
pub struct TraceEvent {
pub:
	t      i64    // unix milliseconds
	kind   string // 'console' | 'request' | 'response'
	detail string
}

@[heap]
pub struct Tracer {
mut:
	bidi   &BiDi       = unsafe { nil }
	mu     &sync.Mutex = unsafe { nil }
	events []TraceEvent
	active bool
}

// new_tracer creates a tracer bound to this BiDi connection.
pub fn (mut b BiDi) new_tracer() &Tracer {
	return &Tracer{
		bidi: &b
		mu:   sync.new_mutex()
	}
}

// start subscribes to console + network events and begins recording.
pub fn (mut t Tracer) start() ! {
	t.active = true
	tptr := voidptr(&t)
	mut b := t.bidi

	b.on_sync('log.entryAdded', fn [tptr] (params json.Any) {
		mut tr := unsafe { &Tracer(tptr) }
		m := params.as_map()
		level := (m['level'] or { json.Any('') }).str()
		text := (m['text'] or { json.Any('') }).str()
		tr.record('console', '${level}: ${text}')
	})
	b.on_sync('network.beforeRequestSent', fn [tptr] (params json.Any) {
		mut tr := unsafe { &Tracer(tptr) }
		rq := (params.as_map()['request'] or { json.Any(map[string]json.Any{}) }).as_map()
		method := (rq['method'] or { json.Any('') }).str()
		url := (rq['url'] or { json.Any('') }).str()
		tr.record('request', '${method} ${url}')
	})
	b.on_sync('network.responseCompleted', fn [tptr] (params json.Any) {
		mut tr := unsafe { &Tracer(tptr) }
		rp := (params.as_map()['response'] or { json.Any(map[string]json.Any{}) }).as_map()
		status := (rp['status'] or { json.Any(0) }).int()
		url := (rp['url'] or { json.Any('') }).str()
		tr.record('response', '${status} ${url}')
	})

	b.subscribe(['log.entryAdded', 'network.beforeRequestSent', 'network.responseCompleted'])!
}

// stop halts recording (handlers remain registered but become no-ops).
pub fn (mut t Tracer) stop() {
	t.active = false
}

// record appends an event if tracing is active (called from handler threads).
fn (mut t Tracer) record(kind string, detail string) {
	if !t.active {
		return
	}
	t.mu.lock()
	t.events << TraceEvent{
		t:      time.now().unix_milli()
		kind:   kind
		detail: detail
	}
	t.mu.unlock()
}

// count returns how many events have been recorded so far.
pub fn (mut t Tracer) count() int {
	t.mu.lock()
	n := t.events.len
	t.mu.unlock()
	return n
}

// events returns a snapshot copy of the recorded events.
pub fn (mut t Tracer) events() []TraceEvent {
	t.mu.lock()
	evs := t.events.clone()
	t.mu.unlock()
	return evs
}

// save writes the recorded events to `path` as a JSON array.
pub fn (mut t Tracer) save(path string) ! {
	evs := t.events()
	mut arr := []json.Any{}
	for e in evs {
		mut m := map[string]json.Any{}
		m['t'] = json.Any(e.t)
		m['kind'] = json.Any(e.kind)
		m['detail'] = json.Any(e.detail)
		arr << json.Any(m)
	}
	os.write_file(path, json.encode(json.Any(arr)))!
}

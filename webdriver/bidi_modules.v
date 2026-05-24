module webdriver

import x.json2 as json

// Convenience wrappers over the core BiDi modules. These are thin typed helpers
// on top of BiDi.send / BiDi.subscribe; raw access is always available via send.

// LogEntry is a console/JavaScript log entry delivered by `log.entryAdded`.
pub struct LogEntry {
pub:
	level  string // 'debug' | 'info' | 'warn' | 'error'
	source string // log type, e.g. 'console' or 'javascript'
	text   string // the (already-stringified) message text
}

// --- browsingContext module ---

// browsing_contexts returns the IDs of the top-level browsing contexts (tabs).
pub fn (mut b BiDi) browsing_contexts() ![]string {
	res := b.send('browsingContext.getTree', json.Any(map[string]json.Any{}))!
	mut ids := []string{}
	if contexts := res.as_map()['contexts'] {
		for c in contexts.as_array() {
			if id := c.as_map()['context'] {
				ids << id.str()
			}
		}
	}
	return ids
}

// first_context returns the first top-level browsing context ID (most scripts
// only have one tab).
pub fn (mut b BiDi) first_context() !string {
	ctxs := b.browsing_contexts()!
	if ctxs.len == 0 {
		return error('no browsing contexts available')
	}
	return ctxs[0]
}

// navigate drives a context to a URL and waits for the load to complete.
pub fn (mut b BiDi) navigate(context string, url string) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['url'] = json.Any(url)
	p['wait'] = json.Any('complete')
	b.send('browsingContext.navigate', json.Any(p))!
}

// reload reloads a context.
pub fn (mut b BiDi) reload(context string) ! {
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['wait'] = json.Any('complete')
	b.send('browsingContext.reload', json.Any(p))!
}

// --- script module ---

// evaluate runs a JavaScript expression in a context and returns the raw BiDi
// result object (which contains `type` and `value`/`result`).
pub fn (mut b BiDi) evaluate(context string, expression string) !json.Any {
	mut target := map[string]json.Any{}
	target['context'] = json.Any(context)
	mut p := map[string]json.Any{}
	p['expression'] = json.Any(expression)
	p['target'] = json.Any(target)
	p['awaitPromise'] = json.Any(true)
	return b.send('script.evaluate', json.Any(p))!
}

// evaluate_string runs an expression and returns its primitive value as a
// string (suitable for expressions that yield a string/number/boolean).
pub fn (mut b BiDi) evaluate_string(context string, expression string) !string {
	res := b.evaluate(context, expression)!
	rm := res.as_map()
	if rt := rm['type'] {
		if rt.str() == 'exception' {
			return error('script exception: ${res}')
		}
	}
	if rv := rm['result'] {
		if val := rv.as_map()['value'] {
			return val.str()
		}
	}
	return ''
}

// --- log module ---

// on_log subscribes to `log.entryAdded` and invokes `handler` for each entry.
pub fn (mut b BiDi) on_log(handler fn (entry LogEntry)) ! {
	b.on('log.entryAdded', fn [handler] (params json.Any) {
		m := params.as_map()
		entry := LogEntry{
			level:  (m['level'] or { json.Any('') }).str()
			source: (m['type'] or { json.Any('') }).str()
			text:   (m['text'] or { json.Any('') }).str()
		}
		handler(entry)
	})
	b.subscribe(['log.entryAdded'])!
}

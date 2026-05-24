module webdriver

import x.json2 as json

// BiDi `script` module extras beyond evaluate: preload scripts (run before any
// page script — Playwright's addInitScript / Selenium's "pin script") and
// callFunction with serialized arguments.

// local_string builds a BiDi LocalValue for a string argument.
pub fn local_string(s string) json.Any {
	return json.Any({
		'type':  json.Any('string')
		'value': json.Any(s)
	})
}

// local_number builds a BiDi LocalValue for a numeric argument.
pub fn local_number(n f64) json.Any {
	return json.Any({
		'type':  json.Any('number')
		'value': json.Any(n)
	})
}

// local_bool builds a BiDi LocalValue for a boolean argument.
pub fn local_bool(v bool) json.Any {
	return json.Any({
		'type':  json.Any('boolean')
		'value': json.Any(v)
	})
}

// add_preload_script registers a function to run before any other script on
// every new document in the session, returning its id. The declaration must be
// a function, e.g. '() => { window.__patched = true }'.
pub fn (mut b BiDi) add_preload_script(function_declaration string) !string {
	mut p := map[string]json.Any{}
	p['functionDeclaration'] = json.Any(function_declaration)
	res := b.send('script.addPreloadScript', json.Any(p))!
	return (res.as_map()['script'] or { json.Any('') }).str()
}

// remove_preload_script removes a previously added preload script.
pub fn (mut b BiDi) remove_preload_script(script_id string) ! {
	mut p := map[string]json.Any{}
	p['script'] = json.Any(script_id)
	b.send('script.removePreloadScript', json.Any(p))!
}

// call_function calls a JS function in a context with serialized arguments
// (build them with local_string/local_number/local_bool) and returns the raw
// BiDi result object.
pub fn (mut b BiDi) call_function(context string, function_declaration string, args []json.Any) !json.Any {
	mut target := map[string]json.Any{}
	target['context'] = json.Any(context)
	mut p := map[string]json.Any{}
	p['functionDeclaration'] = json.Any(function_declaration)
	p['target'] = json.Any(target)
	p['awaitPromise'] = json.Any(true)
	p['arguments'] = json.Any(args)
	return b.send('script.callFunction', json.Any(p))!
}

// call_function_string calls a function and returns its primitive result as a
// string.
pub fn (mut b BiDi) call_function_string(context string, function_declaration string, args []json.Any) !string {
	res := b.call_function(context, function_declaration, args)!
	rm := res.as_map()
	if rt := rm['type'] {
		if rt.str() == 'exception' {
			return error('callFunction exception: ${res}')
		}
	}
	if rv := rm['result'] {
		if val := rv.as_map()['value'] {
			return val.str()
		}
	}
	return ''
}

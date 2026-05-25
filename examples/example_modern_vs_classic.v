module main

import vebidor.webdriver

// This example performs the SAME task two ways — the raw W3C "classic" API and
// the Playwright-style "modern" API — and then demonstrates a BiDi-only
// capability (network mocking) that the classic API fundamentally cannot do.
//
// Run it with no manual driver setup: launch() finds the driver + browser,
// starts it on a free port, and tears everything down on close().

fn main() {
	println('========================================')
	println('Classic vs Modern vs BiDi')
	println('========================================')

	mut b := webdriver.launch_edge(webdriver.LaunchOptions{ headless: true, bidi: true }) or {
		eprintln('launch failed: ${err}')
		exit(1)
	}
	defer {
		b.close()
	}

	classic_approach(b.wd) or { eprintln('classic failed: ${err}') }
	modern_approach(b.wd) or { eprintln('modern failed: ${err}') }
	bidi_approach(mut b) or { eprintln('bidi failed: ${err}') }

	println('\n✅ Done')
}

// classic_approach — raw W3C WebDriver: explicit find_element calls and manual
// state checks. You manage waiting and element references yourself.
fn classic_approach(wd webdriver.WebDriver) ! {
	println('\n--- Classic (raw W3C WebDriver) ---')
	wd.get('https://example.com')!

	heading := wd.find_element('css selector', 'h1')!
	if !wd.is_displayed(heading)! {
		return error('heading not visible')
	}
	println('heading: "${wd.get_text(heading)!}"')

	link := wd.find_element('css selector', 'a')!
	wd.click(link)!
	println('clicked link -> ${wd.get_current_url()!}')
}

// modern_approach — Playwright-style: lazy auto-waiting Locators, semantic
// selectors, and retrying assertions. No explicit find or visibility polling.
fn modern_approach(wd webdriver.WebDriver) ! {
	println('\n--- Modern (Playwright-style) ---')
	wd.get('https://example.com')!

	heading := wd.get_by_role('heading', '')
	webdriver.expect(heading).to_be_visible()! // auto-waits, no manual check
	println('heading: "${heading.text()!}"')

	// Semantic selector + auto-waiting click. get_by_role('link', '') targets the
	// first link by ARIA role — the modern parallel to classic's css 'a'.
	wd.get_by_role('link', '').click()!
	println('clicked link -> ${wd.get_current_url()!}')
}

// bidi_approach — a BiDi-only capability: intercept and mock a response. There
// is no classic-WebDriver equivalent for this.
fn bidi_approach(mut b webdriver.Browser) ! {
	println('\n--- BiDi (network mocking — impossible in classic) ---')
	mut bidi := b.bidi()!
	defer {
		bidi.close()
	}
	ctx := bidi.first_context()!

	bidi.route(fn (req webdriver.InterceptedRequest) {
		if req.url.contains('example.com') {
			req.fulfill(200, 'text/html', '<h1 id="x">MOCKED BY BIDI</h1>') or {}
		} else {
			req.continue_request() or {}
		}
	})!

	bidi.navigate(ctx, 'https://example.com/')!
	h1 := bidi.evaluate_string(ctx, 'document.getElementById("x").textContent')!
	println('document h1: "${h1}"')
}

// Dummy test function (matches the other examples in this directory).
fn test_dummy() {}

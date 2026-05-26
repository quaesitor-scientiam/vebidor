module webdriver

// Mobile (and general) device emulation, mirroring Playwright's device
// descriptors. This is browser emulation over BiDi — not real-device/Appium
// automation. Emulation fidelity is best on Chromium-based drivers (Edge/Chrome).
//
// Phase M1 (this file): the Device descriptor + emulate(), which applies the
// viewport size and device pixel ratio. User-agent override, isMobile/hasTouch
// JS flags, and touch input are added by later phases (see the mobile-emulation
// roadmap in COMPARISON_WITH_PLAYWRIGHT.md).

// Device is a device profile for emulation. Equivalent to a Playwright device
// descriptor (e.g. devices['iPhone 14']).
pub struct Device {
pub:
	name                string
	width               int
	height              int
	device_scale_factor f64 = 1.0
	user_agent          string // applied in a later phase (UA override)
	is_mobile           bool   // applied in a later phase (JS flags)
	has_touch           bool   // applied in a later phase (touch input)
}

// emulate applies a device profile to a browsing context:
//   - viewport size + device pixel ratio (immediate), and
//   - a preload script overriding JS-visible signals: navigator.userAgent and
//     touch capability (navigator.maxTouchPoints + ontouchstart).
//
// The preload script applies to documents loaded AFTER this call, so call
// emulate() *before* navigating. Limits: the preload changes JS-visible UA only
// — the HTTP User-Agent *request header* (server-side detection) needs network
// interception, and real touch-event dispatch needs driver-level touch
// emulation; here `has_touch` makes touch *detection* true so sites enable their
// touch UI.
pub fn (mut b BiDi) emulate(context string, device Device) ! {
	b.set_viewport(context, device.width, device.height)!
	if device.device_scale_factor > 0 {
		b.set_device_pixel_ratio(context, device.device_scale_factor)!
	}
	js := device_preload_js(device)
	if js != '' {
		b.add_preload_script(js)!
	}
}

// set_user_agent overrides the JS-visible navigator.userAgent for documents
// loaded after this call (via a preload script). Call before navigating.
pub fn (mut b BiDi) set_user_agent(user_agent string) ! {
	ua := js_escape(user_agent)
	b.add_preload_script("() => { Object.defineProperty(navigator, 'userAgent', { get: () => '${ua}', configurable: true }); }")!
}

// device_preload_js builds the preload script overriding navigator.userAgent and
// touch signals for a Device. Returns '' when the device sets neither.
fn device_preload_js(device Device) string {
	mut parts := []string{}
	if device.user_agent != '' {
		ua := js_escape(device.user_agent)
		parts << "Object.defineProperty(navigator, 'userAgent', { get: () => '${ua}', configurable: true });"
	}
	if device.has_touch {
		parts << 'Object.defineProperty(navigator, "maxTouchPoints", { get: () => 5, configurable: true });'
		parts << 'if (!("ontouchstart" in window)) { window.ontouchstart = null; }'
	}
	if parts.len == 0 {
		return ''
	}
	return '() => {' + parts.join(' ') + '}'
}

// js_escape escapes a value for embedding inside a single-quoted JS string.
fn js_escape(s string) string {
	return s.replace('\\', '\\\\').replace("'", "\\'")
}

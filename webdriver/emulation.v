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

// emulate applies a device profile to a browsing context. Phase M1 sets the
// viewport dimensions and device pixel ratio so the page renders at the
// device's size; later phases extend this to UA and touch.
pub fn (mut b BiDi) emulate(context string, device Device) ! {
	b.set_viewport(context, device.width, device.height)!
	if device.device_scale_factor > 0 {
		b.set_device_pixel_ratio(context, device.device_scale_factor)!
	}
}

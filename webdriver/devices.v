module webdriver

// Curated device presets for mobile emulation (Playwright `devices[...]`
// equivalent). Each preset bundles viewport, device-scale-factor, a realistic
// user agent, and the mobile/touch flags, ready to pass to emulate().

const ua_iphone = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
const ua_ipad = 'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
const ua_pixel = 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36'
const ua_galaxy = 'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36'

// device looks up a preset by name (e.g. 'iPhone 14', 'Pixel 7'); none if unknown.
pub fn device(name string) ?Device {
	d := match name {
		'iPhone SE' {
			Device{'iPhone SE', 375, 667, 2.0, ua_iphone, true, true}
		}
		'iPhone 12' {
			Device{'iPhone 12', 390, 844, 3.0, ua_iphone, true, true}
		}
		'iPhone 14' {
			Device{'iPhone 14', 390, 844, 3.0, ua_iphone, true, true}
		}
		'iPhone 14 Pro Max' {
			Device{'iPhone 14 Pro Max', 430, 932, 3.0, ua_iphone, true, true}
		}
		'Pixel 5' {
			Device{'Pixel 5', 393, 851, 3.0, ua_pixel, true, true}
		}
		'Pixel 7' {
			Device{'Pixel 7', 412, 915, 2.625, ua_pixel, true, true}
		}
		'Galaxy S21' {
			Device{'Galaxy S21', 360, 800, 3.0, ua_galaxy, true, true}
		}
		'iPad' {
			Device{'iPad', 810, 1080, 2.0, ua_ipad, true, true}
		}
		'iPad Mini' {
			Device{'iPad Mini', 768, 1024, 2.0, ua_ipad, true, true}
		}
		else {
			return none
		}
	}

	return d
}

// device_names returns the available preset names.
pub fn device_names() []string {
	return ['iPhone SE', 'iPhone 12', 'iPhone 14', 'iPhone 14 Pro Max', 'Pixel 5', 'Pixel 7',
		'Galaxy S21', 'iPad', 'iPad Mini']
}

// emulate_device emulates a named preset on a browsing context (lookup +
// emulate). Call before navigating. Errors if the name is unknown.
pub fn (mut b BiDi) emulate_device(context string, name string) ! {
	d := device(name) or { return error('unknown device "${name}" (see device_names())') }
	b.emulate(context, d)!
}

module webdriver

import x.json2 as json

// Helper function to set up a test driver with test HTML
fn setup_test_driver_with_html() !WebDriver {
	caps := Capabilities{
		browser_name: 'msedge'
		edge_options: EdgeOptions{
			args:   ['--headless=new', '--disable-gpu']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	mut wd := new_edge_driver('http://127.0.0.1:9515', caps)!

	// Navigate to a data URL with test HTML
	test_html := '<!DOCTYPE html>
<html>
<head>
<style>
	#red-box {
		color: rgb(255, 0, 0);
		background-color: rgb(0, 0, 255);
		font-size: 16px;
		display: block;
		width: 200px;
		height: 100px;
		margin: 10px;
		padding: 5px;
		border: 2px solid black;
		font-weight: bold;
		text-align: center;
	}
	#green-text {
		color: rgb(0, 255, 0);
		font-family: Arial, sans-serif;
		font-style: italic;
	}
	.hidden-element {
		display: none;
		visibility: hidden;
	}
</style>
</head>
<body>
	<div id="red-box">Red Text Box</div>
	<p id="green-text">Green Text</p>
	<span class="hidden-element">Hidden</span>
</body>
</html>'

	wd.get('data:text/html;charset=utf-8,${test_html}')!
	return wd
}

fn test_get_css_color() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	color := wd.get_css_value(element, 'color') or {
		eprintln('Failed to get color: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_color: ${color}')
	// Color should be 'rgb(255, 0, 0)' or 'rgba(255, 0, 0, 1)'
	assert color.contains('255') && color.contains('0')
}

fn test_get_css_background_color() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	bg_color := wd.get_css_value(element, 'background-color') or {
		eprintln('Failed to get background-color: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_background_color: ${bg_color}')
	// Background should be 'rgb(0, 0, 255)' or 'rgba(0, 0, 255, 1)'
	assert bg_color.contains('0') && bg_color.contains('255')
}

fn test_get_css_font_size() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	font_size := wd.get_css_value(element, 'font-size') or {
		eprintln('Failed to get font-size: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_font_size: ${font_size}')
	// Should be '16px' or computed value
	assert font_size.contains('px')
}

fn test_get_css_display() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	display := wd.get_css_value(element, 'display') or {
		eprintln('Failed to get display: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_display: ${display}')
	assert display == 'block'
}

fn test_get_css_width_height() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	width := wd.get_css_value(element, 'width') or {
		eprintln('Failed to get width: ${err}')
		assert false
		return
	}

	height := wd.get_css_value(element, 'height') or {
		eprintln('Failed to get height: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_width_height: width=${width}, height=${height}')
	assert width.contains('px')
	assert height.contains('px')
}

fn test_get_css_margin_padding() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	margin := wd.get_css_value(element, 'margin-top') or {
		eprintln('Failed to get margin: ${err}')
		assert false
		return
	}

	padding := wd.get_css_value(element, 'padding-top') or {
		eprintln('Failed to get padding: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_margin_padding: margin=${margin}, padding=${padding}')
	assert margin.contains('px')
	assert padding.contains('px')
}

fn test_get_css_border() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	border_width := wd.get_css_value(element, 'border-top-width') or {
		eprintln('Failed to get border-width: ${err}')
		assert false
		return
	}

	border_style := wd.get_css_value(element, 'border-top-style') or {
		eprintln('Failed to get border-style: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_border: width=${border_width}, style=${border_style}')
	assert border_width.contains('px')
	assert border_style == 'solid'
}

fn test_get_css_font_properties() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#red-box') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	font_weight := wd.get_css_value(element, 'font-weight') or {
		eprintln('Failed to get font-weight: ${err}')
		assert false
		return
	}

	text_align := wd.get_css_value(element, 'text-align') or {
		eprintln('Failed to get text-align: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_font_properties: weight=${font_weight}, align=${text_align}')
	// font-weight might be 'bold' or '700'
	assert font_weight == 'bold' || font_weight == '700'
	assert text_align == 'center'
}

fn test_get_css_visibility_hidden() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '.hidden-element') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	display := wd.get_css_value(element, 'display') or {
		eprintln('Failed to get display: ${err}')
		assert false
		return
	}

	visibility := wd.get_css_value(element, 'visibility') or {
		eprintln('Failed to get visibility: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_visibility_hidden: display=${display}, visibility=${visibility}')
	assert display == 'none'
	assert visibility == 'hidden'
}

fn test_get_css_font_family() {
	wd := setup_test_driver_with_html() or {
		eprintln('Failed to setup driver: ${err}')
		assert false
		return
	}
	defer {
		wd.quit() or {}
	}

	element := wd.find_element('css selector', '#green-text') or {
		eprintln('Failed to find element: ${err}')
		assert false
		return
	}

	font_family := wd.get_css_value(element, 'font-family') or {
		eprintln('Failed to get font-family: ${err}')
		assert false
		return
	}

	font_style := wd.get_css_value(element, 'font-style') or {
		eprintln('Failed to get font-style: ${err}')
		assert false
		return
	}

	println('✓ test_get_css_font_family: family=${font_family}, style=${font_style}')
	assert font_family.contains('Arial') || font_family.contains('arial')
	assert font_style == 'italic'
}

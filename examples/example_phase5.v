module main

import webdriver
import time

fn main() {
	println('========================================')
	println('Phase 5 Features Demo: CSS Properties')
	println('========================================\n')

	run_demo() or {
		eprintln('Demo failed: ${err}')
		exit(1)
	}

	println('\n✓ All Phase 5 demonstrations completed successfully!')
}

fn run_demo() ! {
	// Setup driver
	println('[1/7] Setting up WebDriver...')
	caps := webdriver.Capabilities{
		browser_name: 'msedge'
		edge_options: webdriver.EdgeOptions{
			args:   ['--headless=new', '--disable-gpu']
			binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
		}
	}

	mut wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
	defer {
		wd.quit() or {}
	}

	// Create a test page with styled elements
	test_html := '<!DOCTYPE html>
<html>
<head>
<style>
	body {
		font-family: Arial, sans-serif;
		margin: 20px;
		background-color: #f0f0f0;
	}

	#header {
		color: rgb(0, 0, 128);
		background-color: rgb(255, 255, 0);
		font-size: 24px;
		font-weight: bold;
		padding: 10px;
		margin-bottom: 20px;
		border: 3px solid rgb(255, 0, 0);
		text-align: center;
		width: 500px;
	}

	#content-box {
		background-color: rgb(144, 238, 144);
		color: rgb(0, 0, 0);
		padding: 15px;
		margin: 10px 0;
		border-radius: 5px;
		font-size: 14px;
		line-height: 1.5;
		width: 400px;
		height: 100px;
	}

	.styled-button {
		background-color: rgb(30, 144, 255);
		color: rgb(255, 255, 255);
		border: 2px solid rgb(0, 0, 139);
		padding: 10px 20px;
		font-size: 16px;
		font-weight: 600;
		cursor: pointer;
		border-radius: 4px;
	}

	.hidden-element {
		display: none;
		visibility: hidden;
	}

	.italic-text {
		font-style: italic;
		color: rgb(128, 0, 128);
	}
</style>
</head>
<body>
	<div id="header">Styled Header</div>
	<div id="content-box">This is a styled content box with specific dimensions and colors.</div>
	<button class="styled-button">Styled Button</button>
	<p class="italic-text">Italic purple text</p>
	<span class="hidden-element">Hidden element</span>
</body>
</html>'

	println('[2/7] Loading test page with styled elements...')
	wd.get('data:text/html;charset=utf-8,${test_html}')!
	time.sleep(500 * time.millisecond)

	// Demo 1: Get text color
	println('\n[3/7] Demo 1: Getting text colors')
	println('────────────────────────────────')
	header := wd.find_element('css selector', '#header')!
	header_color := wd.get_css_value(header, 'color')!
	println('  Header text color: ${header_color}')

	italic_text := wd.find_element('css selector', '.italic-text')!
	italic_color := wd.get_css_value(italic_text, 'color')!
	println('  Italic text color: ${italic_color}')

	// Demo 2: Get background colors
	println('\n[4/7] Demo 2: Getting background colors')
	println('────────────────────────────────────────')
	header_bg := wd.get_css_value(header, 'background-color')!
	println('  Header background: ${header_bg}')

	content_box := wd.find_element('css selector', '#content-box')!
	content_bg := wd.get_css_value(content_box, 'background-color')!
	println('  Content box background: ${content_bg}')

	// Demo 3: Get font properties
	println('\n[5/7] Demo 3: Getting font properties')
	println('──────────────────────────────────────')
	header_font_size := wd.get_css_value(header, 'font-size')!
	header_font_weight := wd.get_css_value(header, 'font-weight')!
	header_text_align := wd.get_css_value(header, 'text-align')!
	println('  Header font-size: ${header_font_size}')
	println('  Header font-weight: ${header_font_weight}')
	println('  Header text-align: ${header_text_align}')

	italic_font_style := wd.get_css_value(italic_text, 'font-style')!
	println('  Italic font-style: ${italic_font_style}')

	// Demo 4: Get dimensions (width, height)
	println('\n[6/7] Demo 4: Getting element dimensions')
	println('─────────────────────────────────────────')
	header_width := wd.get_css_value(header, 'width')!
	content_width := wd.get_css_value(content_box, 'width')!
	content_height := wd.get_css_value(content_box, 'height')!
	println('  Header width: ${header_width}')
	println('  Content box width: ${content_width}')
	println('  Content box height: ${content_height}')

	// Demo 5: Get spacing properties (margin, padding)
	println('\n[7/7] Demo 5: Getting spacing properties')
	println('─────────────────────────────────────────')
	header_padding := wd.get_css_value(header, 'padding-top')!
	content_padding := wd.get_css_value(content_box, 'padding-left')!
	content_margin := wd.get_css_value(content_box, 'margin-top')!
	println('  Header padding: ${header_padding}')
	println('  Content box padding: ${content_padding}')
	println('  Content box margin: ${content_margin}')

	// Demo 6: Get border properties
	println('\n[Bonus] Getting border properties')
	println('──────────────────────────────────')
	header_border_width := wd.get_css_value(header, 'border-top-width')!
	header_border_color := wd.get_css_value(header, 'border-top-color')!
	header_border_style := wd.get_css_value(header, 'border-top-style')!
	println('  Header border-width: ${header_border_width}')
	println('  Header border-color: ${header_border_color}')
	println('  Header border-style: ${header_border_style}')

	// Demo 7: Get display and visibility
	println('\n[Bonus] Getting display and visibility')
	println('───────────────────────────────────────')
	content_display := wd.get_css_value(content_box, 'display')!
	println('  Content box display: ${content_display}')

	hidden := wd.find_element('css selector', '.hidden-element')!
	hidden_display := wd.get_css_value(hidden, 'display')!
	hidden_visibility := wd.get_css_value(hidden, 'visibility')!
	println('  Hidden element display: ${hidden_display}')
	println('  Hidden element visibility: ${hidden_visibility}')

	// Demo 8: Get button styling
	println('\n[Bonus] Getting button styles')
	println('──────────────────────────────')
	button := wd.find_element('css selector', '.styled-button')!
	button_bg := wd.get_css_value(button, 'background-color')!
	button_color := wd.get_css_value(button, 'color')!
	button_border := wd.get_css_value(button, 'border-radius')!
	button_cursor := wd.get_css_value(button, 'cursor')!
	println('  Button background: ${button_bg}')
	println('  Button text color: ${button_color}')
	println('  Button border-radius: ${button_border}')
	println('  Button cursor: ${button_cursor}')

	println('\n✓ Phase 5 CSS property retrieval demonstration complete!')
}

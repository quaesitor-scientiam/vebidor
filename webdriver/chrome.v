module webdriver

pub struct ChromeOptions {
	pub mut:
		args        ?[]string
		extensions  ?[]string
		binary      ?string
}

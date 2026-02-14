module webdriver

import time

pub fn (wd WebDriver) wait_for(condition fn (WebDriver) !bool, timeout_ms int, interval_ms int) ! {
	start := time.now()
	for {
		ok := condition(wd) or { false }
		if ok {
			return
		}
		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('wait_for: timeout after ${timeout_ms}ms')
		}
		time.sleep(interval_ms * time.millisecond)
	}
}

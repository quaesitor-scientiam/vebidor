module webdriver

import time

// WaitOptions parameterises the polling helpers. `describe` is used verbatim
// in the timeout error message so callers can produce a useful "what was I
// waiting for?" string.
pub struct WaitOptions {
pub:
	timeout_ms  int = default_timeout_ms
	interval_ms int = default_poll_ms
	describe    string
}

// poll_until_true repeats `predicate` until it returns true or `timeout_ms`
// elapses. Both `false` returns and errors are treated as "not yet" — the
// predicate keeps being polled. On timeout, returns an error formatted with
// `opts.describe`.
//
// Shared by `LocatorAssertions.poll` today and (forthcoming) the mobile
// module's equivalent assertions. Locator's element-returning waits
// (`wait_for`, `wait_until_actionable`) stay inlined for now — extracting a
// generic `poll_until_ok[T]` lands in Mob-2 when MobileLocator actually
// needs it.
pub fn poll_until_true(opts WaitOptions, predicate fn () !bool) ! {
	start := time.now()
	for {
		if ok := predicate() {
			if ok {
				return
			}
		}
		if time.now().unix_milli() - start.unix_milli() > i64(opts.timeout_ms) {
			return error('${opts.describe}: condition not met after ${opts.timeout_ms}ms')
		}
		time.sleep(opts.interval_ms * time.millisecond)
	}
}

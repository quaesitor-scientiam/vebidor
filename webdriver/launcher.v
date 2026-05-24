module webdriver

import os
import net
import time

// Browser/driver lifecycle management (Playwright `browserType.launch()` style).
//
// launch() locates the matching driver executable and browser binary, starts
// the driver on a free port, waits for it to become ready, opens a session, and
// returns a Browser that owns the driver process and tears it down on close().
//
// Scope note: this auto-DETECTS already-installed drivers/browsers (PATH, env
// vars, common install locations). Auto-DOWNLOADING version-matched binaries is
// a planned follow-up; find_driver/find_browser_binary are the extension points.

pub enum BrowserKind {
	edge
	chrome
	firefox
	safari
}

// LaunchOptions configures a launch. All fields are optional; sensible defaults
// (headless, auto-detected binaries, ephemeral free port) apply when unset.
pub struct LaunchOptions {
pub:
	headless         bool = true
	binary           string   // browser executable; auto-detected if empty
	driver_path      string   // driver executable; auto-detected if empty
	port             int      // driver port; an ephemeral free port if 0
	args             []string // extra browser args
	driver_url       string   // connect to an already-running driver; skips spawning
	start_timeout_ms int = 10000 // how long to wait for the driver to become ready
	bidi             bool // request a WebDriver-BiDi socket (webSocketUrl:true)
}

// Browser bundles a WebDriver session with the driver process that backs it,
// so a single close() tears everything down.
@[heap]
pub struct Browser {
pub:
	wd   WebDriver
	kind BrowserKind
	port int
pub mut:
	proc         &os.Process = unsafe { nil }
	owns_process bool
}

// launch starts (or connects to) a driver and opens a session for `kind`.
pub fn launch(kind BrowserKind, opts LaunchOptions) !Browser {
	mut owns := false
	mut proc := &os.Process(unsafe { nil })
	mut port := opts.port

	base_url := if opts.driver_url != '' {
		opts.driver_url
	} else {
		if port == 0 {
			port = free_port()!
		}
		driver := if opts.driver_path != '' { opts.driver_path } else { find_driver(kind)! }
		mut p := os.new_process(driver)
		p.set_args(['--port=${port}'])
		p.set_redirect_stdio()
		p.run()
		proc = p
		owns = true
		url := 'http://127.0.0.1:${port}'
		wait_for_driver(url, opts.start_timeout_ms) or {
			p.signal_kill()
			p.close()
			return error('${kind} driver did not become ready on port ${port}: ${err}')
		}
		url
	}

	mut caps := build_launch_caps(kind, opts) or {
		if owns {
			proc.signal_kill()
			proc.close()
		}
		return err
	}
	if opts.bidi {
		caps.web_socket_url = true
	}

	wd := new_session(base_url, caps) or {
		if owns {
			proc.signal_kill()
			proc.close()
		}
		return error('failed to create ${kind} session: ${err}')
	}

	return Browser{
		wd:           wd
		kind:         kind
		port:         port
		proc:         proc
		owns_process: owns
	}
}

// launch_edge launches Microsoft Edge.
pub fn launch_edge(opts LaunchOptions) !Browser {
	return launch(.edge, opts)
}

// launch_chrome launches Google Chrome.
pub fn launch_chrome(opts LaunchOptions) !Browser {
	return launch(.chrome, opts)
}

// launch_firefox launches Mozilla Firefox.
pub fn launch_firefox(opts LaunchOptions) !Browser {
	return launch(.firefox, opts)
}

// launch_safari launches Safari (macOS).
pub fn launch_safari(opts LaunchOptions) !Browser {
	return launch(.safari, opts)
}

// goto navigates the browser's session to a URL (convenience pass-through).
pub fn (b Browser) goto(url string) ! {
	b.wd.get(url)!
}

// bidi opens a WebDriver-BiDi connection for this browser. Requires launching
// with LaunchOptions{ bidi: true }.
pub fn (b Browser) bidi() !&BiDi {
	return b.wd.bidi()
}

// close quits the session and, if launch() spawned the driver, kills it.
pub fn (mut b Browser) close() {
	b.wd.quit() or {}
	if b.owns_process && !isnil(b.proc) {
		b.proc.signal_kill()
		b.proc.wait()
		b.proc.close()
	}
}

// --- internals ---

// free_port asks the OS for an unused TCP port by binding to port 0.
fn free_port() !int {
	mut l := net.listen_tcp(.ip, '127.0.0.1:0')!
	addr := l.addr()!
	p := addr.port()!
	l.close()!
	return int(p)
}

// exe_suffix is the platform's executable extension.
fn exe_suffix() string {
	$if windows {
		return '.exe'
	} $else {
		return ''
	}
}

// find_driver locates the WebDriver executable for a browser kind: an env var
// override, then the current directory, then PATH.
fn find_driver(kind BrowserKind) !string {
	mut name := ''
	mut env := ''
	match kind {
		.edge {
			name = 'msedgedriver'
			env = 'EDGEDRIVER'
		}
		.chrome {
			name = 'chromedriver'
			env = 'CHROMEDRIVER'
		}
		.firefox {
			name = 'geckodriver'
			env = 'GECKODRIVER'
		}
		.safari {
			name = 'safaridriver'
			env = 'SAFARIDRIVER'
		}
	}

	ev := os.getenv(env)
	if ev != '' && os.exists(ev) {
		return ev
	}

	local := name + exe_suffix()
	if os.exists(local) {
		return os.abs_path(local)
	}

	return os.find_abs_path_of_executable(name) or {
		error('${name} not found on PATH; install it, set ${env}, or pass driver_path')
	}
}

// find_browser_binary locates an installed browser executable for a kind.
fn find_browser_binary(kind BrowserKind) !string {
	match kind {
		.edge {
			return find_edge_binary()
		}
		.chrome {
			return find_first_existing('CHROME_BINARY', [
				r'C:\Program Files\Google\Chrome\Application\chrome.exe',
				r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
				'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
				'/usr/bin/google-chrome',
				'/usr/bin/google-chrome-stable',
			], 'chrome')
		}
		.firefox {
			return find_first_existing('FIREFOX_BINARY', [
				r'C:\Program Files\Mozilla Firefox\firefox.exe',
				r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe',
				'/Applications/Firefox.app/Contents/MacOS/firefox',
				'/usr/bin/firefox',
			], 'firefox')
		}
		.safari {
			// Safari has no separate binary path; safaridriver controls it.
			return ''
		}
	}
}

// find_first_existing checks an env var override, then a list of candidate
// paths, then PATH for the named executable.
fn find_first_existing(env string, candidates []string, path_name string) !string {
	ev := os.getenv(env)
	if ev != '' && os.exists(ev) {
		return ev
	}
	for c in candidates {
		if os.exists(c) {
			return c
		}
	}
	return os.find_abs_path_of_executable(path_name) or {
		error('browser binary not found; set ${env} or pass binary')
	}
}

// build_launch_caps assembles Capabilities for a kind from LaunchOptions,
// applying headless flags and an auto-detected browser binary.
fn build_launch_caps(kind BrowserKind, opts LaunchOptions) !Capabilities {
	binary := if opts.binary != '' {
		opts.binary
	} else {
		find_browser_binary(kind) or { '' }
	}

	match kind {
		.edge {
			mut args := opts.args.clone()
			if opts.headless {
				args << '--headless=new'
				args << '--disable-gpu'
			}
			mut eo := EdgeOptions{
				args: args
			}
			if binary != '' {
				eo.binary = binary
			}
			return Capabilities{
				browser_name: 'msedge'
				edge_options: eo
			}
		}
		.chrome {
			mut args := opts.args.clone()
			if opts.headless {
				args << '--headless=new'
				args << '--disable-gpu'
			}
			mut co := ChromeOptions{
				args: args
			}
			if binary != '' {
				co.binary = binary
			}
			return Capabilities{
				browser_name:   'chrome'
				chrome_options: co
			}
		}
		.firefox {
			mut args := opts.args.clone()
			if opts.headless {
				args << '-headless'
			}
			mut fo := FirefoxOptions{
				args: args
			}
			if binary != '' {
				fo.binary = binary
			}
			return Capabilities{
				browser_name:    'firefox'
				firefox_options: fo
			}
		}
		.safari {
			return Capabilities{
				browser_name: 'safari'
			}
		}
	}
}

// wait_for_driver polls the driver's /status endpoint until it responds OK.
fn wait_for_driver(base_url string, timeout_ms int) ! {
	start := time.now()
	for {
		if resp := wd_do('GET', '${base_url}/status', '', '') {
			if resp.status_code == 200 {
				return
			}
		}
		if time.now().unix_milli() - start.unix_milli() > i64(timeout_ms) {
			return error('timeout after ${timeout_ms}ms')
		}
		time.sleep(100 * time.millisecond)
	}
}

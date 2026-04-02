module main

import os
import time
import vebidor {webdriver}
import x.json2 as json

struct BenchConfig {
mut:
	browser    string
	driver_url string
	iters      int
	warmup     int
	headless   bool
	binary     string
}

struct BenchStats {
	name  string
	count int
	min   i64
	max   i64
	avg   f64
	p50   i64
	p95   i64
	p99   i64
}

fn main() {
	cfg := parse_args() or {
		eprintln(err.msg())
		return
	}

	println('WebDriver latency benchmark')
	println('browser=${cfg.browser} driver=${cfg.driver_url} iters=${cfg.iters} warmup=${cfg.warmup} headless=${cfg.headless}')

	mut wd := create_driver(cfg) or {
		eprintln('Failed to create WebDriver session: ${err}')
		eprintln('Ensure driver is running at ${cfg.driver_url}')
		return
	}
	defer {
		wd.quit() or { eprintln('Failed to quit session: ${err}') }
	}

	wd.get('data:text/html,<title>bench</title><h1>bench</h1>') or {
		eprintln('Failed to navigate to local benchmark page: ${err}')
		return
	}

	title_stats := benchmark_get_title(wd, cfg.iters, cfg.warmup) or {
		eprintln(err.msg())
		return
	}
	url_stats := benchmark_get_current_url(wd, cfg.iters, cfg.warmup) or {
		eprintln(err.msg())
		return
	}
	script_stats := benchmark_execute_script(wd, cfg.iters, cfg.warmup) or {
		eprintln(err.msg())
		return
	}

	println('')
	print_stats(title_stats)
	print_stats(url_stats)
	print_stats(script_stats)
}

fn parse_args() !BenchConfig {
	mut cfg := BenchConfig{
		browser:  'edge'
		iters:    200
		warmup:   20
		headless: true
	}
	args := os.args[1..]
	for arg in args {
		if arg == '--' {
			continue
		}
		if arg == '--headed' {
			cfg.headless = false
			continue
		}
		if arg == '--headless' {
			cfg.headless = true
			continue
		}
		if arg.starts_with('--browser=') {
			cfg.browser = arg.all_after('=').to_lower()
			continue
		}
		if arg.starts_with('--driver=') {
			cfg.driver_url = arg.all_after('=')
			continue
		}
		if arg.starts_with('--iters=') {
			cfg.iters = arg.all_after('=').int()
			continue
		}
		if arg.starts_with('--warmup=') {
			cfg.warmup = arg.all_after('=').int()
			continue
		}
		if arg.starts_with('--binary=') {
			cfg.binary = arg.all_after('=')
			continue
		}
		if arg == '--help' || arg == '-h' {
			return error(help_text())
		}
		return error('Unknown argument: ${arg}\n\n${help_text()}')
	}

	if cfg.iters <= 0 {
		return error('--iters must be > 0')
	}
	if cfg.warmup < 0 {
		return error('--warmup must be >= 0')
	}
	if cfg.browser !in ['edge', 'chrome', 'firefox', 'safari'] {
		return error('--browser must be one of: edge|chrome|firefox|safari')
	}
	if cfg.driver_url == '' {
		cfg.driver_url = match cfg.browser {
			'firefox' { 'http://127.0.0.1:4444' }
			'safari' { 'http://127.0.0.1:4445' }
			else { 'http://127.0.0.1:9515' }
		}
	}
	return cfg
}

fn help_text() string {
	return 'Usage:
  v run examples/webdriver_latency_bench.v -- [options]

Options:
  --browser=edge|chrome|firefox|safari
  --driver=http://127.0.0.1:9515
  --iters=200
  --warmup=20
  --binary=C:\\Path\\To\\Browser.exe
  --headless | --headed
'
}

fn create_driver(cfg BenchConfig) !webdriver.WebDriver {
	match cfg.browser {
		'edge' {
			mut args := []string{}
			if cfg.headless {
				args << '--headless=new'
			}
			args << '--disable-gpu'
			args << '--disable-dev-shm-usage'
			args << '--no-sandbox'
			mut caps := webdriver.Capabilities{
				browser_name: 'msedge'
				edge_options: webdriver.EdgeOptions{
					args: args
				}
			}
			edge_bin := if cfg.binary != '' { cfg.binary } else { os.getenv('EDGE_BINARY') }
			if edge_bin != '' {
				mut opts := caps.edge_options or { webdriver.EdgeOptions{} }
				opts.binary = edge_bin
				caps.edge_options = opts
			}
			return webdriver.new_edge_driver(cfg.driver_url, caps)
		}
		'chrome' {
			mut args := []string{}
			if cfg.headless {
				args << '--headless=new'
			}
			args << '--disable-gpu'
			args << '--disable-dev-shm-usage'
			args << '--no-sandbox'
			mut caps := webdriver.Capabilities{
				browser_name:   'chrome'
				chrome_options: webdriver.ChromeOptions{
					args: args
				}
			}
			chrome_bin := if cfg.binary != '' { cfg.binary } else { os.getenv('CHROME_BINARY') }
			if chrome_bin != '' {
				mut opts := caps.chrome_options or { webdriver.ChromeOptions{} }
				opts.binary = chrome_bin
				caps.chrome_options = opts
			}
			return webdriver.new_chrome_driver(cfg.driver_url, caps)
		}
		'firefox' {
			mut args := []string{}
			if cfg.headless {
				args << '-headless'
			}
			mut caps := webdriver.Capabilities{
				browser_name:    'firefox'
				firefox_options: webdriver.FirefoxOptions{
					args: args
				}
			}
			firefox_bin := if cfg.binary != '' { cfg.binary } else { os.getenv('FIREFOX_BINARY') }
			if firefox_bin != '' {
				mut opts := caps.firefox_options or { webdriver.FirefoxOptions{} }
				opts.binary = firefox_bin
				caps.firefox_options = opts
			}
			return webdriver.new_firefox_driver(cfg.driver_url, caps)
		}
		'safari' {
			caps := webdriver.Capabilities{
				browser_name: 'safari'
			}
			return webdriver.new_safari_driver(cfg.driver_url, caps)
		}
		else {
			return error('Unsupported browser: ${cfg.browser}')
		}
	}
}

fn benchmark_get_title(wd webdriver.WebDriver, iters int, warmup int) !BenchStats {
	for _ in 0 .. warmup {
		wd.get_title()!
	}
	mut samples := []i64{cap: iters}
	for _ in 0 .. iters {
		sw := time.new_stopwatch()
		wd.get_title()!
		samples << sw.elapsed().microseconds()
	}
	return calculate_stats('get_title', samples)
}

fn benchmark_get_current_url(wd webdriver.WebDriver, iters int, warmup int) !BenchStats {
	for _ in 0 .. warmup {
		wd.get_current_url()!
	}
	mut samples := []i64{cap: iters}
	for _ in 0 .. iters {
		sw := time.new_stopwatch()
		wd.get_current_url()!
		samples << sw.elapsed().microseconds()
	}
	return calculate_stats('get_current_url', samples)
}

fn benchmark_execute_script(wd webdriver.WebDriver, iters int, warmup int) !BenchStats {
	for _ in 0 .. warmup {
		wd.execute_script('return 1', []json.Any{})!
	}
	mut samples := []i64{cap: iters}
	for _ in 0 .. iters {
		sw := time.new_stopwatch()
		wd.execute_script('return 1', []json.Any{})!
		samples << sw.elapsed().microseconds()
	}
	return calculate_stats('execute_script(return 1)', samples)
}

fn calculate_stats(name string, samples []i64) !BenchStats {
	if samples.len == 0 {
		return error('No samples collected for ${name}')
	}
	mut sorted := samples.clone()
	sorted.sort()

	mut sum := i64(0)
	for v in samples {
		sum += v
	}

	return BenchStats{
		name:  name
		count: samples.len
		min:   sorted[0]
		max:   sorted[sorted.len - 1]
		avg:   f64(sum) / f64(samples.len)
		p50:   percentile(sorted, 0.50)
		p95:   percentile(sorted, 0.95)
		p99:   percentile(sorted, 0.99)
	}
}

fn percentile(sorted []i64, p f64) i64 {
	if sorted.len == 0 {
		return 0
	}
	mut idx := int(f64(sorted.len - 1) * p)
	if idx < 0 {
		idx = 0
	}
	if idx >= sorted.len {
		idx = sorted.len - 1
	}
	return sorted[idx]
}

fn print_stats(stats BenchStats) {
	println('Command: ${stats.name}')
	println('  count: ${stats.count}')
	println('  min: ${f64(stats.min) / 1000.0:.3f} ms')
	println('  avg: ${stats.avg / 1000.0:.3f} ms')
	println('  p50: ${f64(stats.p50) / 1000.0:.3f} ms')
	println('  p95: ${f64(stats.p95) / 1000.0:.3f} ms')
	println('  p99: ${f64(stats.p99) / 1000.0:.3f} ms')
	println('  max: ${f64(stats.max) / 1000.0:.3f} ms')
}

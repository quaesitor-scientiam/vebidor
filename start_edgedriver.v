module main

import os
import time
import net.http

fn main() {
	println('========================================')
	println('EdgeDriver Test Environment Starter')
	println('========================================\n')

	// Check if EdgeDriver is already running
	if is_edgedriver_running() {
		println('✓ EdgeDriver is already running on port 9515')
		println('\nReady to run tests:')
		println('  v test webdriver/')
		println('  v run main.v')
		println('  v run example_phase1.v')
		return
	}

	// Find EdgeDriver executable
	edgedriver_path := find_edgedriver() or {
		eprintln('Error: Could not find msedgedriver.exe')
		eprintln('\nPlease download EdgeDriver from:')
		eprintln('https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/')
		eprintln('\nPlace msedgedriver.exe in:')
		eprintln('  - Current directory: ${os.getwd()}')
		eprintln('  - Or add to PATH')
		exit(1)
	}

	println('Found EdgeDriver: ${edgedriver_path}')
	println('Starting EdgeDriver on port 9515...\n')

	// Start EdgeDriver in background
	mut p := os.new_process(edgedriver_path)
	p.set_args(['--port=9515', '--silent'])
	p.set_redirect_stdio()
	p.run()

	// Wait for EdgeDriver to be ready
	println('Waiting for EdgeDriver to start...')
	for i := 0; i < 10; i++ {
		time.sleep(500 * time.millisecond)
		if is_edgedriver_running() {
			println('✓ EdgeDriver started successfully!\n')
			println('EdgeDriver is now running on http://127.0.0.1:9515')
			println('\nReady to run tests:')
			println('  v test webdriver/')
			println('  v run main.v')
			println('  v run example_phase1.v')
			println('  v run example_phase2.v')
			println('  v run example_phase3.v')
			println('  v run example_phase4.v')
			println('\nPress Ctrl+C to stop EdgeDriver')

			// Keep process alive
			for {
				time.sleep(1 * time.second)
			}
		}
	}

	eprintln('\n✗ Failed to start EdgeDriver')
	eprintln('EdgeDriver process may have exited')
	p.close()
	exit(1)
}

fn find_edgedriver() ?string {
	// Check current directory
	if os.exists('msedgedriver.exe') {
		return 'msedgedriver.exe'
	}
	if os.exists('./msedgedriver.exe') {
		return './msedgedriver.exe'
	}

	// Check PATH
	path_dirs := os.getenv('PATH').split(os.path_delimiter)
	for dir in path_dirs {
		exe_path := os.join_path(dir, 'msedgedriver.exe')
		if os.exists(exe_path) {
			return exe_path
		}
	}

	return none
}

fn is_edgedriver_running() bool {
	// Try to connect to EdgeDriver status endpoint
	resp := http.get('http://127.0.0.1:9515/status') or { return false }
	return resp.status_code == 200
}

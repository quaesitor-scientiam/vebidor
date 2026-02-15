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

	// Check version compatibility
	check_version_compatibility(edgedriver_path)

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

fn get_edge_version() ?string {
	// Common Edge installation paths
	edge_paths := [
		r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
		r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
	]

	// Try common paths first
	for edge_path in edge_paths {
		if os.exists(edge_path) {
			// Get version using PowerShell
			result := os.execute('powershell -NoProfile -Command "(Get-Item \'${edge_path}\').VersionInfo.ProductVersion"')
			if result.exit_code == 0 {
				version := result.output.trim_space()
				if version.len > 0 && version != '' {
					return version
				}
			}
		}
	}

	// Try using registry to find Edge installation
	reg_result := os.execute('powershell -NoProfile -Command "(Get-ItemProperty \'HKLM:\\SOFTWARE\\Microsoft\\EdgeUpdate\\Clients\\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}\' -ErrorAction SilentlyContinue).pv"')
	if reg_result.exit_code == 0 {
		version := reg_result.output.trim_space()
		// Verify it looks like a version number
		if version.len > 0 && version != '' && version.contains('.') {
			return version
		}
	}

	// Try using Edge itself to report version
	for edge_path in edge_paths {
		if os.exists(edge_path) {
			ver_result := os.execute('"${edge_path}" --version')
			if ver_result.exit_code == 0 {
				output := ver_result.output.trim_space()
				// Output format: "Microsoft Edge 131.0.2903.112"
				// Find version pattern in output
				parts := output.split(' ')
				for part in parts {
					if part.contains('.') && part.split('.').len >= 3 {
						// Verify first char is digit
						if part.len > 0 && part[0] >= `0` && part[0] <= `9` {
							return part
						}
					}
				}
			}
		}
	}

	return none
}

fn get_edgedriver_version(edgedriver_path string) ?string {
	// Run EdgeDriver with --version flag
	result := os.execute('"${edgedriver_path}" --version')
	if result.exit_code == 0 {
		// Output format: "MSEdgeDriver 131.0.2903.112 (abc123...)"
		// Extract version number
		output := result.output.trim_space()

		// Try to find version pattern (X.X.X.X)
		parts := output.split(' ')
		for part in parts {
			// Check if part looks like a version (contains dots and numbers)
			if part.contains('.') && part.split('.').len >= 3 {
				// Verify it's numeric
				version_parts := part.split('.')
				if version_parts.len >= 3 {
					// Check first part is numeric
					first := version_parts[0]
					if first.len > 0 && first[0] >= `0` && first[0] <= `9` {
						return part.trim_right(')')
					}
				}
			}
		}
	}
	return none
}

fn extract_major_version(version string) string {
	// Extract major version number (e.g., "131.0.2903.112" -> "131")
	parts := version.split('.')
	if parts.len > 0 {
		major := parts[0]
		// Verify it's numeric
		if major.len > 0 && major[0] >= `0` && major[0] <= `9` {
			return major
		}
	}
	return version
}

fn is_valid_version(version string) bool {
	// Check if version looks valid (contains dots and starts with digit)
	if version.len == 0 || !version.contains('.') {
		return false
	}
	// Check first character is digit
	if version[0] < `0` || version[0] > `9` {
		return false
	}
	// Should have at least 2 parts (major.minor)
	parts := version.split('.')
	return parts.len >= 2
}

fn check_version_compatibility(edgedriver_path string) {
	edge_version := get_edge_version() or {
		println('⚠ Warning: Could not detect Microsoft Edge version')
		println('  Make sure Edge is installed')
		println('')
		return
	}

	edgedriver_version := get_edgedriver_version(edgedriver_path) or {
		println('⚠ Warning: Could not detect EdgeDriver version')
		println('')
		return
	}

	// Validate versions before comparing
	if !is_valid_version(edge_version) {
		println('⚠ Warning: Detected invalid Edge version format: ${edge_version}')
		println('')
		return
	}

	if !is_valid_version(edgedriver_version) {
		println('⚠ Warning: Detected invalid EdgeDriver version format: ${edgedriver_version}')
		println('')
		return
	}

	edge_major := extract_major_version(edge_version)
	driver_major := extract_major_version(edgedriver_version)

	println('Version Check:')
	println('  Edge Browser:  ${edge_version}')
	println('  EdgeDriver:    ${edgedriver_version}')

	if edge_major != driver_major {
		println('')
		println('⚠⚠⚠ WARNING: Version Mismatch! ⚠⚠⚠')
		println('  Edge major version (${edge_major}) does not match EdgeDriver major version (${driver_major})')
		println('  This may cause compatibility issues!')
		println('')
		println('  Download matching EdgeDriver from:')
		println('  https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/')
		println('  Select version: ${edge_major}.x.x.x')
		println('')
	} else {
		println('  ✓ Versions compatible')
		println('')
	}
}

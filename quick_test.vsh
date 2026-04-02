#!/usr/bin/env -S v run

import net
import os
import time

println('\033[36m========================================\033[0m')
println('\033[36mVebidor Quick Tests\033[0m')
println('\033[36m========================================\033[0m')
println('')

// Check if EdgeDriver is running
print('\033[33mChecking EdgeDriver... \033[0m')
conn := net.dial_tcp('localhost:9515') or {
	println('\033[31m❌ EdgeDriver is not running on port 9515\033[0m')
	println('\033[33mPlease start EdgeDriver with: .\\msedgedriver.exe --port=9515\033[0m')
	exit(1)
}
conn.close() or {}
println('\033[32m✓ EdgeDriver is running\033[0m')
println('')

// Run quick tests
println('\033[36mRunning quick tests (2 browser sessions)...\033[0m')
start_ms := time.now().unix_milli()
exit_code := os.system('v test webdriver/quick_test.v')
elapsed := f64(time.now().unix_milli() - start_ms) / 1000.0

println('')
if exit_code == 0 {
	println('\033[32m✅ All tests passed in ${elapsed:.1f} seconds\033[0m')
} else {
	println('\033[31m❌ Tests failed\033[0m')
	exit(1)
}

// Cleanup
println('')
println('\033[33mRunning cleanup...\033[0m')
os.system('v run cleanup_browsers.vsh')

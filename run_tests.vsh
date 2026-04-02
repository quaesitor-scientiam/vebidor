#!/usr/bin/env -S v run

import net
import os

println('\033[36m========================================\033[0m')
println('\033[36mVebidor Test Suite\033[0m')
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

// Run unit tests
println('\033[36m========================================\033[0m')
println('\033[36mRunning Unit Tests\033[0m')
println('\033[36m========================================\033[0m')
if os.system('v test webdriver/') != 0 {
	println('\033[31m❌ Unit tests failed\033[0m')
	exit(1)
}
println('')

// Run integration tests
println('\033[36m========================================\033[0m')
println('\033[36mRunning Integration Tests\033[0m')
println('\033[36m========================================\033[0m')
if os.system('v run integration_test.v') != 0 {
	println('\033[31m❌ Integration tests failed\033[0m')
	exit(1)
}
println('')

println('\033[32m========================================\033[0m')
println('\033[32m✅ All tests passed!\033[0m')
println('\033[32m========================================\033[0m')

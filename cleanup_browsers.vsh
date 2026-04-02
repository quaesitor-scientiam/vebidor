#!/usr/bin/env -S v run

import os

println('\033[33mStopping orphaned Edge browser instances...\033[0m')

// Find and kill headless/remote-debugging Edge processes
result := os.execute('powershell -NoProfile -Command "Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { ${_.CommandLine} -like \'*--headless*\' -or ${_.CommandLine} -like \'*--remote-debugging-port*\' } | Measure-Object | Select-Object -ExpandProperty Count"')
count := result.output.trim_space().int()

if count > 0 {
	println('\033[33mFound ${count} orphaned Edge processes\033[0m')
	os.system('powershell -NoProfile -Command "Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { \$_.CommandLine -like \'*--headless*\' -or \$_.CommandLine -like \'*--remote-debugging-port*\' } | Stop-Process -Force -ErrorAction SilentlyContinue"')
	println('\033[32m✓ Cleaned up Edge processes\033[0m')
} else {
	println('\033[32mNo orphaned Edge processes found\033[0m')
}

// Warn if multiple EdgeDriver instances are running
driver_result := os.execute('powershell -NoProfile -Command "Get-Process msedgedriver -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count"')
driver_count := driver_result.output.trim_space().int()
if driver_count > 1 {
	println('\033[33mWarning: Multiple EdgeDriver instances found. You may want to restart EdgeDriver.\033[0m')
}

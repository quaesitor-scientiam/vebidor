#!/usr/bin/env pwsh
# Cleanup orphaned browser instances

Write-Host "Stopping orphaned Edge browser instances..." -ForegroundColor Yellow

# Get Edge processes started by WebDriver (not regular browser usage)
$edgeProcesses = Get-Process msedge -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*--headless*" -or $_.CommandLine -like "*--remote-debugging-port*" }

if ($edgeProcesses) {
    $count = ($edgeProcesses | Measure-Object).Count
    Write-Host "Found $count orphaned Edge processes" -ForegroundColor Yellow
    $edgeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Cleaned up Edge processes" -ForegroundColor Green
} else {
    Write-Host "No orphaned Edge processes found" -ForegroundColor Green
}

# Also clean up any EdgeDriver processes that might be stuck
$driverProcesses = Get-Process msedgedriver -ErrorAction SilentlyContinue
if ($driverProcesses -and ($driverProcesses | Measure-Object).Count -gt 1) {
    Write-Host "Warning: Multiple EdgeDriver instances found. You may want to restart EdgeDriver." -ForegroundColor Yellow
}

#!/usr/bin/env pwsh
# Quick test runner - runs fast smoke tests

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebDriver Quick Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if EdgeDriver is running
Write-Host "Checking EdgeDriver..." -ForegroundColor Yellow
$edgeDriverRunning = Test-NetConnection -ComputerName localhost -Port 9515 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $edgeDriverRunning) {
    Write-Host "❌ EdgeDriver is not running on port 9515" -ForegroundColor Red
    Write-Host "Please start EdgeDriver with: .\msedgedriver.exe --port=9515" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ EdgeDriver is running" -ForegroundColor Green
Write-Host ""

# Run quick tests
Write-Host "Running quick tests (2 browser sessions)..." -ForegroundColor Cyan
$startTime = Get-Date
v test webdriver/quick_test.v
$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "✅ All tests passed in $([math]::Round($duration, 1)) seconds" -ForegroundColor Green
} else {
    Write-Host "❌ Tests failed" -ForegroundColor Red
    exit 1
}

# Cleanup
Write-Host ""
Write-Host "Running cleanup..." -ForegroundColor Yellow
.\cleanup_browsers.ps1

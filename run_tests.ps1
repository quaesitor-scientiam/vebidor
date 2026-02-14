#!/usr/bin/env pwsh
# Test runner script for WebDriver

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebDriver Test Suite" -ForegroundColor Cyan
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

# Run unit tests
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Unit Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
v test webdriver/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Unit tests failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Run integration tests
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Integration Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
v run integration_test.v
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Integration tests failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ All tests passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

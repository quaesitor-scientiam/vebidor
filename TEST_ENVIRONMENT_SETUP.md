# Test Environment Setup Guide

This guide will help you set up your environment to run v-webdriver tests and examples.

---

## Quick Start (Automated)

### Option 1: Use the Helper Script (Recommended)

```bash
# Compile and run the EdgeDriver starter
v run start_edgedriver.v
```

This script will:
- ✅ Check if EdgeDriver is already running
- ✅ Find msedgedriver.exe automatically
- ✅ Start EdgeDriver on port 9515
- ✅ Verify it's running correctly
- ✅ Keep it running until you press Ctrl+C

Once EdgeDriver is running, open a new terminal and run tests:

```bash
v test webdriver/
```

---

## Manual Setup

### Step 1: Install Prerequisites

#### 1.1 Install Microsoft Edge

EdgeDriver requires Microsoft Edge browser to be installed.

**Check if Edge is installed:**
```bash
# Windows: Check the default Edge location
ls "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

**Download Edge:** https://www.microsoft.com/edge

#### 1.2 Download EdgeDriver

Download the EdgeDriver version that matches your Edge browser version.

**Check your Edge version:**
```bash
# Windows PowerShell
(Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe').VersionInfo.ProductVersion
```

**Download EdgeDriver:**
- URL: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
- Choose the version matching your Edge browser
- Download and extract `msedgedriver.exe`

**Place EdgeDriver in one of these locations:**
- Project directory: `S:\vProjects\v-webdriver\msedgedriver.exe`
- Or add to your PATH

### Step 2: Start EdgeDriver

#### Option A: Direct Command
```bash
# Navigate to where msedgedriver.exe is located
.\msedgedriver.exe --port=9515
```

#### Option B: Silent Mode (No Logs)
```bash
.\msedgedriver.exe --port=9515 --silent
```

#### Option C: With Verbose Logging (for debugging)
```bash
.\msedgedriver.exe --port=9515 --verbose
```

**Leave this terminal open** while running tests.

### Step 3: Verify EdgeDriver is Running

Open a new terminal and test the connection:

```bash
# Using curl
curl http://127.0.0.1:9515/status

# Using PowerShell
Invoke-WebRequest -Uri http://127.0.0.1:9515/status
```

You should see a JSON response with status information.

### Step 4: Run Tests

With EdgeDriver running, you can now run tests:

```bash
# Run all webdriver tests
v test webdriver/

# Run quick smoke tests
v test webdriver/quick_test.v

# Run specific test file
v test webdriver/element_properties_test.v

# Run integration tests
v run integration_test.v

# Run demo examples
v run main.v
v run example_phase1.v
v run example_phase2.v
v run example_phase3.v
v run example_phase4.v
```

---

## Troubleshooting

### Problem: "Failed to connect to EdgeDriver"

**Solution:**
1. Verify EdgeDriver is running: `curl http://127.0.0.1:9515/status`
2. Check if another process is using port 9515
3. Try stopping and restarting EdgeDriver

### Problem: "msedgedriver.exe not found"

**Solution:**
1. Download EdgeDriver from the official site
2. Place in project directory or add to PATH
3. Verify with: `where msedgedriver.exe` (Windows)

### Problem: EdgeDriver version mismatch

**Solution:**
1. Check Edge version: See Step 1.2 above
2. Download matching EdgeDriver version
3. EdgeDriver and Edge versions must match

### Problem: Port 9515 already in use

**Solution:**
```bash
# Windows: Find process using port 9515
netstat -ano | findstr :9515

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use a different port
.\msedgedriver.exe --port=9516

# And update your code to use the new port:
wd := webdriver.new_edge_driver('http://127.0.0.1:9516', caps)!
```

### Problem: Tests timeout or hang

**Solution:**
1. Increase timeouts in test code
2. Check network connectivity
3. Verify Edge browser opens (remove --headless to see)
4. Check EdgeDriver logs for errors

### Problem: "Session not created" errors

**Solution:**
1. Verify Edge binary path in capabilities is correct
2. Check Edge browser can launch manually
3. Try without --headless mode first
4. Check antivirus/firewall isn't blocking

---

## Advanced Configuration

### Running Multiple EdgeDriver Instances

You can run multiple EdgeDriver instances on different ports:

```bash
# Terminal 1
.\msedgedriver.exe --port=9515

# Terminal 2
.\msedgedriver.exe --port=9516

# Terminal 3
.\msedgedriver.exe --port=9517
```

Then in your code:
```v
// Use different ports for parallel testing
wd1 := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
wd2 := webdriver.new_edge_driver('http://127.0.0.1:9516', caps)!
wd3 := webdriver.new_edge_driver('http://127.0.0.1:9517', caps)!
```

### Using EdgeDriver with a Remote Server

```v
// Connect to remote EdgeDriver
caps := webdriver.Capabilities{
	browser_name: 'msedge'
}

wd := webdriver.new_edge_driver('http://remote-server:9515', caps)!
```

### Headless vs Headed Mode

**Headless (for CI/automated testing):**
```v
edge_options: webdriver.EdgeOptions{
	args: ['--headless=new']  // Browser window not visible
}
```

**Headed (for debugging/development):**
```v
edge_options: webdriver.EdgeOptions{
	args: []  // Browser window visible
}
```

---

## Test Environment Checklist

Before running tests, verify:

- [ ] Microsoft Edge is installed
- [ ] EdgeDriver version matches Edge version
- [ ] msedgedriver.exe is accessible (in project dir or PATH)
- [ ] EdgeDriver is running on port 9515
- [ ] Can connect to http://127.0.0.1:9515/status
- [ ] No firewall blocking localhost:9515
- [ ] V compiler is installed and working

---

## Continuous Integration (CI) Setup

### Example GitHub Actions Workflow

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup V
      uses: vlang/setup-v@v1

    - name: Install Edge
      uses: browser-actions/setup-edge@latest

    - name: Download EdgeDriver
      run: |
        # Download matching EdgeDriver version
        $EdgeVersion = (Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion
        # Download and extract EdgeDriver
        # (Add download script here)

    - name: Start EdgeDriver
      run: |
        Start-Process msedgedriver.exe -ArgumentList "--port=9515","--silent"
        Start-Sleep -Seconds 2

    - name: Run Tests
      run: v test webdriver/

    - name: Stop EdgeDriver
      if: always()
      run: Stop-Process -Name msedgedriver -Force
```

---

## Best Practices

### 1. Always Clean Up Sessions

```v
wd := webdriver.new_edge_driver(url, caps)!
defer {
	wd.quit() or { eprintln('Failed to quit: ${err}') }
}
```

### 2. Use Timeouts

```v
// Set reasonable timeouts
wd.set_implicit_wait(10000)!         // 10 seconds
wd.set_page_load_timeout(30000)!     // 30 seconds
wd.set_script_timeout(15000)!        // 15 seconds
```

### 3. Handle Errors Gracefully

```v
element := wd.find_element('css selector', 'h1') or {
	eprintln('Element not found: ${err}')
	return
}
```

### 4. Use Headless Mode for CI

```v
$if test {
	// Headless in test mode
	args: ['--headless=new']
} $else {
	// Visible for development
	args: []
}
```

---

## Helper Scripts

### start_edgedriver.v

Automated EdgeDriver starter:
```bash
v run start_edgedriver.v
```

Features:
- Auto-detects if EdgeDriver is running
- Finds msedgedriver.exe automatically
- Starts EdgeDriver with optimal settings
- Verifies successful startup
- Provides helpful error messages

---

## Additional Resources

- **EdgeDriver Documentation**: https://docs.microsoft.com/en-us/microsoft-edge/webdriver-chromium/
- **W3C WebDriver Spec**: https://www.w3.org/TR/webdriver/
- **v-webdriver README**: [README.md](README.md)
- **Testing Guide**: [TESTING.md](TESTING.md)

---

## Quick Reference Commands

```bash
# Start environment
v run start_edgedriver.v

# In new terminal - run tests
v test webdriver/              # All tests
v test webdriver/quick_test.v  # Quick tests only
v run main.v                   # Demo showcase
v run example_phase1.v         # Phase 1 demo
v run example_phase2.v         # Phase 2 demo
v run example_phase3.v         # Phase 3 demo
v run example_phase4.v         # Phase 4 demo

# Stop EdgeDriver
Ctrl+C  # In the EdgeDriver terminal
```

---

**Status**: Complete test environment setup guide
**Version**: v2.0.0 compatible
**Last Updated**: 2026-02-14

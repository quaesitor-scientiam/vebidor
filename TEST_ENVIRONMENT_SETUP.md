# Test Environment Setup Guide

This guide will help you set up your environment to run v-webdriver tests and examples with **Edge, Chrome, Firefox, or Safari**.

---

## 🌐 Multi-Browser Support

v-webdriver now supports **4 major browsers**:

| Browser | Driver | Default Port | Supported Platforms |
|---------|--------|--------------|---------------------|
| **Microsoft Edge** | EdgeDriver | 9515 | Windows, macOS, Linux |
| **Google Chrome** | ChromeDriver | 9515 | Windows, macOS, Linux |
| **Mozilla Firefox** | GeckoDriver | 4444 | Windows, macOS, Linux |
| **Apple Safari** | SafariDriver | 4445 | macOS only |

Choose your browser below for setup instructions.

---

## Quick Start (Automated)

### Microsoft Edge (Recommended for Windows)

```bash
# Compile and run the EdgeDriver starter
v run start_edgedriver.v
```

This script will:
- ✅ Check if EdgeDriver is already running
- ✅ Find msedgedriver.exe automatically
- ✅ **Check version compatibility** between Edge and EdgeDriver
- ✅ **Warn if versions don't match**
- ✅ Start EdgeDriver on port 9515
- ✅ Verify it's running correctly
- ✅ Keep it running until you press Ctrl+C

**Example output:**
```
========================================
EdgeDriver Test Environment Starter
========================================

Found EdgeDriver: msedgedriver.exe
Version Check:
  Edge Browser:  131.0.2903.112
  EdgeDriver:    131.0.2903.112
  ✓ Versions compatible

Starting EdgeDriver on port 9515...
```

Once EdgeDriver is running, open a new terminal and run tests:

```bash
v test webdriver/
```

---

## Manual Setup

Choose your browser:
- [Microsoft Edge](#microsoft-edge-setup)
- [Google Chrome](#google-chrome-setup)
- [Mozilla Firefox](#firefox-setup)
- [Apple Safari](#safari-setup)

---

## Microsoft Edge Setup

### Step 1: Install Microsoft Edge

EdgeDriver requires Microsoft Edge browser to be installed.

**Check if Edge is installed:**
```bash
# Windows: Check the default Edge location
ls "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

**Download Edge:** https://www.microsoft.com/edge

### Step 2: Download EdgeDriver

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

### Step 3: Start EdgeDriver

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

---

## Google Chrome Setup

### Step 1: Install Google Chrome

**Check if Chrome is installed:**
```bash
# Windows
ls "C:\Program Files\Google\Chrome\Application\chrome.exe"

# macOS
ls "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Linux
which google-chrome
```

**Download Chrome:** https://www.google.com/chrome/

### Step 2: Download ChromeDriver

Download the ChromeDriver version that matches your Chrome browser version.

**Check your Chrome version:**
```bash
# Windows PowerShell
(Get-Item 'C:\Program Files\Google\Chrome\Application\chrome.exe').VersionInfo.ProductVersion

# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --version

# Linux
google-chrome --version
```

**Download ChromeDriver:**
- URL: https://chromedriver.chromium.org/downloads
- Or use Chrome for Testing: https://googlechromelabs.github.io/chrome-for-testing/
- Choose the version matching your Chrome browser
- Download and extract `chromedriver.exe` (Windows) or `chromedriver` (macOS/Linux)

**Place ChromeDriver in one of these locations:**
- Project directory or add to your PATH

### Step 3: Start ChromeDriver

```bash
# Windows
.\chromedriver.exe --port=9515

# macOS/Linux
./chromedriver --port=9515

# Silent mode
.\chromedriver.exe --port=9515 --silent

# Verbose logging
.\chromedriver.exe --port=9515 --verbose
```

**Leave this terminal open** while running tests.

### Step 4: Update Your Code

```v
import webdriver

caps := webdriver.Capabilities{
    browser_name: 'chrome'
    chrome_options: webdriver.ChromeOptions{
        args: ['--headless=new', '--disable-gpu']
        binary: r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    }
}

wd := webdriver.new_chrome_driver('http://127.0.0.1:9515', caps)!
defer { wd.quit() or {} }
```

---

## Firefox Setup

### Step 1: Install Mozilla Firefox

**Check if Firefox is installed:**
```bash
# Windows
ls "C:\Program Files\Mozilla Firefox\firefox.exe"

# macOS
ls "/Applications/Firefox.app/Contents/MacOS/firefox"

# Linux
which firefox
```

**Download Firefox:** https://www.mozilla.org/firefox/

### Step 2: Download GeckoDriver

**Download GeckoDriver:**
- URL: https://github.com/mozilla/geckodriver/releases
- Download the latest release for your platform
- Extract `geckodriver.exe` (Windows) or `geckodriver` (macOS/Linux)

**Place GeckoDriver in one of these locations:**
- Project directory or add to your PATH

### Step 3: Start GeckoDriver

```bash
# Windows
.\geckodriver.exe --port=4444

# macOS/Linux
./geckodriver --port=4444

# With logging
.\geckodriver.exe --port=4444 --log trace
```

**Leave this terminal open** while running tests.

### Step 4: Update Your Code

```v
import webdriver

caps := webdriver.Capabilities{
    browser_name: 'firefox'
    firefox_options: webdriver.FirefoxOptions{
        args: ['-headless']
        binary: r'C:\Program Files\Mozilla Firefox\firefox.exe'
    }
}

wd := webdriver.new_firefox_driver('http://127.0.0.1:4444', caps)!
defer { wd.quit() or {} }
```

---

## Safari Setup

### Step 1: Enable SafariDriver (macOS only)

Safari comes with built-in WebDriver support on macOS.

**Enable SafariDriver:**
```bash
# Run once to enable
safaridriver --enable
```

You may need to enter your password to authorize.

### Step 2: Start SafariDriver

```bash
# Start on default port
safaridriver -p 4445

# Or with logging
safaridriver -p 4445 --diagnose
```

**Leave this terminal open** while running tests.

### Step 3: Update Your Code

```v
import webdriver

caps := webdriver.Capabilities{
    browser_name: 'safari'
    safari_options: webdriver.SafariOptions{
        automatic_inspection: false
        automatic_profiling: false
    }
}

wd := webdriver.new_safari_driver('http://127.0.0.1:4445', caps)!
defer { wd.quit() or {} }
```

**Note:** Safari requires macOS 10.12 or later. SafariDriver is included with Safari.

---

## Verify WebDriver is Running

Open a new terminal and test the connection:

**Edge/Chrome (port 9515):**
```bash
# Using curl
curl http://127.0.0.1:9515/status

# Using PowerShell
Invoke-WebRequest -Uri http://127.0.0.1:9515/status
```

**Firefox (port 4444):**
```bash
curl http://127.0.0.1:4444/status
```

**Safari (port 4445):**
```bash
curl http://127.0.0.1:4445/status
```

You should see a JSON response with status information.

## Run Tests

With your WebDriver running, you can now run tests:

```bash
# Run all webdriver tests (uses Edge by default)
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
v run example_phase8.v
```

**Note:** Most tests currently use Edge by default. To test with other browsers, you'll need to modify the test files to use the appropriate driver function (`new_chrome_driver()`, `new_firefox_driver()`, or `new_safari_driver()`).

---

## Troubleshooting

### General Issues

#### Problem: "Failed to connect to WebDriver"

**Solution:**
1. Verify WebDriver is running:
   - Edge/Chrome: `curl http://127.0.0.1:9515/status`
   - Firefox: `curl http://127.0.0.1:4444/status`
   - Safari: `curl http://127.0.0.1:4445/status`
2. Check if another process is using the port
3. Try stopping and restarting the WebDriver

#### Problem: "WebDriver executable not found"

**Solution:**
1. Download the correct WebDriver for your browser
2. Place in project directory or add to PATH
3. Verify with:
   - Windows: `where msedgedriver` / `where chromedriver` / `where geckodriver`
   - macOS/Linux: `which chromedriver` / `which geckodriver`

### Edge-Specific Issues

#### Problem: EdgeDriver version mismatch

**Symptoms:**
- `start_edgedriver.v` shows warning: "⚠⚠⚠ WARNING: Version Mismatch! ⚠⚠⚠"
- Tests fail with "session not created" errors
- Browser fails to start or crashes

**Solution:**
1. The automated script (`v run start_edgedriver.v`) will detect this automatically
2. Check Edge version manually:
   ```bash
   powershell -Command "(Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe').VersionInfo.ProductVersion"
   ```
3. Download matching EdgeDriver version from:
   https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
4. **Important**: Major versions MUST match (e.g., Edge 131.x needs EdgeDriver 131.x)
5. Replace your old msedgedriver.exe with the new one

### Chrome-Specific Issues

#### Problem: Chrome version mismatch

**Solution:**
1. Check Chrome version:
   ```bash
   # Windows
   (Get-Item 'C:\Program Files\Google\Chrome\Application\chrome.exe').VersionInfo.ProductVersion

   # macOS/Linux
   google-chrome --version
   ```
2. Download matching ChromeDriver from https://chromedriver.chromium.org/downloads
3. Major versions MUST match (e.g., Chrome 120.x needs ChromeDriver 120.x)

#### Problem: "Chrome failed to start"

**Solution:**
1. Verify Chrome binary path is correct in capabilities
2. Try without `--headless` to see error messages
3. Add `--no-sandbox` and `--disable-dev-shm-usage` for Linux environments

### Firefox-Specific Issues

#### Problem: "Firefox not found"

**Solution:**
1. Verify Firefox is installed
2. Specify binary path explicitly in FirefoxOptions:
   ```v
   firefox_options: webdriver.FirefoxOptions{
       binary: r'C:\Program Files\Mozilla Firefox\firefox.exe'
   }
   ```

#### Problem: GeckoDriver connection refused

**Solution:**
1. Make sure GeckoDriver is running on port 4444
2. Check for conflicting processes on port 4444
3. Try a different port and update your code accordingly

### Safari-Specific Issues

#### Problem: "Could not connect to SafariDriver"

**Solution:**
1. Enable SafariDriver first: `safaridriver --enable`
2. Check if Safari Technology Preview is interfering
3. Verify macOS version is 10.12 or later

#### Problem: "Safari permission denied"

**Solution:**
1. Run `safaridriver --enable` and enter your password
2. Check System Preferences > Security & Privacy
3. Allow automation in Safari preferences

### Port Already in Use

**Problem:** Port 9515, 4444, or 4445 already in use

**Solution:**
```bash
# Windows: Find process using a port (e.g., 9515)
netstat -ano | findstr :9515

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# macOS/Linux: Find and kill process
lsof -i :9515
kill -9 <PID>

# Or use a different port
.\msedgedriver.exe --port=9516
.\chromedriver.exe --port=9516
.\geckodriver.exe --port=4445

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

### Edge Checklist
- [ ] Microsoft Edge is installed
- [ ] EdgeDriver version matches Edge version
- [ ] msedgedriver.exe is accessible (in project dir or PATH)
- [ ] EdgeDriver is running on port 9515
- [ ] Can connect to http://127.0.0.1:9515/status
- [ ] No firewall blocking localhost:9515
- [ ] V compiler is installed and working

### Chrome Checklist
- [ ] Google Chrome is installed
- [ ] ChromeDriver version matches Chrome version
- [ ] chromedriver executable is accessible
- [ ] ChromeDriver is running on port 9515
- [ ] Can connect to http://127.0.0.1:9515/status
- [ ] V compiler is installed and working

### Firefox Checklist
- [ ] Mozilla Firefox is installed
- [ ] GeckoDriver is downloaded and accessible
- [ ] GeckoDriver is running on port 4444
- [ ] Can connect to http://127.0.0.1:4444/status
- [ ] V compiler is installed and working

### Safari Checklist (macOS only)
- [ ] Safari is installed (comes with macOS)
- [ ] SafariDriver is enabled (`safaridriver --enable`)
- [ ] SafariDriver is running on port 4445
- [ ] Can connect to http://127.0.0.1:4445/status
- [ ] macOS 10.12 or later
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

### Edge (Windows Recommended)
```bash
# Start EdgeDriver
v run start_edgedriver.v         # Automated
# OR
.\msedgedriver.exe --port=9515   # Manual

# Run tests
v test webdriver/
v run main.v

# Stop EdgeDriver
Ctrl+C
```

### Chrome (Cross-platform)
```bash
# Start ChromeDriver
.\chromedriver.exe --port=9515   # Windows
./chromedriver --port=9515       # macOS/Linux

# Run tests (modify test files to use new_chrome_driver)
v test webdriver/
v run main.v

# Stop ChromeDriver
Ctrl+C
```

### Firefox (Cross-platform)
```bash
# Start GeckoDriver
.\geckodriver.exe --port=4444    # Windows
./geckodriver --port=4444        # macOS/Linux

# Run tests (modify test files to use new_firefox_driver)
v test webdriver/
v run main.v

# Stop GeckoDriver
Ctrl+C
```

### Safari (macOS only)
```bash
# Enable SafariDriver (run once)
safaridriver --enable

# Start SafariDriver
safaridriver -p 4445

# Run tests (modify test files to use new_safari_driver)
v test webdriver/
v run main.v

# Stop SafariDriver
Ctrl+C
```

---

**Status**: Complete multi-browser test environment setup guide
**Version**: v3.1.0 compatible (4-browser support)
**Last Updated**: 2026-02-15

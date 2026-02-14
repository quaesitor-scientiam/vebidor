# WebDriver Testing Guide

This document describes how to run tests for the V WebDriver library.

## Prerequisites

1. **Microsoft Edge** must be installed
2. **EdgeDriver** must be running on port 9515
   ```powershell
   # Start EdgeDriver (from the directory where msedgedriver.exe is located)
   .\msedgedriver.exe --port=9515
   ```

## Running Unit Tests

Unit tests are located in `webdriver/webdriver_test.v` and test individual components.

```powershell
# Run all tests in the webdriver module
v test webdriver/

# Run a specific test
v test webdriver/ -stats
```

## Running Integration Tests

Integration tests are located in `integration_test.v` and test real-world scenarios.

```powershell
# Build and run integration tests
v run integration_test.v
```

## Test Coverage

### Unit Tests (`webdriver/webdriver_test.v`)

The unit tests cover:

- ✅ **Session Lifecycle**: Creating and quitting sessions
- ✅ **Navigation**: URL navigation, back, forward, refresh
- ✅ **Element Finding**: Single and multiple elements, CSS selectors
- ✅ **Error Handling**: Non-existent elements
- ✅ **JavaScript Execution**: Scripts with and without arguments
- ✅ **Window Management**: Handles, rect, resizing
- ✅ **Cookies**: Add, get, delete operations
- ✅ **Capabilities**: Conversion to session parameters
- ✅ **Actions**: Builders for keyboard, mouse, wheel actions
- ✅ **Edge Features**: Browser version

### Integration Tests (`integration_test.v`)

The integration tests cover real-world scenarios:

1. **Search Flow Test**
   - Navigate to a website
   - Verify page title
   - Find and interact with elements
   - Extract text content

2. **Cookie Management Test**
   - Add multiple cookies
   - Retrieve all cookies
   - Delete specific cookies
   - Delete all cookies

3. **Window Management Test**
   - Get window handles
   - Get and set window size
   - Verify window position

4. **JavaScript Execution Test**
   - Arithmetic operations
   - String manipulation
   - DOM queries
   - URL retrieval

5. **Navigation Flow Test**
   - Navigate between pages
   - Use browser back/forward
   - Refresh page

6. **Multiple Elements Test**
   - Find multiple elements by selector
   - Verify element counts

## Test Output

### Successful Unit Test
```
OK: webdriver/webdriver_test.v
```

### Successful Integration Test
```
========================================
Running WebDriver Integration Tests
========================================
Running integration test: Search flow
✓ Navigated to example.com
✓ Page title verified: Example Domain
✓ Found h1 element: f.68A11F3A70E25283E388FB0326359182.d.A40B1D8DC01E83BF53B90F473343ECE2.e.2
✓ Heading text: Example Domain
✅ Search flow test passed!

[... more tests ...]

========================================
All integration tests completed!
========================================
```

## Troubleshooting

### EdgeDriver not running
```
Error: Failed to create session: Post "http://127.0.0.1:9515/session" dial tcp 127.0.0.1:9515: connect: connection refused
```
**Solution**: Start EdgeDriver on port 9515

### Edge binary not found
```
Error: cannot find msedge binary
```
**Solution**: Update the `binary` path in capabilities to match your Edge installation

### Session creation fails
```
Error: No matching capabilities found
```
**Solution**: Ensure `browser_name` is set to `'msedge'` and the binary path is correct

## Writing New Tests

### Unit Test Example
```v
fn test_my_feature() {
    wd := setup_test_driver() or {
        assert false
        return
    }
    defer {
        wd.quit() or {}
    }

    // Your test code here
    wd.get('https://example.com') or {
        assert false
        return
    }

    // Assertions
    assert condition == expected
}
```

### Integration Test Example
```v
fn test_my_scenario() ! {
    println('Running test: My scenario')

    caps := webdriver.Capabilities{
        browser_name: 'msedge'
        accept_insecure_certs: true
        edge_options: webdriver.EdgeOptions{
            args: ['--headless=new']
            binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
        }
    }

    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
    defer {
        wd.quit() or {}
    }

    // Your test scenario here
    wd.get('https://example.com')!
    println('✓ Test step completed')

    println('✅ My scenario test passed!')
}
```

## Continuous Integration

For CI environments, run tests with:

```powershell
# Run all tests
v test .

# Run with verbose output
v test . -stats

# Run integration tests
v run integration_test.v
```

## Test Best Practices

1. **Always use `defer` to quit sessions** - Prevents orphaned browser instances
2. **Use headless mode in CI** - Faster and more stable
3. **Handle errors explicitly** - Better debugging
4. **Clean up resources** - Delete cookies, close windows after tests
5. **Use meaningful assertions** - Clear test failure messages

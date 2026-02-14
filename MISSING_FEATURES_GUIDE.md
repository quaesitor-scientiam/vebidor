# Quick Guide: Working Around Missing Features

This guide shows how to work around missing V WebDriver features using JavaScript execution until native methods are implemented.

## Element Properties (Currently Missing)

### Get Element Text

**Missing**: `element.get_text()`

**Workaround**:
```v
element := wd.find_element('css selector', 'h1')!
text := wd.execute_script('return arguments[0].textContent', [
    json.Any(json.encode(element))
])!
println('Text: ${text}')
```

### Get Element Attribute

**Missing**: `element.get_attribute(name)`

**Workaround**:
```v
element := wd.find_element('css selector', 'a')!
href := wd.execute_script('return arguments[0].getAttribute("href")', [
    json.Any(json.encode(element))
])!
println('Href: ${href}')
```

### Check if Element is Displayed

**Missing**: `element.is_displayed()`

**Workaround**:
```v
element := wd.find_element('css selector', '#hidden-div')!
visible := wd.execute_script('
    const el = arguments[0];
    return el.offsetWidth > 0 && el.offsetHeight > 0 &&
           window.getComputedStyle(el).visibility !== "hidden";
', [json.Any(json.encode(element))])!

if visible.bool() {
    println('Element is visible')
}
```

### Check if Element is Enabled

**Missing**: `element.is_enabled()`

**Workaround**:
```v
element := wd.find_element('css selector', 'button')!
enabled := wd.execute_script('return !arguments[0].disabled', [
    json.Any(json.encode(element))
])!

if enabled.bool() {
    wd.click(element)!
}
```

### Get Element Property

**Missing**: `element.get_property(name)`

**Workaround**:
```v
element := wd.find_element('css selector', 'input')!
value := wd.execute_script('return arguments[0].value', [
    json.Any(json.encode(element))
])!
println('Input value: ${value}')
```

## Page Information (Currently Missing)

### Get Page Title

**Missing**: Direct `wd.get_title()` method

**Current Workaround** (already working):
```v
title := wd.execute_script('return document.title', [])!
println('Title: ${title}')
```

### Get Current URL

**Missing**: Direct `wd.get_current_url()` method

**Workaround**:
```v
url := wd.execute_script('return window.location.href', [])!
println('Current URL: ${url}')
```

### Get Page Source

**Missing**: `wd.get_page_source()`

**Workaround**:
```v
source := wd.execute_script('return document.documentElement.outerHTML', [])!
println('Page source length: ${source.str().len}')
```

## Alert Handling (Currently Missing)

### Accept Alert

**Missing**: `wd.accept_alert()`

**Workaround**:
```v
// Check if alert exists and accept it
result := wd.execute_script('
    try {
        alert("Test alert");
        return true;
    } catch (e) {
        return false;
    }
', [])!

// Note: W3C WebDriver requires proper alert endpoints
// JavaScript execution cannot fully replace alert handling
```

**Limitation**: JavaScript cannot handle browser alerts properly. This requires implementing the W3C alert endpoints.

## Element Interaction (Partially Missing)

### Clear Input Field

**Missing**: `wd.clear(element)`

**Workaround**:
```v
element := wd.find_element('css selector', 'input')!
wd.execute_script('arguments[0].value = ""', [
    json.Any(json.encode(element))
])!
```

### Submit Form

**Missing**: `wd.submit(element)`

**Workaround**:
```v
form := wd.find_element('css selector', 'form')!
wd.execute_script('arguments[0].submit()', [
    json.Any(json.encode(element))
])!
```

## Window Management (Partially Missing)

### Switch to Window/Tab

**Missing**: `wd.switch_to_window(handle)`

**Note**: This requires implementing the W3C WebDriver window switching endpoint. Cannot be done via JavaScript.

### Maximize Window

**Missing**: `wd.maximize_window()`

**Partial Workaround**:
```v
// Set to a large size (not true maximize)
wd.set_window_rect(webdriver.WindowRect{
    x: 0
    y: 0
    width: 1920
    height: 1080
})!

// Or use JavaScript for screen size
size := wd.execute_script('
    return {
        width: screen.availWidth,
        height: screen.availHeight
    }
', [])!
```

## Waits (Basic Implementation Only)

### Implicit Wait

**Missing**: `wd.set_implicit_wait(seconds)`

**Workaround**: Use the existing `wait_for()` method:
```v
// Wait for element to exist
wd.wait_for(fn [element_selector] (wd webdriver.WebDriver) !bool {
    wd.find_element('css selector', element_selector) or { return false }
    return true
}, 10000, 500)!
```

### Wait for Element to be Clickable

**Missing**: Expected conditions

**Workaround**:
```v
wd.wait_for(fn [selector] (wd webdriver.WebDriver) !bool {
    element := wd.find_element('css selector', selector) or { return false }

    // Check if visible and enabled
    clickable := wd.execute_script('
        const el = arguments[0];
        return el.offsetWidth > 0 && el.offsetHeight > 0 && !el.disabled;
    ', [json.Any(json.encode(element))]) or { return false }

    return clickable.bool()
}, 10000, 500)!
```

### Wait for Text to be Present

**Missing**: Expected conditions

**Workaround**:
```v
wd.wait_for(fn [selector, expected_text] (wd webdriver.WebDriver) !bool {
    element := wd.find_element('css selector', selector) or { return false }
    text := wd.execute_script('return arguments[0].textContent', [
        json.Any(json.encode(element))
    ]) or { return false }

    return text.str().contains(expected_text)
}, 10000, 500)!
```

## Complete Example: Login Form with Workarounds

```v
import webdriver
import x.json2 as json

fn main() {
    caps := webdriver.Capabilities{
        browser_name: 'msedge'
        edge_options: webdriver.EdgeOptions{
            args: ['--headless=new']
            binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
        }
    }

    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps) or {
        eprintln('Failed: ${err}')
        return
    }
    defer { wd.quit() or {} }

    // Navigate
    wd.get('https://example.com/login') or { return }

    // Wait for page to load (workaround for implicit wait)
    wd.wait_for(fn (wd webdriver.WebDriver) !bool {
        wd.find_element('css selector', '#username') or { return false }
        return true
    }, 10000, 500) or {
        eprintln('Timeout waiting for page')
        return
    }

    // Find elements
    username_field := wd.find_element('css selector', '#username') or { return }
    password_field := wd.find_element('css selector', '#password') or { return }
    submit_button := wd.find_element('css selector', 'button[type="submit"]') or { return }

    // Clear fields (workaround)
    wd.execute_script('arguments[0].value = ""', [
        json.Any(json.encode(username_field))
    ]) or { return }

    // Enter credentials
    wd.send_keys(username_field, 'testuser') or { return }
    wd.send_keys(password_field, 'password123') or { return }

    // Check if button is enabled (workaround)
    enabled := wd.execute_script('return !arguments[0].disabled', [
        json.Any(json.encode(submit_button))
    ]) or { return }

    if enabled.bool() {
        wd.click(submit_button) or { return }
    }

    // Wait for redirect
    wd.wait_for(fn (wd webdriver.WebDriver) !bool {
        url := wd.execute_script('return window.location.pathname', []) or {
            return false
        }
        return url.str() == '/dashboard'
    }, 5000, 500) or {
        eprintln('Login failed or redirect timeout')
        return
    }

    // Get page title (workaround)
    title := wd.execute_script('return document.title', []) or { return }
    println('Logged in! Page title: ${title}')

    // Get welcome message text (workaround)
    welcome := wd.find_element('css selector', '.welcome-message') or { return }
    text := wd.execute_script('return arguments[0].textContent', [
        json.Any(json.encode(welcome))
    ]) or { return }
    println('Welcome message: ${text}')
}
```

## Summary

Most missing features can be worked around using `execute_script()`, but some limitations exist:

### ✅ Can be worked around with JavaScript:
- Element text/attributes/properties
- Element state (visible, enabled)
- Page info (title, URL, source)
- Clear input
- Submit form
- Custom waits

### ❌ Cannot be fully worked around:
- Alert handling (needs W3C endpoints)
- Window/tab switching (needs W3C endpoints)
- Implicit waits (needs W3C endpoints)
- Some timeouts (needs W3C endpoints)

For production use, implementing the W3C endpoints for these features is recommended rather than relying on JavaScript workarounds.

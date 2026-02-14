# V WebDriver - W3C WebDriver Protocol Implementation

A V language implementation of the W3C WebDriver protocol for browser automation.

## 🚀 Features

### ✅ Fully Implemented
- **Session Management** - Create, manage, and quit browser sessions
- **Navigation** - Navigate, back, forward, refresh
- **Element Location** - Find elements by CSS selector, XPath, ID, class name, etc.
- **Element Interaction** - Click, send keys, clear input fields
- **Element Properties** ✨ NEW - Get text, attributes, properties, check visibility/enabled/selected state, get tag name
- **JavaScript Execution** - Execute synchronous scripts with arguments
- **Window Management** - Get handles, get/set window size
- **Cookies** - Get, add, delete cookies
- **Screenshots** - Capture page and element screenshots
- **Frame Switching** - Switch between frames and iframes
- **Actions API** - Keyboard, mouse, and wheel actions
- **Waits** - Basic wait functionality
- **Edge-Specific** - Network conditions, device emulation, browser version

### ⚠️ Planned Features (See IMPLEMENTATION_PLAN.md)
- Alert handling (accept, dismiss, get text)
- Page information (get_title, get_current_url, get_page_source)
- Advanced window management (switch windows, maximize)
- Implicit waits and expected conditions

## 📦 Installation

### Prerequisites
1. [V compiler](https://vlang.io/) installed
2. Microsoft Edge browser
3. [EdgeDriver](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/) matching your Edge version

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd W3C

# Start EdgeDriver
.\msedgedriver.exe --port=9515
```

## 🎯 Quick Start

```v
import webdriver

fn main() {
    // Configure capabilities
    caps := webdriver.Capabilities{
        browser_name: 'msedge'
        accept_insecure_certs: true
        edge_options: webdriver.EdgeOptions{
            args: ['--headless=new']
            binary: r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
        }
    }

    // Create WebDriver session
    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps) or {
        eprintln('Failed to create driver: ${err}')
        return
    }
    defer {
        wd.quit() or { eprintln('Failed to quit: ${err}') }
    }

    // Navigate to a page
    wd.get('https://example.com')!

    // Find an element
    heading := wd.find_element('css selector', 'h1')!

    // Execute JavaScript
    title := wd.execute_script('return document.title', [])!
    println('Page title: ${title}')

    // Take a screenshot
    screenshot := wd.screenshot()!
    println('Screenshot captured (base64): ${screenshot[..50]}...')
}
```

## 📖 Examples

### Form Automation
```v
import webdriver

fn login_example() ! {
    caps := webdriver.Capabilities{
        browser_name: 'msedge'
    }

    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
    defer { wd.quit() or {} }

    wd.get('https://example.com/login')!

    // Find form elements
    username := wd.find_element('css selector', '#username')!
    password := wd.find_element('css selector', '#password')!
    submit := wd.find_element('css selector', 'button[type="submit"]')!

    // Fill the form
    wd.send_keys(username, 'testuser')!
    wd.send_keys(password, 'password123')!
    wd.click(submit)!
}
```

### Working with Cookies
```v
import webdriver

fn cookie_example() ! {
    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
    defer { wd.quit() or {} }

    wd.get('https://example.com')!

    // Add a cookie
    cookie := webdriver.Cookie{
        name: 'session_id'
        value: 'abc123'
        path: '/'
        domain: 'example.com'
    }
    wd.add_cookie(cookie)!

    // Get all cookies
    cookies := wd.get_cookies()!
    println('Cookies: ${cookies.len}')

    // Delete a cookie
    wd.delete_cookie('session_id')!
}
```

### Using Actions API
```v
import webdriver

fn actions_example() ! {
    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
    defer { wd.quit() or {} }

    wd.get('https://example.com')!

    // Type text using actions
    wd.type_text('Hello World')!

    // Scroll down
    wd.scroll_by(0, 500)!

    // Click at coordinates
    wd.click_at(100, 200)!
}
```

### Waiting for Elements
```v
import webdriver

fn wait_example() ! {
    wd := webdriver.new_edge_driver('http://127.0.0.1:9515', caps)!
    defer { wd.quit() or {} }

    wd.get('https://example.com')!

    // Wait for element to appear
    wd.wait_for(fn (wd webdriver.WebDriver) !bool {
        wd.find_element('css selector', '#dynamic-content') or { return false }
        return true
    }, 10000, 500)!

    element := wd.find_element('css selector', '#dynamic-content')!
    wd.click(element)!
}
```

## 🧪 Testing

### Run Quick Tests (~10 seconds)
```bash
v test webdriver/quick_test.v
```

### Run Full Test Suite (~1-2 minutes)
```bash
v test webdriver/
```

### Run Integration Tests (~2-3 minutes)
```bash
v run integration_test.v
```

### Run Simple Standalone Test
```bash
v simple_test.v
.\simple_test.exe
```

## 📚 Documentation

- **[PHASE1_COMPLETE.md](PHASE1_COMPLETE.md)** ✨ NEW - Phase 1 completion summary
- **[COMPARISON_WITH_SELENIUM.md](COMPARISON_WITH_SELENIUM.md)** - Feature comparison with Selenium
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Roadmap for missing features
- **[MISSING_FEATURES_GUIDE.md](MISSING_FEATURES_GUIDE.md)** - Workarounds for remaining missing features
- **[TESTING.md](TESTING.md)** - Testing guide
- **[CHANGELOG.md](CHANGELOG.md)** - Change history

## 🎯 Feature Coverage

**Current**: **68%** feature parity with Selenium WebDriver (was 55%)
**Latest**: Phase 1 Complete - Element Properties fully implemented!

| Category | Status |
|----------|--------|
| Session Management | ✅ 100% |
| Navigation | ✅ 100% |
| Element Location | ✅ 100% |
| Cookies | ✅ 100% |
| Screenshots | ✅ 100% |
| Frames | ✅ 100% |
| **Element Properties** | ✅ **100%** ✨ NEW |
| Actions API | ✅ 80% |
| **Element Interaction** | ✅ **75%** (improved) |
| Window Management | ⚠️ 56% |
| Alerts | ❌ 0% (Phase 2) |
| Waits | ⚠️ 14% (basic only) |

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for roadmap to 85% coverage.

## ✨ New in Phase 1

No more workarounds needed for element properties! Now you can use native methods:

```v
// Get element text - NOW NATIVE!
element := wd.find_element('css selector', 'h1')!
text := wd.get_text(element)!

// Get attributes - NOW NATIVE!
link := wd.find_element('css selector', 'a')!
href := wd.get_attribute(link, 'href')!

// Check visibility - NOW NATIVE!
if wd.is_displayed(element)! {
    wd.click(element)!
}

// Check if enabled - NOW NATIVE!
button := wd.find_element('css selector', 'button')!
if wd.is_enabled(button)! {
    wd.click(button)!
}

// Clear input fields - NOW NATIVE!
input := wd.find_element('css selector', '#username')!
wd.clear(input)!
wd.send_keys(input, 'newtext')!
```

See [PHASE1_COMPLETE.md](PHASE1_COMPLETE.md) for all new methods and examples.

## 🏗️ Project Structure

```
v-webdriver/
├── webdriver/
│   ├── client.v              # Core WebDriver client
│   ├── elements.v            # Element finding and interaction
│   ├── script.v              # JavaScript execution
│   ├── window.v              # Window management
│   ├── cookies.v             # Cookie operations
│   ├── screenshot.v          # Screenshot capture
│   ├── actions.v             # Actions API
│   ├── frame.v               # Frame switching
│   ├── wait.v                # Wait utilities
│   ├── capabiities.v         # Capabilities configuration
│   ├── types.v               # Common types
│   ├── errors.v              # Error handling
│   ├── webdriver_test.v      # Unit tests
│   └── quick_test.v          # Quick smoke tests
├── main.v                    # Example usage
├── simple_test.v             # Standalone test suite
├── integration_test.v        # Integration tests
└── README.md                 # This file
```

## 🤝 Contributing

Contributions are welcome! Priority areas:

1. **Element Properties** - Implement `get_text()`, `get_attribute()`, `is_displayed()`, etc.
2. **Alert Handling** - Implement alert/confirm/prompt methods
3. **Page Info** - Implement `get_title()`, `get_current_url()`, `get_page_source()`
4. **Advanced Waits** - Implement expected conditions
5. **Window Switching** - Implement multi-window/tab support

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for detailed specifications.

## 📄 License

[Your License Here]

## 🙏 Acknowledgments

- Built following the [W3C WebDriver Specification](https://www.w3.org/TR/webdriver/)
- Inspired by Selenium WebDriver
- Powered by the [V Programming Language](https://vlang.io/)

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check existing documentation
- Review test files for usage examples

---

**Status**: Production-ready for web automation. Element properties fully implemented!

**Version**: 0.95.0 (68% Selenium feature parity) - Phase 1 Complete ✅

**Target**: 1.0.0 (85% Selenium feature parity)

**Latest Update**: 2026-02-14 - Added 8 element property methods


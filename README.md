# PySwiftKit

![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![Python](https://img.shields.io/badge/Python-3.13+-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

PySwiftKit is a powerful Swift Package Manager library for **bidirectional Python-Swift interoperability**. It uses Swift macros to generate Python C API bindings, enabling seamless communication between Swift and Python code.

## ✨ Features

- **🔄 Bidirectional Binding** - Call Swift from Python and Python from Swift
- **🎯 Swift Macros** - Automatic binding generation with `@PyClass`, `@PyModule`, `@PyMethod`
- **🔀 Type Conversion** - Automatic marshalling of common types (Int, String, Array, Dictionary, etc.)
- **⚡ Performance** - Direct C API integration with efficient GIL management
- **🛡️ Type Safety** - Full Swift type system support with generic conversions
- **📱 iOS & macOS** - Support for iOS 13+ and macOS 11+
- **🐍 Python 3.13** - Compatible with the latest Python version

## 📦 Installation

### Swift Package Manager

Add PySwiftKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Py-Swift/PySwiftKit", from: "313.1.1")
]
```

### Requirements

- **Swift**: 5.0+ (Swift 6.0 tools)
- **Python**: 3.13+
- **Platforms**: iOS 13+, macOS 11+

## 🚀 Quick Start

### Hello World Example

**Swift Code:**

```swift
import PySwiftWrapper

@PyClass
class HelloWorld {
    @PyInit
    init() {}
    
    @PyMethod
    func sendString(text: String) {
        print("Swift received: \(text)")
    }
}

@PyModule
struct HelloWorldModule: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        HelloWorld.self
    ]
}
```

**Python Usage:**

```python
from hello_world import HelloWorld

hw = HelloWorld()
hw.send_string("Hello from Python!")
# Output: Swift received: Hello from Python!
```

### Device Info Example (iOS)

**Swift Code:**

```swift
import UIKit
import PySwiftWrapper

@PyClass
class DeviceInfo {
    @PyInit
    init() {}
    
    @PyMethod
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    @PyMethod
    func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    @PyMethod
    func getAllInfo() -> [String: String] {
        return [
            "name": UIDevice.current.name,
            "model": UIDevice.current.model,
            "system": UIDevice.current.systemName,
            "version": UIDevice.current.systemVersion
        ]
    }
}

@PyModule
struct DeviceInfoModule: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        DeviceInfo.self
    ]
}
```

**Python Usage:**

```python
from device_info import DeviceInfo

device = DeviceInfo()

# Get individual properties
print(f"Device: {device.get_device_name()}")
print(f"iOS Version: {device.get_system_version()}")

# Get all information
info = device.get_all_info()
for key, value in info.items():
    print(f"{key}: {value}")
```

### Callbacks from Swift to Python

**Swift Code:**

```swift
@PyClass
class HelloWorld {
    var _callback: PyPointer
    
    @PyInit
    init(callback: PyPointer) {
        _callback = callback
    }
    
    @PyMethod
    func sendString(text: String) {
        callback(text + " World")
    }
    
    @PyCall
    func callback(text: String)
}
```

**Python Usage:**

```python
from hello_world import HelloWorld

def my_callback(text: str):
    print(f"Callback received: {text}")

hw = HelloWorld(my_callback)
hw.send_string("Hello")
# Output: Callback received: Hello World

# Or with lambda
hw = HelloWorld(lambda text: print(text))
hw.send_string("Hello")
```

## 🔄 Type Conversions

PySwiftKit automatically converts between Python and Swift types:

### Numeric Types

| Python Type | Swift Type | Description |
|-------------|------------|-------------|
| `int` | `Int`, `Int32`, `Int16`, `Int8` | Signed integers |
| `int` | `UInt`, `UInt32`, `UInt16`, `UInt8` | Unsigned integers |
| `float` | `Double`, `Float`, `Float16` | Floating-point numbers |

### Collections

| Python Type | Swift Type | Description |
|-------------|------------|-------------|
| `str` | `String` | Unicode strings |
| `bytes` | `Data`, `[UInt8]` | Binary data |
| `list[int]` | `[Int]`, `[UInt8]` | Integer arrays |
| `list[float]` | `[Double]`, `[Float]` | Float arrays |
| `list[str]` | `[String]` | String arrays |
| `dict` | `[String: Any]` | Dictionaries |

### Example

```swift
@PyClass
class TypeConverter {
    @PyMethod
    func processInt(_ value: Int) {
        print("Received: \(value)")
    }
    
    @PyMethod
    func processFloats(_ values: [Double]) {
        print("Floats: \(values)")
    }
    
    @PyMethod
    func processData(_ data: Data) {
        print("Data size: \(data.count)")
    }
}
```

```python
converter = TypeConverter()

converter.process_int(42)
converter.process_floats([3.14, 2.71, 1.41])
converter.process_data(b"Hello, Swift!")
```

## 📚 Architecture

PySwiftKit uses a three-layer architecture:

1. **PySwiftKit** - Low-level Python C API wrappers
2. **PySerializing** - Type conversion protocols (`PySerialize`/`PyDeserialize`)
3. **PySwiftWrapper** - Swift macros for automatic binding generation

### GIL Management

PySwiftKit provides safe GIL (Global Interpreter Lock) management:

```swift
// Explicit GIL acquisition
withGIL {
    // Python C API calls here
}

// Conditional GIL acquisition
withAutoGIL {
    // Only acquires if not already held
}

// Check GIL state
if PyHasGIL() {
    // GIL is held
}
```

## 📖 Documentation

- **[Developer Guide](https://github.com/Py-Swift/PySwiftKit/blob/master/.github/copilot-instructions.md)** - Comprehensive guide for contributors
- **[Wiki](https://py-swift.github.io/wiki/)** - Tutorials and examples
- **[API Reference](https://github.com/Py-Swift/PySwiftKit)** - Full API documentation

## 🎯 Use Cases

- **iOS Apps with Python** - Embed Python scripts in iOS applications
- **Data Science on Apple Platforms** - Use Python data science libraries in Swift apps
- **Hybrid Applications** - Combine Swift's performance with Python's ecosystem
- **Cross-Platform Tools** - Share algorithmic code between Python and Swift
- **Rapid Prototyping** - Prototype in Python, optimize in Swift

## �� Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

PySwiftKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## 🔗 Links

- **[GitHub](https://github.com/Py-Swift/PySwiftKit)**
- **[Wiki & Tutorials](https://py-swift.github.io/wiki/)**
- **[Issues](https://github.com/Py-Swift/PySwiftKit/issues)**

---

Made with ❤️ by the Py-Swift team

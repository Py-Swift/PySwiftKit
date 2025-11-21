# PySwiftKit v313.1.2

## 🐛 Bug Fixes & Improvements

### GIL Management Enhancement
- **Fixed GIL deadlock issue** in callback generators
- Updated `PyCallback.swift` to conditionally acquire GIL only when not already held
- Changed from unconditional `PyGILState_Ensure()` to checking `PyGIL_Released()` first
- Added optional unwrapping for `PyGILState_Release()` calls

### Concurrency Improvements
- **Added `@MainActor` annotations** to test classes for Swift 6 concurrency safety
- **Added `@preconcurrency` imports** for CPython and PySwiftKit modules
- Improved thread safety in test infrastructure

### Dependency Updates
- **Updated CPython dependency** from 313.7.1 to 313.8.1
- Updated package dependency strategy from `.upToNextMinor` to `.upToNextMajor`
- Downgraded swift-docc-plugin from 1.4.5 to 1.3.0 for compatibility
- Updated swift-syntax to 601.0.1

### Test Enhancements
- **Fixed NumericTestClass initialization** - now requires `value: String` parameter
- Updated Python test script to match new initializer signature
- Changed `py_classes` from `var` to `let` in module declarations
- Added Swift language mode v5 to test targets

### Code Quality
- Improved GIL handling in generated callback code
- Better error handling in callback wrappers
- Enhanced type safety in macro-generated code

## 📦 Installation

```swift
dependencies: [
    .package(url: "https://github.com/Py-Swift/PySwiftKit", from: "313.1.2")
]
```

## 🔧 Technical Details

### Breaking Changes
- `NumericTestClass` now requires a `String` parameter in its initializer (test code only)

### Files Modified
- `Sources/PyWrapperInternal/Generators/PyCallback.swift` - GIL management improvements
- `Tests/PyTests/InitPython.swift` - Added `@MainActor` and `@preconcurrency`
- `Tests/PyTests/PySwiftWrapperTests/NumericTestClass.swift` - Updated initializer
- `Tests/PyTests/pyswiftwrapper_tests.py` - Updated to match Swift changes
- `Package.swift` - Updated dependencies and added Swift 5 language mode to tests
- `Package.resolved` - Updated dependency versions

## 🙏 Credits

This release improves the stability and thread safety of PySwiftKit, making it more robust for production use.

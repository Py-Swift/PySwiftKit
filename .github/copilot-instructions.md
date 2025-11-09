# PySwiftKit Development Guide

## Project Overview

PySwiftKit is a Swift Package Manager library for bidirectional Python-Swift interoperability. It uses Swift macros to generate Python C API bindings, enabling Swift classes/functions to be called from Python and vice versa.

### Core Architecture

**Three-Layer Design:**
1. **PySwiftKit** - Low-level Python C API wrappers (`PyPointer`, GIL management, type conversions)
2. **PySerializing** - Type conversion protocols (`PySerialize`/`PyDeserialize`) for Swift ↔ Python data marshalling
3. **PySwiftWrapper** - Swift macros that generate Python bindings at compile time

**Key Components:**
- `CPySwiftObject` - C struct bridging Swift objects to Python objects (defines `PySwiftObject` with `swift_ptr`)
- `PySwiftGenerators` - Compiler plugin with macros: `@PyClass`, `@PyModule`, `@PyFunction`, `@PyContainer`
- `PyWrapperInternal` - Macro implementation details using SwiftSyntax to generate binding code
- `PyProtocols` - Core protocols (`PyClassProtocol`, `PyModuleProtocol`, `PyPointerProtocol`)

## Critical Patterns

### Python GIL Management

**Always use GIL helpers when crossing language boundaries:**
```swift
// Check GIL state
PyHasGIL()  // Returns true if current thread holds GIL
PyGIL_Released()  // Returns true if GIL not held

// Explicit GIL acquisition
withGIL {
    // Python C API calls here
}

// Conditional GIL acquisition (only acquires if not already held)
withAutoGIL {
    // Safer for reentrant code
}
```

**GIL in generated code:** Macro-generated wrappers automatically inject `PyGILState_Ensure()` / `PyGILState_Release()` when `gil: true` parameter is set.

### Type Conversion Protocols

**PySerialize** (Swift → Python):
```swift
protocol PySerialize {
    func pyPointer() -> PyPointer
}
// Implemented for: Int, String, Bool, Array, Dictionary, Optional, etc.
```

**PyDeserialize** (Python → Swift):
```swift
protocol PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self
    static func casted(unsafe object: PyPointer) throws -> Self
}
// Use .casted(from:) for safe conversion with error handling
```

### Swift Macros Usage

**@PyClass** - Generate Python class from Swift class:
```swift
@PyClass(bases: [.number], unretained: false)
final class MyClass {
    @PyInit
    init() {}
    
    @PyMethod
    func myMethod() -> Int { 42 }
    
    @PyProperty
    var myProp: String { "hello" }
}
// Generates: _PyType, _PyMethodDefs, _PyGetSetDefs, tp_* functions
```

**@PyModule** - Register classes with Python:
```swift
@PyModule
struct MyModule: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        MyClass.self
    ]
}
// Call MyModule.py_init in PyImport_AppendInittab()
```

**Protocol Extensions** - Use Python protocol slots:
```swift
extension MyClass: PyNumberProtocol {
    func nb_add(_ other: PyPointer) -> PyPointer? { 
        (try! Int.casted(from: other) + 5).pyPointer()
    }
    func nb_multiply(_ other: PyPointer) -> PyPointer? { 
        (try! Int.casted(from: other) * 3).pyPointer()
    }
}
```

**Available Protocol Slots:**
- `PyNumberProtocol` - Arithmetic operations (nb_add, nb_subtract, nb_multiply, nb_true_divide, etc.)
- `PySequenceProtocol` - Sequence operations (sq_length, sq_item, sq_ass_item, sq_contains)
- `PyMappingProtocol` - Mapping operations (mp_length, mp_subscript, mp_ass_subscript)
- `PyAsyncProtocol` - Async operations (am_await, am_aiter, am_anext)
- `PyBufferProtocol` - Buffer interface (bf_getbuffer, bf_releasebuffer)

### Memory Management

**PyPointer reference counting:**
```swift
let pyObj = something.pyPointer()
defer { Py_DecRef(pyObj) }  // ALWAYS decrement when done

// Helper extension
extension PyPointer {
    func decRef() { Py_DecRef(self) }
}
```

**PySwiftObject structure:** Python objects wrapping Swift instances store `void* swift_ptr` - the Swift object must remain alive as long as Python holds a reference.

**Unretained mode:** Use `@PyClass(unretained: true)` when Swift already manages object lifetime. Without this, Python's reference counting controls deallocation.

## Development Workflows

### Building
```bash
swift build -v
# Or in Xcode: Cmd+B
# Dependencies: CPython package (313.7.0+), swift-syntax (601.0.0+)
```

### Testing
Tests use embedded Python runtime. Initialize Python once:
```swift
// Tests/PyTests/InitPython.swift
initPython()  // Configures isolated Python with custom stdlib path
// Then register module: PyImport_AppendInittab("mymodule", MyModule.py_init)
```

**Test execution order is critical:**
1. Register modules with `PyImport_AppendInittab()` BEFORE `Py_Initialize()`
2. Call `Py_InitializeFromConfig()` to start Python
3. Call `PyEval_SaveThread()` to release GIL for multi-threaded access
4. Use `withGIL {}` in tests when calling Python code

Run Python test scripts:
```swift
// From Swift test that calls Python
withGIL {
    let result = PyRun_SimpleString("""
        from mymodule import MyClass
        obj = MyClass()
        assert obj.myMethod() == 42
    """)
}
```

**Run tests:**
```bash
swift test -v  # Run all tests with verbose output
swift test --filter PySwiftWrapperTests  # Run specific test class
```

### Code Organization Rules

**Swift 5 language mode:** All targets use `.swiftLanguageMode(.v5)` in Package.swift

**Macro targets are separated:**
- `PyWrapperInternal` - Target with macro implementations (depends on SwiftSyntax)
- `PySwiftGenerators` - Macro plugin (type `.macro` in Package.swift)
- Never import macro implementations in runtime code

**Protocol conformance:** Generated `@PyClass` types automatically conform to `PyClassProtocol` via macro extension

**Package.swift flags:**
- `local = false` - Use GitHub package dependencies (default)
- `local = true` - Use local path to CPython package for development
- `dev_mode = true` - Expose internal targets for debugging

## Debugging & Performance

### Debugging Techniques

**Inspecting Generated Macro Code:**
```bash
# Expand macros to see generated code
swift build -Xswiftc -Xfrontend -Xswiftc -dump-macro-expansions
```

**Python Error Handling:**
```swift
// Always check and print Python errors
if let error = PyErr_Occurred() {
    PyErr_Print()  // Prints traceback to stderr
}

// Clear errors manually if needed
PyErr_Clear()
```

**Debugging GIL Issues:**
```swift
// Add assertions to verify GIL state
assert(PyHasGIL(), "GIL must be held here")
assert(PyGIL_Released(), "GIL must be released here")
```

**Inspecting Python Objects:**
```swift
withGIL {
    let obj = someSwiftValue.pyPointer()
    defer { Py_DecRef(obj) }
    
    // Print object representation
    PyObject_Print(obj, stdout, 0)
    
    // Get type name
    let typeName = String(cString: obj.pointee.ob_type.pointee.tp_name)
    print("Python type: \(typeName)")
}
```

### Performance Considerations

**Minimize GIL Thrashing:**
```swift
// BAD: Acquiring GIL repeatedly in loop
for item in items {
    withGIL {
        processPythonObject(item)
    }
}

// GOOD: Hold GIL for entire batch
withGIL {
    for item in items {
        processPythonObject(item)
    }
}
```

**Avoid Unnecessary Conversions:**
```swift
// BAD: Converting back and forth
let pyInt = swiftInt.pyPointer()
let swiftInt2 = try! Int.casted(from: pyInt)

// GOOD: Work in one domain at a time
let pyInt = swiftInt.pyPointer()
defer { Py_DecRef(pyInt) }
// Do all Python operations with pyInt
```

**Reference Counting Optimization:**
```swift
// For return values that Python will own, don't increment
func myMethod() -> PyPointer {
    return value.pyPointer()  // Python takes ownership
}

// For stored references, increment
var storedPyObj: PyPointer?
func storeObject(_ obj: PyPointer) {
    Py_IncRef(obj)
    storedPyObj = obj
}
```

**Use PyPointer directly when possible:**
```swift
// BAD: Unnecessary type conversions
@PyMethod
func processValue(_ val: Int) -> String {
    return "Result: \(val)"
}

// GOOD: Work with PyPointer directly for complex operations
@PyMethod
func processValue(_ val: PyPointer) -> PyPointer? {
    // Direct Python C API manipulation, no conversion overhead
    guard PyLong_Check(val) != 0 else { return nil }
    let result = PyNumber_Add(val, PyLong_FromLong(10))
    return result  // Ownership transferred
}
```

## Advanced Patterns

### Custom Python Type with Multiple Bases

```swift
@PyClass(bases: [.number, .sequence], base_type: .none)
final class HybridClass {
    @PyInit
    init() {}
}

extension HybridClass: PyNumberProtocol {
    func nb_add(_ other: PyPointer) -> PyPointer? { ... }
}

extension HybridClass: PySequenceProtocol {
    func sq_length() -> Int { ... }
    func sq_item(_ index: Int) -> PyPointer? { ... }
}
```

### Python Container Types

```swift
@PyContainer(name: "MyContainer")
struct SwiftContainer {
    var items: [String]
    var count: Int
}
// Automatically generates PyDeserialize conformance for easy Python→Swift conversion
```

### Working with Python Modules

```swift
// Import and call Python functions from Swift
withGIL {
    guard let module = PyImport_ImportModule("math") else {
        PyErr_Print()
        return
    }
    defer { Py_DecRef(module) }
    
    guard let sqrtFunc = PyObject_GetAttrString(module, "sqrt") else {
        PyErr_Print()
        return
    }
    defer { Py_DecRef(sqrtFunc) }
    
    let args = PyTuple_New(1)
    defer { Py_DecRef(args) }
    PyTuple_SetItem(args, 0, PyLong_FromLong(16))
    
    guard let result = PyObject_CallObject(sqrtFunc, args) else {
        PyErr_Print()
        return
    }
    defer { Py_DecRef(result) }
    
    let value = try! Double.casted(from: result)
    print("sqrt(16) = \(value)")  // 4.0
}
```

### Attribute Access Helpers

```swift
// PySwiftKit provides convenience functions for attribute access
withGIL {
    let obj = myPythonObject()
    defer { Py_DecRef(obj) }
    
    // Set attribute
    PyObject_SetAttr(obj, key: "name", value: "MyName")
    
    // Get attribute with type inference
    let name: String = try PyObject_GetAttr(obj, key: "name")
    
    // Check if attribute exists
    if PyObject_HasAttr(obj, "optional_field") {
        let field: Int = try PyObject_GetAttr(obj, key: "optional_field")
    }
}
```

## Common Issues

**"PyGIL_Check() returned 0"** - Trying to call Python C API without GIL. Wrap in `withGIL {}`.

**Segfault on Python object access** - Likely reference counting error. Check for missing `Py_DecRef` or accessing deallocated `swift_ptr`.

**"Module not found"** - Ensure module registered via `PyImport_AppendInittab()` before `Py_Initialize()`, and Python initialized with `PyEval_SaveThread()` at the end.

**SwiftSyntax version conflicts** - Lock swift-syntax to `~> 601.0.0` and rebuild with `swift package update`.

**Macro expansion errors** - Check that `@PyClass` is only on `final class` types, not structs or non-final classes. Macro targets must not be imported in runtime code.

**Python module import fails in tests** - Verify `Tests/python3.13/` contains complete Python stdlib. The isolated config requires all modules to be local.

**Type mismatch in PyDeserialize** - Use `try? Type.casted(from:)` for optional conversions or provide explicit error handling. Check Python type with `PyLong_Check()`, `PyUnicode_Check()`, etc. before casting.

## Key Files Reference

### Core Runtime Files
- `Sources/PySwiftKit/PySwiftKit.swift` - GIL helpers (`withGIL`, `withAutoGIL`, `PyHasGIL`)
- `Sources/PySwiftKit/PyPointer.swift` - PyPointer typealias and extensions
- `Sources/CPySwiftObject/CPySwiftObject.{h,c}` - C bridge: `PySwiftObject` struct with `swift_ptr`
- `Sources/PyProtocols/PyClassProtocol.swift` - Protocol all `@PyClass` types conform to

### Type Conversion Files
- `Sources/PySerializing/PySerialize.swift` - `PySerialize` protocol (Swift → Python)
- `Sources/PySerializing/PyDeserialize.swift` - `PyDeserialize` protocol (Python → Swift)
- `Sources/PySerializing/PySerialize/*.swift` - Implementations for Int, String, Array, etc.
- `Sources/PySerializing/PyDeserialize/*.swift` - Implementations for all standard types

### Macro Implementation Files
- `Sources/PySwiftGenerators/PySwiftGenerators.swift` - Compiler plugin registration
- `Sources/PySwiftGenerators/PySwiftClassGenerator.swift` - Main `@PyClass` macro implementation
- `Sources/PySwiftGenerators/PySwiftModuleGenerator.swift` - `@PyModule` macro implementation
- `Sources/PyWrapperInternal/Generators/PyCallableProtocol.swift` - Code generation for callable wrappers with GIL handling
- `Sources/PyWrapperInternal/PyTypeObject/*.swift` - Python type object slot definitions

### Macro Definition Files (User-facing)
- `Sources/PySwiftWrapper/PySwiftWrapper.swift` - Macro declarations (`@PyClass`, `@PyModule`, `@PyMethod`, etc.)

### Test Files
- `Tests/PyTests/InitPython.swift` - Python runtime initialization for tests
- `Tests/PyTests/PySwiftWrapperTests/NumericTestClass.swift` - Example `@PyClass` with PyNumberProtocol
- `Tests/PyTests/pyswiftwrapper_tests.py` - Python test scripts that import Swift classes

### Configuration Files
- `Package.swift` - SPM manifest with `local`/`dev_mode` flags, Swift 5 language mode settings
- `.github/workflows/swift.yml` - CI configuration (builds on macOS 13 with Xcode 15)

## External Dependencies

**CPython package** (py-swift/CPython): 
- Provides Python.h headers and `CPython` module
- Version must match target Python runtime (3.13)
- SPM package: `https://github.com/py-swift/CPython` at `313.7.0+`
- Contains Swift wrappers for Python C API

**swift-syntax** (Apple):
- Used for macro implementation
- Version: `601.0.0+` (locked to avoid breaking changes)
- Provides SwiftSyntax, SwiftSyntaxBuilder, SwiftSyntaxMacros, SwiftCompilerPlugin
- Only imported in macro targets, never in runtime code

**Platforms:** 
- iOS 13+, macOS 11+
- Python runtime must be embedded in app bundle for iOS
- See `Tests/python3.13/` for example of embedded Python stdlib
- macOS can use system Python, iOS requires bundled interpreter

## Quick Start Example

```swift
// 1. Define a Swift class with Python bindings
import PySwiftWrapper

@PyClass
final class Calculator {
    @PyInit
    init() {}
    
    @PyMethod
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
    
    @PyProperty
    var version: String { "1.0" }
}

// 2. Create a module to expose classes
@PyModule
struct MathModule: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Calculator.self
    ]
}

// 3. Register and use from Python
PyImport_AppendInittab("mathmodule", MathModule.py_init)
Py_Initialize()
PyEval_SaveThread()

withGIL {
    PyRun_SimpleString("""
        from mathmodule import Calculator
        calc = Calculator()
        result = calc.add(5, 3)
        print(f"Result: {result}")  # Output: Result: 8
        print(f"Version: {calc.version}")  # Output: Version: 1.0
    """)
}
```

## Architecture Decision Records

**Why Swift 5 language mode?** - Swift 6 strict concurrency checking breaks macro implementations. All targets locked to `.swiftLanguageMode(.v5)`.

**Why separate macro targets?** - Macro implementations use SwiftSyntax which has large compile times. Separating `PyWrapperInternal` (macro implementation) from `PySwiftGenerators` (plugin) and runtime code reduces build times and prevents cyclic dependencies.

**Why PyTypeObjectContainer?** - Python's `PyTypeObject` must have stable memory address. Container provides `@unchecked Sendable` wrapper managing heap-allocated `PyTypeObject` with proper dealloc.

**Why custom PyModuleDef_HEAD_INIT?** - Python's macro conflicts with Swift. Exported from `CPySwiftObject.c` as `_PyModuleDef_HEAD_INIT` for use in Swift code.

**Why isolated Python config in tests?** - Prevents conflicts with system Python. Tests use bundled `python3.13/` stdlib with `PyConfig_InitIsolatedConfig()` for reproducible test environment.

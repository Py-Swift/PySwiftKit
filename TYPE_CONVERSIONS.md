# PySwiftKit Type Conversions Reference

This document provides a comprehensive reference for all automatic type conversions between Python and Swift in PySwiftKit. These conversions are handled by the `PySerialize` (Swift → Python) and `PyDeserialize` (Python → Swift) protocols.

## Overview

**PySerialize Protocol** - Converts Swift types to Python objects via `.pyPointer()` method
**PyDeserialize Protocol** - Converts Python objects to Swift types via `.casted(from:)` and `.casted(unsafe:)` methods

## Type Conversion Tables

### 1. Numeric Types - Signed Integers

| Swift Type | Python Type | PySerialize API | PyDeserialize API | Notes |
|------------|-------------|----------------|-------------------|-------|
| `Int` | `int` | `PyLong_FromLong()` | `PyLong_AsLong()` | Platform word size (32/64-bit) |
| `Int64` | `int` | `PyLong_FromLongLong()` | `PyLong_AsLongLong()` | 64-bit signed integer |
| `Int32` | `int` | `PyLong_FromLong()` | `PyLong_AsInt()` | 32-bit signed integer |
| `Int16` | `int` | `PyLong_FromLong()` | `PyLong_AsLong()` | 16-bit signed integer, truncated |
| `Int8` | `int` | `PyLong_FromLong()` | `PyLong_AsLong()` | 8-bit signed integer, truncated |

**Implementation Details:**
```swift
// Swift → Python
extension Int: PySerialize {
    func pyPointer() -> PyPointer {
        PyLong_FromLong(self)
    }
}

// Python → Swift
extension Int: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { 
            throw PyStandardException.typeError 
        }
        return PyLong_AsLong(object)
    }
}
```

### 2. Numeric Types - Unsigned Integers

| Swift Type | Python Type | PySerialize API | PyDeserialize API | Notes |
|------------|-------------|----------------|-------------------|-------|
| `UInt` | `int` | `PyLong_FromUnsignedLong()` | `PyLong_AsUnsignedLong()` | Platform word size (32/64-bit) |
| `UInt64` | `int` | `PyLong_FromUnsignedLongLong()` | `PyLong_AsUnsignedLongLong()` | 64-bit unsigned integer |
| `UInt32` | `int` | `PyLong_FromUnsignedLong()` | `PyLong_AsUnsignedLong()` | 32-bit unsigned integer |
| `UInt16` | `int` | `PyLong_FromUnsignedLong()` | `PyLong_AsUnsignedLong()` | 16-bit unsigned integer, truncated |
| `UInt8` | `int` | `PyLong_FromUnsignedLong()` | `PyLong_AsUnsignedLong()` | 8-bit unsigned integer, truncated |

**Implementation Details:**
```swift
// Swift → Python
extension UInt: PySerialize {
    func pyPointer() -> PyPointer {
        PyLong_FromUnsignedLong(self)
    }
}

// Python → Swift
extension UInt: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { 
            throw PyStandardException.typeError 
        }
        return PyLong_AsUnsignedLong(object)
    }
}
```

### 3. Numeric Types - Floating Point

| Swift Type | Python Type | PySerialize API | PyDeserialize API | Notes |
|------------|-------------|----------------|-------------------|-------|
| `Double` | `float` | `PyFloat_FromDouble()` | `PyFloat_AS_DOUBLE()` | 64-bit floating point |
| `Float` / `Float32` | `float` | `PyFloat_FromDouble()` | `PyFloat_AS_DOUBLE()` | Converted via Double |
| `Float16` | `float` | `PyFloat_FromDouble()` | `PyFloat_AS_DOUBLE()` | iOS 16+, macOS 11+ only |
| `CGFloat` | `float` | `PyFloat_FromDouble()` | `PyFloat_AS_DOUBLE()` | CoreFoundation only |

**Implementation Details:**
```swift
// Swift → Python (generic for all BinaryFloatingPoint)
extension PySerialize where Self: BinaryFloatingPoint {
    func pyPointer() -> PyPointer {
        PyFloat_FromDouble(Double(self))
    }
}

// Python → Swift
extension Double: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyFloat) else { 
            throw PyStandardException.typeError 
        }
        return PyFloat_AS_DOUBLE(object)
    }
}
```

### 4. Boolean Type

| Swift Type | Python Type | PySerialize API | PyDeserialize API | Notes |
|------------|-------------|----------------|-------------------|-------|
| `Bool` | `bool` | `__Py_True__` / `__Py_False__` | Pointer comparison | Singleton objects |

**Implementation Details:**
```swift
// Swift → Python
extension Bool: PySerialize {
    func pyPointer() -> PyPointer {
        self ? __Py_True__ : __Py_False__
    }
}

// Python → Swift
extension Bool: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Bool {
        if object == __Py_True__ { return true }
        else if object == __Py_False__ { return false }
        else { throw PyStandardException.typeError }
    }
}
```

### 5. String Types

| Swift Type | Python Type | PySerialize API | PyDeserialize API | Notes |
|------------|-------------|----------------|-------------------|-------|
| `String` | `str` | `PyUnicode_FromString()` | `PyUnicode_AsUTF8()` | UTF-8 encoding |
| `Substring` | `str` | `PyUnicode_FromString()` | `PyUnicode_AsUTF8()` | UTF-8 encoding |

**Implementation Details:**
```swift
// Swift → Python (generic for StringProtocol)
extension PySerialize where Self: StringProtocol {
    func pyPointer() -> PyPointer {
        withCString(PyUnicode_FromString)!
    }
}

// Python → Swift
extension String: PyDeserialize {
    static func casted(from object: PyPointer) throws -> String {
        guard PyObject_TypeCheck(object, .PyUnicode) else { 
            throw PyStandardException.unicodeError 
        }
        return String(cString: PyUnicode_AsUTF8(object))
    }
}
```

### 6. Collection Types - Arrays/Lists

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Array<Element>` where `Element: PySerialize` | `list` | `PyList_New()` + direct memory write | `PyList` iteration + element conversion | Optimized for performance |

**Implementation Details:**
```swift
// Swift → Python (optimized with direct memory access)
extension PySerialize where Self: Collection, Self.Element: PySerialize {
    func pyPointer() -> PyPointer {
        let py_list = PyList_New(count)!
        py_list.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let ob_item = pointer.pointee.ob_item
            _ = self.reduce(ob_item) { partialResult, next in
                partialResult?.pointee = next.pyPointer()
                return partialResult?.advanced(by: 1)
            }
        }
        return py_list
    }
}

// Python → Swift
extension Array: PyDeserialize where Element: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Array<Element> {
        guard PyObject_TypeCheck(object, .PyList) else { 
            throw PyStandardException.typeError 
        }
        return try object.map { element in
            guard let element else { throw PyStandardException.indexError }
            return try Element.casted(from: element)
        }
    }
}
```

**Examples:**
- `[Int]` ↔ `list[int]`
- `[String]` ↔ `list[str]`
- `[Double]` ↔ `list[float]`
- `[[Int]]` ↔ `list[list[int]]` (nested arrays)

### 7. Collection Types - Sets

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Set<Element>` where `Element: PySerialize & Hashable` | `set` | `PySet_New()` + `PySet_Add()` | Iterator-based | Elements must be hashable |

**Implementation Details:**
```swift
// Swift → Python
extension Set: PySerialize where Element: PySerialize {
    func pyPointer() -> PyPointer {
        let pyset = PySet_New(nil)!
        for element in self {
            PySet_Add(pyset, element.pyPointer())
        }
        return pyset
    }
}

// Python → Swift
extension Set: PyDeserialize where Element: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Set<Element> {
        guard PyObject_TypeCheck(object, .PySet) else { 
            throw PyStandardException.typeError 
        }
        let iter = PyObject_GetIter(object)
        var set = Set<Element>()
        while let next = PyIter_Next(iter) {
            set.insert(try Element.casted(from: next))
        }
        return set
    }
}
```

**Examples:**
- `Set<Int>` ↔ `set[int]`
- `Set<String>` ↔ `set[str]`

### 8. Collection Types - Dictionaries

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Dictionary<Key, Value>` where `Key: PySerialize & Hashable, Value: PySerialize` | `dict` | `PyDict_New()` + `PyDict_SetItem()` | `PyDict_Next()` iteration | Both keys and values converted |
| `Dictionary<Key, PyPointer>` where `Key: PySerialize & Hashable` | `dict` | `PyDict_New()` + `PyDict_SetItem()` | `PyDict_Next()` iteration | Values are raw Python objects |

**Implementation Details:**
```swift
// Swift → Python
extension Dictionary: PySerialize 
    where Key: PySerialize & Hashable, Value: PySerialize {
    func pyPointer() -> PyPointer {
        let pydict = PyDict_New()!
        for (k, v) in self {
            let py_key = k.pyPointer()
            let py_value = v.pyPointer()
            PyDict_SetItem(pydict, py_key, py_value)
            Py_DecRef(py_key)
            Py_DecRef(py_value)
        }
        return pydict
    }
}

// Python → Swift
extension Dictionary: PyDeserialize 
    where Key: PyDeserialize, Value: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Dictionary<Key, Value> {
        guard PyObject_TypeCheck(object, .PyDict) else { 
            throw PyStandardException.typeError 
        }
        var d: [Key: Value] = .init()
        var pos: Int = 0
        var key: PyPointer?
        var value: PyPointer?
        while PyDict_Next(object, &pos, &key, &value) == 1 {
            guard let key, let value else { throw PyStandardException.keyError }
            d[try Key.casted(from: key)] = try Value.casted(from: value)
        }
        return d
    }
}
```

**Examples:**
- `[String: Int]` ↔ `dict[str, int]`
- `[String: Any]` ↔ `dict[str, Any]` (using PyPointer for values)
- `[Int: [String]]` ↔ `dict[int, list[str]]` (nested collections)

### 9. Binary Data Types

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Data` | `bytes` | `PyMemoryView_FromBuffer()` + `PyBytes_FromObject()` | Multiple format support | Uses Python buffer protocol |
| `Data` | `bytearray` | `PyMemoryView_FromBuffer()` + `PyBytes_FromObject()` | Multiple format support | Uses Python buffer protocol |
| `Data` | `memoryview` | `PyMemoryView_FromBuffer()` + `PyBytes_FromObject()` | Multiple format support | Uses Python buffer protocol |

**Implementation Details:**
```swift
// Swift → Python (using buffer protocol)
extension Data: PySerialize {
    func pyPointer() -> PyPointer {
        var data = self
        var element_size = MemoryLayout<UInt8>.size
        var size = self.count
        return data.withUnsafeMutableBytes { raw in
            var buffer = Py_buffer()
            buffer.buf = raw.baseAddress
            buffer.len = size
            buffer.readonly = 0
            buffer.itemsize = element_size
            buffer.format = .ubyte_format
            buffer.ndim = 1
            buffer.shape = .init(&size)
            buffer.strides = .init(&element_size)
            buffer.suboffsets = nil
            buffer.internal = nil
            
            let mem = PyMemoryView_FromBuffer(&buffer)
            let bytes = PyBytes_FromObject(mem) ?? .None
            Py_DecRef(mem)
            return bytes
        }
    }
}

// Python → Swift (supports bytes, bytearray, memoryview)
extension Data: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Data {
        switch object {
        case .PyMemoryView:
            let data_size = PyObject_Size(object)
            let py_buf = PyMemoryView_GET_BUFFER(object)
            defer { PyBuffer_Release(py_buf) }
            var indices = [0]
            guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) 
                else { throw PyStandardException.memoryError }
            let uint8_pointer = buf_ptr.assumingMemoryBound(to: UInt8.self)
            return Data(UnsafeMutableBufferPointer(
                start: uint8_pointer, 
                count: data_size
            ))
        case .PyBytes:
            return try Self.fromBytes(bytes: object)
        case .PyByteArray:
            return try Self.fromByteArray(bytes: object)
        default: 
            throw PyStandardException.typeError
        }
    }
}
```

### 10. Optional Types

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Optional<Wrapped>` where `Wrapped: PySerialize` | `None` or value type | Returns `__Py_None__` or wrapped value | Checks for `__Py_None__` | Swift nil ↔ Python None |

**Implementation Details:**
```swift
// Swift → Python
extension Optional: PySerialize where Wrapped: PySerialize {
    func pyPointer() -> PyPointer {
        if let self {
            return self.pyPointer()
        } else {
            return __Py_None__
        }
    }
}

// Python → Swift
extension Optional: PyDeserialize where Wrapped: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self {
        if object == __Py_None__ {
            return nil
        } else {
            return try Wrapped.casted(from: object)
        }
    }
}
```

**Examples:**
- `Int?` ↔ `Optional[int]` / `int | None`
- `String?` ↔ `Optional[str]` / `str | None`
- `[Int]?` ↔ `Optional[list[int]]` / `list[int] | None`

### 11. Range Types

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Range<Int>` | `range` | `PyRange_new(start, stop)` | Not implemented | Half-open range (excludes end) |
| `ClosedRange<Int>` | `range` | `PyRange_new(start, stop)` | Not implemented | Closed range (includes end) |

**Implementation Details:**
```swift
// Swift → Python (half-open range)
extension Range: PySerialize where Bound == Int {
    func pyPointer() -> PyPointer {
        (try? PyRange_new(start: lowerBound, stop: upperBound))!
    }
}

// Swift → Python (closed range)
extension ClosedRange: PySerialize where Bound == Int {
    func pyPointer() -> PyPointer {
        (try? PyRange_new(start: lowerBound, stop: upperBound))!
    }
}
```

**Examples:**
- `0..<10` → `range(0, 10)`
- `0...10` → `range(0, 10)`

### 12. Date and Time Types

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `Date` | `datetime.datetime` | `PyDateTime_Create()` with components | `PyDateTime_Info()` + Calendar | Foundation Date ↔ Python datetime |
| `DateComponents` | `datetime.datetime` | Not implemented | `PyDateTime_Info()` extraction | Component-wise conversion |
| `Date` | `float` | Not implemented | `timeIntervalSince1970` | Unix timestamp |
| `Date` | `str` | Not implemented | `ISO8601DateFormatter` | ISO 8601 format |

**Implementation Details:**
```swift
// Swift → Python
extension Date: PySerialize {
    func pyPointer() -> PyPointer {
        initPyDateTime()  // Initialize datetime module
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond], 
            from: self
        )
        let microsecond = (components.nanosecond ?? 0) / 1000
        return PyDateTime_Create(
            Int32(components.year ?? 0),
            Int32(components.month ?? 1),
            Int32(components.day ?? 0),
            Int32(components.hour ?? 0),
            Int32(components.minute ?? 0),
            Int32(components.second ?? 0),
            Int32(microsecond)
        )
    }
}

// Python → Swift (supports datetime, float, str)
extension Date: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Date {
        switch object {
        case .PyDateTime:
            let calendar = Calendar.current
            let components = try DateComponents.casted(unsafe: object)
            return calendar.date(from: components)!
        case .PyFloat:
            return Date(timeIntervalSince1970: try Double.casted(unsafe: object))
        case .PyUnicode:
            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(
                from: try String.casted(unsafe: object)
            ) else {
                throw PyStandardException.unicodeError
            }
            return date
        default: 
            throw PyStandardException.typeError
        }
    }
}
```

### 13. URL Types

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `URL` | `str` | `path` property as string | `URL(string:)` from string | File paths and URLs as strings |

**Implementation Details:**
```swift
// Swift → Python
extension URL: PySerialize {
    func pyPointer() -> PyPointer {
        path.pyPointer()
    }
}

// Python → Swift
extension URL: PyDeserialize {
    static func casted(from object: PyPointer) throws -> URL {
        guard let url = URL(string: try String.casted(from: object)) 
            else { throw URLError(.badURL) }
        return url
    }
}
```

### 14. RawRepresentable Types (Enums)

| Swift Type | Python Type | PySerialize Method | PyDeserialize Method | Notes |
|------------|-------------|-------------------|---------------------|-------|
| `RawRepresentable` where `RawValue: PySerialize` | Type of raw value | Serializes raw value | Deserializes raw value + creates enum | Swift enums with raw values |

**Implementation Details:**
```swift
// Swift → Python
extension RawRepresentable where RawValue: PySerialize {
    func pyPointer() -> PyPointer {
        rawValue.pyPointer()
    }
}

// Python → Swift
extension PyDeserialize where Self: RawRepresentable, RawValue: PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self {
        guard let representable = Self(
            rawValue: try RawValue.casted(from: object)
        ) else { 
            throw PyStandardException.typeError 
        }
        return representable
    }
}
```

**Example:**
```swift
enum Status: String, PySerialize, PyDeserialize {
    case active
    case inactive
    case pending
}

// Status.active ↔ "active" (Python str)
```

### 15. PyPointer (Raw Python Objects)

| Swift Type | Python Type | Notes |
|------------|-------------|-------|
| `PyPointer` | Any Python object | Direct access to Python C API pointers, no conversion |

**Usage:**
```swift
// PyPointer can be used directly in function signatures for maximum flexibility
@PyMethod
func processRaw(_ obj: PyPointer) -> PyPointer {
    // Direct Python C API calls
    return obj
}
```

## Protocol Implementations Summary

### PySerialize Conforming Types
- ✅ `Int`, `Int64`, `Int32`, `Int16`, `Int8`
- ✅ `UInt`, `UInt64`, `UInt32`, `UInt16`, `UInt8`
- ✅ `Double`, `Float`, `Float16` (iOS 16+), `CGFloat`
- ✅ `Bool`
- ✅ `String`, `Substring`
- ✅ `Array<Element>` where `Element: PySerialize`
- ✅ `Set<Element>` where `Element: PySerialize`
- ✅ `Dictionary<Key, Value>` where `Key: PySerialize & Hashable, Value: PySerialize`
- ✅ `Data`
- ✅ `Optional<Wrapped>` where `Wrapped: PySerialize`
- ✅ `Range<Int>`, `ClosedRange<Int>`
- ✅ `Date`
- ✅ `URL`
- ✅ `RawRepresentable` where `RawValue: PySerialize`

### PyDeserialize Conforming Types
- ✅ `Int`, `Int64`, `Int32`, `Int16`, `Int8`
- ✅ `UInt`, `UInt64`, `UInt32`, `UInt16`, `UInt8`
- ✅ `Double`, `Float`, `Float16` (iOS 16+), `CGFloat`
- ✅ `Bool`
- ✅ `String`, `Substring`
- ✅ `Array<Element>` where `Element: PyDeserialize`
- ✅ `Set<Element>` where `Element: PyDeserialize`
- ✅ `Dictionary<Key, Value>` where `Key: PyDeserialize, Value: PyDeserialize`
- ✅ `Data`
- ✅ `Optional<Wrapped>` where `Wrapped: PyDeserialize`
- ✅ `Date`, `DateComponents`
- ✅ `URL`
- ✅ `RawRepresentable` where `RawValue: PyDeserialize`

## Error Handling

All `PyDeserialize.casted(from:)` methods can throw the following exceptions:

| Exception | Condition |
|-----------|-----------|
| `PyStandardException.typeError` | Python object type doesn't match expected Swift type |
| `PyStandardException.indexError` | Array/list index out of bounds |
| `PyStandardException.keyError` | Dictionary key not found |
| `PyStandardException.unicodeError` | String encoding/decoding error |
| `PyStandardException.memoryError` | Memory allocation or buffer error |
| `PyStandardException.bufferError` | Python buffer protocol error |
| `PyStandardException.attributeError` | Attribute not found on object |
| `URLError(.badURL)` | Invalid URL string |

## Safe vs Unsafe Casting

PySwiftKit provides two deserialization methods:

### `casted(from:)` - Safe Casting
- Performs type checking using `PyObject_TypeCheck()`
- Throws `PyStandardException.typeError` if type is incorrect
- Recommended for user input or untrusted data

```swift
let value = try Int.casted(from: pythonObject)  // Type-safe
```

### `casted(unsafe:)` - Unsafe Casting
- Skips type checking for performance
- Assumes the Python object is the correct type
- Use only when you're certain of the Python object's type
- Faster but can cause crashes if type is wrong

```swift
let value = try Int.casted(unsafe: pythonObject)  // Fast but risky
```

## Helper Functions

PySwiftKit provides convenience functions for common operations:

### Setting Attributes/Items
```swift
// Set object attribute
PyObject_SetAttr(pyObject, key: "name", value: "John")

// Set dictionary item
try PyDict_SetItem(pyDict, key: "age", value: 30)

// Set tuple item
try PyTuple_SetItem(pyTuple, index: 0, value: "hello")
```

### Getting Attributes/Items
```swift
// Get object attribute (type inferred)
let name: String = try PyObject_GetAttr(pyObject, key: "name")

// Get dictionary item
let age: Int = try PyDict_GetItem(pyDict, key: "age")

// Get tuple item
let item: String = try PyTuple_GetItem(pyTuple, index: 0)
```

## Usage Examples

### Example 1: Function with Automatic Conversions
```swift
@PyClass
class Calculator {
    @PyMethod
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
    
    @PyMethod
    func processArray(_ numbers: [Double]) -> [Double] {
        return numbers.map { $0 * 2 }
    }
}
```

```python
calc = Calculator()
result = calc.add(5, 3)  # int automatically converted
doubles = calc.process_array([1.5, 2.5, 3.5])  # list[float] converted
```

### Example 2: Working with Dictionaries
```swift
@PyMethod
func getUserInfo() -> [String: String] {
    return [
        "name": "Alice",
        "email": "alice@example.com",
        "role": "admin"
    ]
}

@PyMethod
func processConfig(_ config: [String: Int]) {
    for (key, value) in config {
        print("\(key): \(value)")
    }
}
```

```python
info = obj.get_user_info()  # Returns dict[str, str]
obj.process_config({"timeout": 30, "retries": 3})  # dict[str, int]
```

### Example 3: Optional Values
```swift
@PyMethod
func findUser(id: Int) -> String? {
    return database.users[id]?.name
}

@PyMethod
func setOptionalValue(_ value: Int?) {
    if let value = value {
        print("Value: \(value)")
    } else {
        print("No value provided")
    }
}
```

```python
name = obj.find_user(123)  # Returns str or None
obj.set_optional_value(42)   # Pass int
obj.set_optional_value(None) # Pass None
```

### Example 4: Complex Nested Types
```swift
@PyMethod
func getStatistics() -> [String: [String: Double]] {
    return [
        "user1": ["score": 95.5, "time": 120.0],
        "user2": ["score": 87.0, "time": 135.5]
    ]
}
```

```python
stats = obj.get_statistics()
# Returns: dict[str, dict[str, float]]
print(stats["user1"]["score"])  # 95.5
```

### Example 5: Working with Data
```swift
@PyMethod
func loadImage() -> Data {
    return imageData
}

@PyMethod
func processBytes(_ data: Data) {
    print("Received \(data.count) bytes")
}
```

```python
image_data = obj.load_image()  # Returns bytes
obj.process_bytes(b"Hello, World!")  # Pass bytes
```

## Performance Considerations

### Optimized Types
- **Integers/Floats**: Direct C API calls, minimal overhead
- **Strings**: Single UTF-8 conversion
- **Arrays**: Direct memory access via `PyListObject`, very fast
- **Dictionaries**: Iterator-based, efficient for large collections

### Memory Management
- All `pyPointer()` calls return **new references** (reference count +1)
- Caller is responsible for calling `Py_DecRef()` when done
- Generated `@PyMethod` wrappers handle reference counting automatically
- Helper functions like `PyObject_SetAttr` manage references internally

### Best Practices
1. Use `Array<T>` instead of individual element conversions for collections
2. Use `PyPointer` directly when no conversion is needed
3. Prefer `casted(unsafe:)` in performance-critical code when type is guaranteed
4. Batch operations when possible to minimize GIL acquisitions

## Extending Type Conversions

To add support for custom types, implement the protocols:

```swift
struct MyCustomType: PySerialize, PyDeserialize {
    var value: Int
    
    // Swift → Python
    func pyPointer() -> PyPointer {
        // Convert to Python representation
        return value.pyPointer()
    }
    
    // Python → Swift
    static func casted(from object: PyPointer) throws -> Self {
        let value = try Int.casted(from: object)
        return MyCustomType(value: value)
    }
    
    static func casted(unsafe object: PyPointer) throws -> Self {
        let value = try Int.casted(unsafe: object)
        return MyCustomType(value: value)
    }
}
```

## Python C API Reference

For implementation details, PySwiftKit uses these Python C API functions:

### Integer Functions
- `PyLong_FromLong()`, `PyLong_FromLongLong()`, `PyLong_FromUnsignedLong()`
- `PyLong_AsLong()`, `PyLong_AsLongLong()`, `PyLong_AsUnsignedLong()`

### Float Functions
- `PyFloat_FromDouble()`, `PyFloat_AS_DOUBLE()`

### String Functions
- `PyUnicode_FromString()`, `PyUnicode_AsUTF8()`

### Collection Functions
- `PyList_New()`, `PySet_New()`, `PyDict_New()`
- `PyList_Append()`, `PySet_Add()`, `PyDict_SetItem()`
- `PyDict_Next()`, `PyObject_GetIter()`, `PyIter_Next()`

### Buffer Protocol
- `PyMemoryView_FromBuffer()`, `PyMemoryView_GET_BUFFER()`
- `PyBuffer_GetPointer()`, `PyBuffer_Release()`
- `PyBytes_FromObject()`, `PyByteArray_Size()`

### Type Checking
- `PyObject_TypeCheck()` - Validates Python object type

### DateTime Functions
- `PyDateTime_Create()`, `PyDateTime_Info()`

## Additional Notes

1. **Thread Safety**: All conversions require the GIL (Global Interpreter Lock) to be held. Use `withGIL {}` blocks when calling conversion methods.

2. **Reference Counting**: PySwiftKit follows Python's reference counting model. All `pyPointer()` calls return new references that must be decremented with `Py_DecRef()`.

3. **Platform Availability**: Some types like `Float16` are only available on specific platforms (iOS 16+, macOS 11+).

4. **CoreFoundation**: Types like `CGFloat` require CoreFoundation framework import.

5. **Generic Protocols**: Many protocol extensions use Swift generics to provide automatic conversion for all conforming types (e.g., all `SignedInteger` types).

---

**Version**: PySwiftKit 313.1.2+
**Last Updated**: December 2025
**Python Version**: 3.13+
**Swift Version**: 5.0+ (Swift 6.0 tools)

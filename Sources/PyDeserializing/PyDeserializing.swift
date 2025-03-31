import PythonCore
import PySwiftCore
import Foundation


public protocol PyDeserialize {
    init(object: PyPointer) throws
}


public extension PyDeserialize {
    init(consuming object: PyPointer) throws {
        try self.init(object: object)
        _Py_DecRef(object)
    }
    
    init(object: PyPointer?) throws {
        guard object != PyNone else { throw PythonError.type("NoneType is not allowed")}
        try self.init(object: object)
    }
    
    init?(optional object: PyPointer?) throws {
        guard let object, object != PyNone else { return nil }
        try self.init(object: object)
    }
}

@inlinable public func PyObject_GetAttr<T>(_ o: PyPointer, _ key: String) throws -> T where T: PyDeserialize {
    try key.withCString { string in
        let value = PyObject_GetAttrString(o, string)
        defer { Py_DecRef(value) }
        return try T(object: value)
    }
}

@inlinable public func PyObject_GetAttr<T>(_ o: PyPointer, _ key: CodingKey) throws -> T where T: PyDeserialize {
    try key.stringValue.withCString { string in
        let value = PyObject_GetAttrString(o, string)
        defer { Py_DecRef(value) }
        return try T(object: value)
    }
}

import PythonCore
import PySwiftKit
import Foundation


public protocol PyDeserialize {
    init(object: PyPointer) throws
    static func casted(from object: PyPointer) throws -> Self
}


public extension PyDeserialize {
    
    init(object: PyPointer) throws {
        fatalError("\(Self.self)(object: PyPointer) not implemented")
    }
    
    static func casted(from object: PyPointer) throws -> Self {
        try Self(object: object)
    }
    
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

extension PyDeserialize where Self: AnyObject {
    public static func casted(from object: PyPointer) throws -> Self {
        guard
            let pointee = unsafeBitCast(object, to: PySwiftObjectPointer.self)?.pointee
        else { throw PyStandardException.typeError }
        
        return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
    }
}

extension Optional: PyDeserialize where Wrapped: PyDeserialize {
    public init(object: PythonCore.PyPointer) throws {
        self = if object == PyNone {
            nil
        } else {
            try Wrapped(object: object)
        }
    }
    public static func casted(from object: PyPointer) throws -> Optional<Wrapped> {
        if object == PyNone {
            nil
        } else {
            try Wrapped.casted(from: object)
        }
    }
}


@inlinable public func PyObject_GetAttr<T>(_ o: PyPointer, _ key: String) throws -> T where T: PyDeserialize {
    try key.withCString { string in
        let value = PyObject_GetAttrString(o, string)
        defer { Py_DecRef(value) }
        return try T(object: value)
    }
}

@inlinable public func PyObject_GetAttr<T>(_ o: PyPointer, _ key: String) throws -> T where T: PyDeserialize & AnyObject {
    try key.withCString { string in
        guard let value = PyObject_GetAttrString(o, string) else { throw PyStandardException.typeError }
        defer { Py_DecRef(value) }
        return try T.casted(from: value)
    }
}

@inlinable public func PyObject_GetAttr<T>(_ o: PyPointer, _ key: CodingKey) throws -> T where T: PyDeserialize {
    try key.stringValue.withCString { string in
        let value = PyObject_GetAttrString(o, string)
        defer { Py_DecRef(value) }
        return try T(object: value)
    }
}


public struct PyCast<T: PyDeserialize> {
    public static func cast(from object: PyPointer) throws -> T {
        try T(object: object)
    }
    
    public static func cast(from object: PyPointer) throws -> T where T: AnyObject {
        try .casted(from: object)
    }
}


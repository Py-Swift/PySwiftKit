import PythonCore
import PySwiftCore
import Foundation


public protocol PyDeserialize {
    init(object: PyPointer) throws
    static func casted(from object: PyPointer) throws -> Self
}


public extension PyDeserialize {
    
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
            object != PyNone,
            let pointee = unsafeBitCast(object, to: PySwiftObjectPointer.self)?.pointee
        else { throw PyStandardException.typeError }
        
        return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
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

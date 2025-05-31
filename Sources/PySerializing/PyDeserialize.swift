import PythonCore
import PySwiftKit
import Foundation


public protocol PyDeserialize {
    init(object: PyPointer) throws
    static func casted(from object: PyPointer) throws -> Self
}

public typealias PyDeserializeObject = PyDeserialize & AnyObject

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
        guard object != PySwiftKit.Py_None else { throw PythonError.type("NoneType is not allowed")}
        try self.init(object: object)
    }
    
    init?(optional object: PyPointer?) throws {
        guard let object, object != PySwiftKit.Py_None else { return nil }
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
    
    
    @_disfavoredOverload
    public init(object: PyPointer) throws {
        self = if object == PySwiftKit.Py_None {
            nil
        } else {
            try Wrapped(object: object)
        }
    }
    
    public init(object: PyPointer) throws where Wrapped: AnyObject {
        self = if object == PySwiftKit.Py_None {
            nil
        } else {
            try Wrapped.casted(from: object)
        }
    }
    
    public static func casted(from object: PyPointer) throws -> Optional<Wrapped> {
        if object == PySwiftKit.Py_None {
            nil
        } else {
            try Wrapped.casted(from: object)
        }
    }
}

extension Optional where Wrapped: PyDeserializeObject {
    
//    public init(object: PyPointer) throws {
//        self = if object == PySwiftKit.Py_None {
//            nil
//        } else {
//            try Wrapped.casted(from: object)
//        }
//    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        if object == PySwiftKit.Py_None {
            nil
        } else {
            try Wrapped.casted(from: object)
        }
    }
}

//extension Optional where Wrapped: PyDeserializeObject {
////    public init(object: PythonCore.PyPointer) throws  {
////        self = if object == PyNone {
////            nil
////        } else {
////            try Wrapped.casted(from: object)
////        }
////    }
//}


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

@_disfavoredOverload
@inlinable public func PyTuple_GetItem<T: PyDeserialize>(_ o: PyPointer, index: Int) throws -> T {
    guard let result = Python.PyTuple_GetItem(o, index) else {
        PyErr_Print()
        throw PyStandardException.indexError
    }
    return try T(object: result)
}

@inlinable public func PyTuple_GetItem<T: PyDeserialize>(_ o: PyPointer, index: Int) throws -> T where T: AnyObject {
    guard let result = Python.PyTuple_GetItem(o, index) else {
        PyErr_Print()
        throw PyStandardException.indexError
    }
    return try T.casted(from: result)
}


//@_disfavoredOverload
@inlinable public func _PyTuple_GetItem<T: PyDeserialize>(_ o: PyPointer, index: Int) throws -> T? {
    guard let result = Python.PyTuple_GetItem(o, index) else {
        PyErr_Print()
        throw PyStandardException.indexError
    }
    return try T(object: result)
}
//@inlinable public func PyTuple_GetItem<T: PyDeserializeObject>(_ o: PyPointer, index: Int) throws -> T {
//    guard let result = Python.PyTuple_GetItem(o, index) else {
//        PyErr_Print()
//        throw PyStandardException.indexError
//    }
//    return try T.casted(from: result)
//}

public struct PyCast<T: PyDeserialize> {
    
   
    
    public static func cast(from object: PyPointer) throws -> T where T: AnyObject {
        try .casted(from: object)
    }
    
    @_disfavoredOverload
    public static func cast(from object: PyPointer) throws -> T {
        try T(object: object)
    }
    
    
    public static func cast(from object: PyPointer) throws -> T? {
        try T(object: object)
    }
    
    public static func cast<O: PyDeserialize & AnyObject>(from object: PyPointer) throws -> T where T == Optional<O> {
        try .casted(from: object)
    }
}




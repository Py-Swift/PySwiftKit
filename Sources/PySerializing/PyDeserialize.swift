//
//  PyDeserialize.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 23/10/2025.
//
import CPython
import PySwiftKit


public protocol PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self
    static func casted(unsafe object: PyPointer) throws -> Self
}

extension PyDeserialize {
    public static func consumedCast(from object: PyPointer) throws -> Self {
        let cast = try Self.casted(from: object)
        Py_DecRef(object)
        return cast
    }
    
    public static func consumedCast(unsafe object: PyPointer) throws -> Self {
        let cast = try Self.casted(unsafe: object)
        Py_DecRef(object)
        return cast
    }
}

public func PyTuple_GetItem<T>(_ tuple: PyPointer, index: Int) throws -> T where T: PyDeserialize {
    guard let result = PyTuple_GetItem(tuple, index) else {
        PyErr_Print()
        throw PyStandardException.indexError
    }
    
    return try T.casted(from: result)
}

public func PyDict_GetItem<T>(_ dict: PyPointer, key: String) throws -> T where T: PyDeserialize {
    guard let result = key.withCString({PyDict_GetItemString(dict, $0)}) else {
        PyErr_Print()
        throw PyStandardException.keyError
    }
    defer { Py_DecRef(result) }
    return try T.casted(from: result)
}

public func PyObject_GetAttr<T>(_ object: PyPointer, key: String) throws -> T where T: PyDeserialize {
    guard let result = key.withCString({PyObject_GetAttrString(object, $0)}) else {
        PyErr_Print()
        throw PyStandardException.attributeError
    }
    defer { Py_DecRef(result)}
    return try T.casted(from: result)
}

//extension PyDeserialize where Self: RawRepresentable, Self.RawValue: PyDeserialize {
//    public init(object: PyPointer) throws {
//        //guard let raw = Self(rawValue: try RawValue(object: object)) else {
//        guard let raw = Self(rawValue: try RawValue.casted(from: object)) else {
//            //throw PythonError.type("\(RawValue.self)")
//            throw PyStandardException.keyError
//        }
//        self = raw
//    }
//}

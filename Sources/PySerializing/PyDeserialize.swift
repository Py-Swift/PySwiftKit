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

public func PyTuple_GetItem<T>(_ tuple: PyPointer, index: Int) throws -> T where T: PyDeserialize {
    guard let result = PyTuple_GetItem(tuple, index) else {
        PyErr_Print()
        fatalError()
    }
    defer {
        Py_DecRef(result)
    }
    return try T.casted(from: result)
}

public func PyDict_GetItem<T>(_ dict: PyPointer, key: String) throws -> T where T: PyDeserialize {
    guard let result = key.withCString({PyDict_GetItemString(dict, $0)}) else {
        PyErr_Print()
        fatalError()
    }
    defer { Py_DecRef(result) }
    return try T.casted(from: result)
}

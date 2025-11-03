//
//  PyAttr.swift
//  PySwiftKit
//
import CPython

public func PyObject_GetAttr(_ object: PyPointer, key: String) throws -> PyPointer {
    if let result = key.withCString({PyObject_GetAttrString(object, $0)}) {
        return result
    } else {
        PyErr_Print()
        throw PyStandardException.keyError
    }
}

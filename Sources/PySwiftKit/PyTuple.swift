
//
//  PyTuple.swift
//  PySwiftKit
//

import CPython


public func PyTuple_GetItem(_ tuple: PyPointer, index: Int) throws -> PyPointer {
    guard let result = PyTuple_GetItem(tuple, index) else {
        PyErr_Print()
        throw PyStandardException.indexError
    }
    return result
}

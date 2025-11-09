//
//  PyPointer.swift
//  PySwiftKit
//

import CPython

public extension PyPointer {
    static var None: Self { __Py_None__ }
    static var True: Self { __Py_True__ }
    static var False: Self { __Py_False__ }
}


//
//  PyObject.swift
//  PySwiftKit
//
import CPython




public struct PythonObject: ~Copyable {
    
    private let ptr: PyPointer
    
    init(_ ptr: PyPointer) {
        self.ptr = Py_NewRef(ptr)
    }
    
    deinit {
        Py_DecRef(ptr)
    }
}


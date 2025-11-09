//
//  PySerialize+Bool.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Bool: PySerialize {
    public func pyPointer() -> PyPointer {
        self ? __Py_True__ : __Py_False__
    }
}





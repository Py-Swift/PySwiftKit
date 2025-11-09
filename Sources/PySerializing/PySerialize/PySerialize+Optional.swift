//
//  PySerialize+Optional.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Optional: PySerialize where Wrapped: PySerialize {
    public func pyPointer() -> PyPointer {
        if let self {
            self.pyPointer()
        } else {
            __Py_None__
        }
    }
}







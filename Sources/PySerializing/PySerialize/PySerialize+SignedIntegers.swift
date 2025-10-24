//
//  PySerialize+SignedIntegers.swift
//  PySwiftKit
//
import CPython
import PySwiftKit


extension PySerialize where Self: SignedInteger {
    public func pyPointer() -> PyPointer {
        PyLong_FromLong(.init(self))
    }
}

extension Int: PySerialize {
    public func pyPointer() -> PyPointer {
        PyLong_FromLong(self)
    }
}

extension Int64: PySerialize {
    public func pyPointer() -> PyPointer {
        PyLong_FromLongLong(self)
    }
}

extension Int32: PySerialize {}

extension Int16: PySerialize {}

extension Int8: PySerialize {}

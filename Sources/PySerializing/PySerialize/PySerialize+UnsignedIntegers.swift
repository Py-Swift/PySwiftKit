//
//  PySerialize+UnsignedIntegers.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension PySerialize where Self: UnsignedInteger {
    public func pyPointer() -> PyPointer {
        PyLong_FromUnsignedLong(.init(self))
    }
}

extension UInt: PySerialize {
    public func pyPointer() -> PyPointer {
        PyLong_FromUnsignedLong(self)
    }
}

extension UInt64: PySerialize {
    public func pyPointer() -> PyPointer {
        PyLong_FromUnsignedLongLong(self)
    }
}

extension UInt32: PySerialize {}

extension UInt16: PySerialize {}

extension UInt8: PySerialize {}

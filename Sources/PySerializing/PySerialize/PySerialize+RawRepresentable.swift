//
//  PySerialize+RawRepresentable.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension RawRepresentable where Self.RawValue: PySerialize {
    public func pyPointer() -> PyPointer {
        rawValue.pyPointer()
    }
}

extension PySerialize where Self: RawRepresentable, Self.RawValue: PySerialize {
    public func pyPointer() -> PyPointer {
        rawValue.pyPointer()
    }
}

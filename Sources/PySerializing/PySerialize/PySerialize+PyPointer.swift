//
//  PySerialize+PyPointer.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension PyPointer: PySerialize {
    public func pyPointer() -> PyPointer {
        self
    }
}


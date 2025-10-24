//
//  PySerialize+Strings.swift
//  PySwiftKit
//
import CPython
import PySwiftKit
import Foundation

public extension PySerialize where Self: StringProtocol {
    func pyPointer() -> PyPointer {
        withCString(PyUnicode_FromString)!
    }
}

extension String: PySerialize {}


extension DefaultStringInterpolation: PySerialize {
    public func pyPointer() -> PyPointer {
        //description.withCString(PyUnicode_FromString)!
        fatalError()
    }
}

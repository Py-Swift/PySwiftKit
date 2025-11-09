//
//  PySerialize+URL.swift
//  PySwiftKit
//

import CPython
import PySwiftKit
import Foundation

extension URL: PySerialize {
    public func pyPointer() -> PyPointer {
        path.pyPointer()
    }
}


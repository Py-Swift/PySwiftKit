//
//  PyMutableMappingProtocol.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 19/02/2026.
//


public protocol PyMutableMappingProtocol: PyMappingProtocol {
	func __setitem__(_ key: PyPointer, _ item: PyPointer?) -> Int32
    func __setitem__(_ key: PyPointer, _ item: PyPointer) -> Int32
    func __delitem__(_ key: PyPointer) -> Int32
}

extension PyMutableMappingProtocol {
    public func __setitem__(_ key: PyPointer, _ item: PyPointer?) -> Int32 {
        if let item {
            __setitem__(key, item)
        } else {
            __delitem__(key)
        }
    }
}

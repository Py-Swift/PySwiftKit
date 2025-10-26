//
//  PyClassProtocol.swift
//  PySwiftKit
//

import CPython

public protocol PyClassProtocol {
    
    static var PyType: UnsafeMutablePointer<_typeobject> { get }
}

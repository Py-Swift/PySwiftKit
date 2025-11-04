//
//  PyClassProtocol.swift
//  PySwiftKit
//

import CPython

public protocol PyClassProtocol {
    static var pyTypeObject: _typeobject { get set }
    static var PyType: UnsafeMutablePointer<_typeobject> { get }
}

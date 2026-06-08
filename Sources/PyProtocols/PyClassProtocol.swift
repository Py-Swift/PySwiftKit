//
//  PyClassProtocol.swift
//  PySwiftKit
//

//import CPython
import CPython

public protocol PyClassProtocol: AnyObject {
    static var pyTypeObject: _typeobject { get set }
    static var PyType: UnsafeMutablePointer<_typeobject> { get }
}

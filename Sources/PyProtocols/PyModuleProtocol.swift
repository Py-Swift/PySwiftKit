//
//  PyModuleProtocol.swift
//  PySwiftKit
//

import CPython


public protocol PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [(PyModuleProtocol).Type] { get }
    
    associatedtype PySerializableType
    
    static var pyserializableTypes: [(PySerializableType.Type, String)] { get }
    
}

public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [(PyModuleProtocol).Type] { [] }
    static var pyserializableTypes: [(PySerializableType.Type, String)] { [] }
}

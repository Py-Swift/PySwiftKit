//
//  PyModuleProtocol.swift
//  PySwiftKit
//

import CPython


public protocol PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [PyModuleProtocol] { get }
}

public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [PyModuleProtocol] { [] }
}

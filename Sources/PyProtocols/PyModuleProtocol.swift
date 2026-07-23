//
//  PyModuleProtocol.swift
//  PySwiftKit
//

import CPython

public protocol PyModuleEntry {
    static func getSubmodules(parent_name: String) -> [any PyModuleEntry]
}



public protocol PyModuleProtocol: PyModuleEntry {
    static var py_name: String { get }
    static var py_init: @convention(c) () -> UnsafeMutablePointer<PyObject>? { get }
    
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [(PyModuleProtocol).Type] { get }
    
    associatedtype PySerializableType
    
    static var pyserializableTypes: [(PySerializableType.Type, String)] { get }
    
}


public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [(PyModuleProtocol).Type] { [] }
    static var pyserializableTypes: [(PySerializableType.Type, String)] { [] }
    
    static func getSubmodules(parent_name: String) -> [any PyModuleEntry] {
        let child_name = "\(parent_name).\(py_name)"
        modules.flatMap { mod in
            mod.getSubmodules(parent_name: child_name)
        }
        
        return []
    }
    
    
}

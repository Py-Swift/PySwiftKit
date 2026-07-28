//
//  PyModuleProtocol.swift
//  PySwiftKit
//

import CPython

public protocol PyModuleEntry {
    #if !PIP_MODE
    static func getSubmodules(parent_name: String) -> [any PyModuleEntry]
    #endif
}



public protocol PyModuleProtocol: PyModuleEntry, Sendable {
    #if !PIP_MODE
    static var py_name: String { get }
    
    static var py_init: @convention(c) () -> UnsafeMutablePointer<PyObject>? { get }
    #endif
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [(any PyModuleProtocol).Type] { get }
    
    associatedtype PySerializableType
    
    static var pyserializableTypes: [(PySerializableType.Type, String)] { get }
    
}


public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [(any PyModuleProtocol).Type] { [] }
    static var pyserializableTypes: [(PySerializableType.Type, String)] { [] }
    #if !PIP_MODE
    static func getSubmodules(parent_name: String) -> [any PyModuleEntry] {
        let child_name = "\(parent_name).\(py_name)"
        modules.flatMap { mod in
            mod.getSubmodules(parent_name: child_name)
        }
        
        return []
    }
    #endif
    
    
}

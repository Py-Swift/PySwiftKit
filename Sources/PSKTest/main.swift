//
//  main.swift
//  PySwiftKit
//
@preconcurrency import PySwiftKit
@preconcurrency import PySwiftWrapper
import PySerializing

#if PIP_MODE
print("hmmm")
#endif

@PyModule
struct test_mod: PyModuleProtocol {

    static let py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        
    ]
    
    
    
    static let py_modules: [any (PyModuleProtocol).Type] = []
}

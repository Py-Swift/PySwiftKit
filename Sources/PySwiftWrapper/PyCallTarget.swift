//
//  PyCallTarget.swift
//  PySwiftKit
//
import PySwiftKit


public protocol PyCallTarget {}

extension PyPointer: PyCallTarget {}
extension String: PyCallTarget {}


public enum PyClassBaseType {
    case pyswift(PyTypePointer)
    case pyobject(PyTypePointer)
    case none
    
}

//
//  PyCapsuleProtocol.swift
//  PySwiftKit
//
import


public protocol PyCapsuleProtocol {
    
    func asCapsule() -> PyPointer
    
    static func fromCapsule(o)
}


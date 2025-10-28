//
//  PyCasted.swift
//  PySwiftKit
//
import PySwiftKit
import PySerializing

@freestanding(expression)
public macro PyCasted<T: PyDeserialize>(_ object: PyPointer, to: T.Type) -> T = #externalMacro(module: "PySwiftGenerators", type: "PyCastMacro")

@freestanding(expression)
public macro PyCasted<T: PyDeserialize>(_ objects: VectorArgs, index: Int, to: T.Type) -> T = #externalMacro(module: "PySwiftGenerators", type: "PyCastMacroArray")

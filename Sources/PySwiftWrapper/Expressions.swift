//
//  FreeStandings.swift
//  PySwiftKit
//
import PySwiftKit
import PySerializing



@freestanding(expression)
public macro PyListNew(_ elements: (any PySerialize)...) -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyListGenerator")

//@freestanding(expression)
//public macro PyTupleNew<each T: PySerialize>(_ elements: (repeat each T)) -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyTupleGenerator")

@freestanding(expression)
public macro PyTupleNew(_ elements: (any PySerialize)...) -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyTupleGenerator")

//
//  FreeStandings.swift
//  PySwiftKit
//





@freestanding(expression)
public macro PyListNew(_ elements: (any PySerialize)...) -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyListGenerator")


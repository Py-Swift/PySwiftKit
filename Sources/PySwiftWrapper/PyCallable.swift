//
//  PyCallable.swift
//  PySwiftKit
//

import Foundation
import PyWrapperInfo
import PySerializing
import PySwiftKit

@attached(body)
public macro PyCall(target: PyCallTarget? = nil, gil: Bool = true, method: Bool = false, cast_options: [ArgumentCast] = []) = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

//@freestanding(expression)
//public macro PyCallable<each T: PySerialize>(_ target: PyPointer, gil: Bool = true) -> (repeat each T) -> Void = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")
//
//@freestanding(expression)
//public macro PyCallable<each T: PySerialize, R: PyDeserialize>(_ target: PyPointer, gil: Bool = true, returns: R.Type) -> (repeat each T) -> R = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")


@freestanding(expression)
public macro PyCallable_V<each T: PySerialize>(_ target: PyPointer, gil: Bool = true, once: Bool = false) -> (repeat each T) -> Void = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

@freestanding(expression)
public macro PyCallable_NV(_ target: PyPointer, gil: Bool = true, once: Bool = false) -> () -> Void = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")


@freestanding(expression)
public macro PyCallable_R<each T: PySerialize, R: PyDeserialize>(_ target: PyPointer, gil: Bool = true, once: Bool = false) -> (repeat each T) throws -> R = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

@freestanding(expression)
public macro PyCallable_P<each T: PySerialize>(_ target: PyPointer, gil: Bool = true, once: Bool = false) -> (repeat each T) -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

@freestanding(expression)
public macro PyCallable_P(_ target: PyPointer, gil: Bool = true, once: Bool = false) -> () -> PyPointer = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")


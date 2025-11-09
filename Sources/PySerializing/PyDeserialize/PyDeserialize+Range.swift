//
//  PyDeserialize+Range.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension Range: PyDeserialize where Bound: PyDeserialize {
    
    public static func casted(from object: PyPointer) throws -> Range<Bound> {
        guard PyObject_TypeCheck(object, .PyRange) else { throw PyStandardException.typeError }
        let start: Bound = try PyObject_GetAttr(object, key: "start")
        let stop: Bound = try PyObject_GetAttr(object, key: "stop")
        return .init(uncheckedBounds: (lower: start, upper: stop))
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Range<Bound> {
        let start: Bound = try PyObject_GetAttr(object, key: "start")
        let stop: Bound = try PyObject_GetAttr(object, key: "stop")
        return .init(uncheckedBounds: (lower: start, upper: stop))
    }
}

extension ClosedRange: PyDeserialize where Bound: PyDeserialize {
    
    public static func casted(from object: PyPointer) throws -> ClosedRange<Bound> {
        guard PyObject_TypeCheck(object, .PyRange) else { throw PyStandardException.typeError }
        let start: Bound = try PyObject_GetAttr(object, key: "start")
        let stop: Bound = try PyObject_GetAttr(object, key: "stop")
        return .init(uncheckedBounds: (lower: start, upper: stop ))
    }
    
    public static func casted(unsafe object: PyPointer) throws -> ClosedRange<Bound> {
        let start: Bound = try PyObject_GetAttr(object, key: "start")
        let stop: Bound = try PyObject_GetAttr(object, key: "stop")
        return .init(uncheckedBounds: (lower: start, upper: stop ))
    }
    
}

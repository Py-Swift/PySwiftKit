//
//  PyDeserialize+Optional.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Optional: PyDeserialize where Wrapped: PyDeserialize {
    
    public static func casted(unsafe object: PyPointer) throws -> Self {
        if object == __Py_None__ {
            nil
        } else {
            try Wrapped.casted(unsafe: object)
        }
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        if object == __Py_None__ {
            nil
        } else {
            try Wrapped.casted(from: object)
        }
    }
}

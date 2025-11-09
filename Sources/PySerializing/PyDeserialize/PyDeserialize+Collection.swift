//
//  PyDeserialize+Collection.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension Array: PyDeserialize where Element: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Array<Element> {
        guard PyObject_TypeCheck(object, .PyList) else { throw PyStandardException.typeError }
        return try object.map { element in
            guard let element else { throw PyStandardException.indexError }
            return try .casted(from: element)
        }
    }
    public static func casted(unsafe object: PyPointer) throws -> Array<Element> {
        try object.map { element in
            guard let element else { throw PyStandardException.indexError }
            return try .casted(unsafe: element)
        }
    }
}

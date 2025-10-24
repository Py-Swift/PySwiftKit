//
//  PyDeserialize+Strings.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension String: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> String {
        guard PyObject_TypeCheck(object, .PyUnicode) else { throw PyStandardException.unicodeError }
        return .init(cString: PyUnicode_AsUTF8(object))
    }
    
    public static func casted(unsafe object: PyPointer) throws -> String {
        .init(cString: PyUnicode_AsUTF8(object))
    }
}

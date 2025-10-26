//
//  PyDeserialize+Strings.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension PyDeserialize where Self: StringProtocol {
    public static func casted(from object: PyPointer) throws -> String {
        guard PyObject_TypeCheck(object, .PyUnicode) else { throw PyStandardException.unicodeError }
        return .init(cString: PyUnicode_AsUTF8(object))
    }
    
    public static func casted(unsafe object: PyPointer) throws -> String {
        .init(cString: PyUnicode_AsUTF8(object))
    }
}

extension String: PyDeserialize {
    
}

extension Substring: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyUnicode) else { throw PyStandardException.unicodeError }
        return .init(cString: PyUnicode_AsUTF8(object))
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Self {
        .init(cString: PyUnicode_AsUTF8(object))
    }
}

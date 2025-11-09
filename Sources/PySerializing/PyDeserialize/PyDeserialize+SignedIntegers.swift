//
//  PyDeserialize+SignedIntegers.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension PyDeserialize where Self: SignedInteger {
    public static func casted(unsafe object: PyPointer) throws -> Self {
        .init(truncatingIfNeeded: PyLong_AsLong(object))
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return .init(truncatingIfNeeded: PyLong_AsLong(object))
    }
}


extension Int: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return PyLong_AsLong(object)
    }
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyLong_AsLong(object)
    }
}

extension Int64: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return PyLong_AsLongLong(object)
    }
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyLong_AsLongLong(object)
    }
}

extension Int32: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return PyLong_AsInt(object)
    }
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyLong_AsInt(object)
    }
}

extension Int16: PyDeserialize {}
extension Int8: PyDeserialize {}

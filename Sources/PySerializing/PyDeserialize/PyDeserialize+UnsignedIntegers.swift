//
//  PyDeserialize+UnsignedIntegers.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension PyDeserialize where Self: UnsignedInteger {
    public static func casted(unsafe object: PyPointer) throws -> Self {
        .init(truncatingIfNeeded: PyLong_AsUnsignedLong(object))
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return .init(truncatingIfNeeded: PyLong_AsUnsignedLong(object))
    }
}


extension UInt: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return PyLong_AsUnsignedLong(object)
    }
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyLong_AsUnsignedLong(object)
    }
}

extension UInt64: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyLong) else { throw PyStandardException.typeError }
        return PyLong_AsUnsignedLongLong(object)
    }
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyLong_AsUnsignedLongLong(object)
    }
}


extension UInt32: PyDeserialize {}
extension UInt16: PyDeserialize {}
extension UInt8: PyDeserialize {}

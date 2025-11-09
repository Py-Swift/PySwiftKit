//
//  PyDeserialize+FloatingPoint.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension PyDeserialize where Self: BinaryFloatingPoint {
    public static func casted(unsafe object: PyPointer) throws -> Self {
        .init(PyFloat_AS_DOUBLE(object))
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyFloat) else { throw PyStandardException.typeError }
        return .init(PyFloat_AS_DOUBLE(object))
    }
}

extension Double: PyDeserialize {
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyFloat_AS_DOUBLE(object)
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyFloat) else { throw PyStandardException.typeError }
        return PyFloat_AS_DOUBLE(object)
    }
}

extension Float32: PyDeserialize {}

#if (os(macOS) && arch(arm64)) || os(iOS)
@available(iOS 16,macOS 11, *)
extension Float16: PyDeserialize {}
#endif


#if canImport(CoreFoundation)
import CoreFoundation
extension CGFloat: PyDeserialize {
    public static func casted(unsafe object: PyPointer) throws -> Self {
        PyFloat_AS_DOUBLE(object)
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, .PyFloat) else { throw PyStandardException.typeError }
        return PyFloat_AS_DOUBLE(object)
    }
}
#endif

//
//  PyDeserialize+AnyObject.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension PyDeserialize where Self: AnyObject {
    
    @inlinable
    public static func casted(from object: PyPointer) throws -> Self {
        guard let swift_ptr = PyObject_AS_SwiftPtr(object) else { throw PyStandardException.memoryError }
        return Unmanaged<Self>.fromOpaque(swift_ptr).takeUnretainedValue()
    }
    
    @inlinable
    public static func casted(unsafe object: PyPointer) throws -> Self {
        return Unmanaged<Self>.fromOpaque(PyObject_AS_SwiftPtr(object)).takeUnretainedValue()
    }
    
    @inlinable
    public static func unsafeUnpacked(_ object: PyPointer) -> Self {
        Unmanaged<Self>.fromOpaque(PyObject_AS_SwiftPtr(object)).takeUnretainedValue()
    }
}



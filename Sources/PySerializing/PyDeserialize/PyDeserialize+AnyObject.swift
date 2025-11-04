//
//  PyDeserialize+AnyObject.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension PyDeserialize where Self: AnyObject {
    public static func casted(from object: PyPointer) throws -> Self {
        guard let swift_ptr = PySwiftObject_Cast(object)?.pointee.swift_ptr else { throw PyStandardException.memoryError }
        return Unmanaged<Self>.fromOpaque(swift_ptr).takeUnretainedValue()
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Self {
        return Unmanaged<Self>.fromOpaque(PySwiftObject_Cast(object)!.pointee.swift_ptr!).takeUnretainedValue()
    }
}



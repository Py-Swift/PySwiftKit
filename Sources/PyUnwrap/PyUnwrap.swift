import Foundation
import PySwiftCore
import _PySwiftObject
import PyCollection
import PythonCore
import PyTypes


public protocol PyUnwrapable {
    
    static func unpack(with object: PyPointer) throws -> Self
    
}

extension PyUnwrapable {
    static func unpack(with object: PyPointer) throws -> Self {
        guard
            //PyObject_TypeCheck(object, check),
            let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
        else { throw PythonError.notPySwiftObject }
        
        return pointee.swift_ptr.withMemoryRebound(to: Self.self, capacity: 1) { pointer in
            pointer.pointee
        }
    }
}

extension PyUnwrapable where Self: PyTypeProtocol {
    static func unpack(with object: PyPointer) throws -> Self {
        guard
            PyObject_TypeCheck(object, PyType) else {
            throw PythonError.notPySwiftObject
        }
        
        return object.withMemoryRebound(to: PySwiftObject.self, capacity: 1) { pointer in
            pointer.pointee.swift_ptr.withMemoryRebound(to: Self.self, capacity: 1) { pointer in
                pointer.pointee
            }
        }
        
    }
}

extension PyUnwrapable where Self: AnyObject {
    static func unpack(with object: PyPointer) throws -> Self {
        return object.withMemoryRebound(to: PySwiftObject.self, capacity: 1) { pointer in
            Unmanaged.fromOpaque(pointer.pointee.swift_ptr).takeUnretainedValue()
        }
    }
}


extension PyUnwrapable where Self: PyTypeProtocol & AnyObject {
    static func unpack(with object: PyPointer) throws -> Self {
        guard PyObject_TypeCheck(object, PyType) else {
            throw PythonError.type("not type <\(Self.self)>")
        }
        return object.withMemoryRebound(to: PySwiftObject.self, capacity: 1) { pointer in
            Unmanaged.fromOpaque(pointer.pointee.swift_ptr).takeUnretainedValue()
        }
    }
}



extension Array: PyUnwrapable where Element: PyUnwrapable {
    public static func unpack(with object: PyPointer) throws -> Array<Element> {
        try object.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let o = pointer.pointee
            return try PySequenceBuffer(start: o.ob_item, count: o.ob_base.ob_size).map { element in
                guard let element else { throw PythonError.sequence }
                return try .unpack(with: element)
            }
        }
    }
    
  
}


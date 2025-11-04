//
//  PySwiftObject.swift
//  PySwiftKit
//
//@_exported
import CPySwiftObject
import CPython

public typealias PySwiftObject = CPySwiftObject.PySwiftObject
public typealias PySwiftObjectPointer = UnsafeMutablePointer<PySwiftObject>


nonisolated
public class PyTypeObjectContainer: @unchecked Sendable {
    public var pointer: PyTypePointer = .allocate(capacity: 1)
    
    public init(_ pytype: PyTypeObject) {
        self.pointer.pointee = pytype
    }
    
    deinit {
        pointer.deallocate()
    }
    
}

//
//  PythonList.swift
//  PySwiftKit
//
import CPython


public class PythonList {
    
    private let ref: PythonObject
    
    public typealias ListPointer = UnsafeMutablePointer<PyListObject>
    
    private let list: ListPointer
    
    private var iter: UnsafeMutableBufferPointer<PyPointer?>.Iterator?
    
    private var buffer: UnsafeMutableBufferPointer<PyPointer?> {
        return .init(start: list.pointee.ob_item, count: list.pointee.ob_base.ob_size)
    }
    
    init(_ ref: PyPointer) {
        self.ref = .init(ref)
        list = ref.withMemoryRebound(to: PyListObject.self, capacity: 1, \.self)
        
    }
    
    deinit {
        
    }
    
}

extension PythonList: IteratorProtocol {
    public func next() -> PyPointer? {
        iter?.next() ?? nil
    }
}

extension PythonList: Sequence {
   
    public typealias Element = PyPointer
    
    public func makeIterator() -> Self {
        iter = buffer.makeIterator()
        return self
    }
}




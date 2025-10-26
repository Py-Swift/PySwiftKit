//
//  PyPointer+Sequence.swift
//  PySwiftKit
//
import CPython


extension PyPointer: Swift.Sequence {
    
    public typealias Iterator = PySequenceBuffer.Iterator
    
    public var pySequence: PySequenceBuffer {
        self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let o = pointer.pointee
            return PySequenceBuffer(start: o.ob_item, count: o.ob_base.ob_size)
        }
    }
    
    
    public func makeIterator() -> PySequenceBuffer.Iterator {
        pySequence.makeIterator()
    }
    
    
}

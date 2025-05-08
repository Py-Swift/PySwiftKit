import PythonCore
import PySwiftKit
import PySerializing


public struct PythonList {
    
    public typealias Buffer = PySequenceBuffer
    
    private let ref: PyPointer
    private let ref_counter: RefCounter
    private var buffer: Buffer
    
    init(ref: PyPointer) {
        self.ref = ref
        self.ref_counter = .init(ref: ref)
        self.buffer = Self.newBuffer(ref)
    }
    
    public init() {
        let ref = PyList_New(0)!
        self.ref = ref
        self.ref_counter = .init(ref: ref, new: true)
        self.buffer = Self.newBuffer(ref)
    }
    
    static func newBuffer(_ ref: PyPointer) -> Buffer {
        ref.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
           let o = pointer.pointee
           return Buffer(start: o.ob_item, count: o.allocated)
       }
    }
    
    
}

extension PythonList: Sequence {
    
    
    
    public typealias Iterator = PySequenceBuffer.Iterator
    
    public func makeIterator() -> Iterator {
        buffer.makeIterator()
    }
}

extension PythonList: MutableCollection {
    public subscript(position: Int) -> Buffer.Element {
        _read {
            yield buffer[position]
        }
        set(newValue) {
            PyList_Insert(ref, position, newValue)
        }
    }
    
    public typealias Element = Buffer.Element
    
    public var startIndex: Buffer.Index { buffer.startIndex }
    public var endIndex: Buffer.Index { buffer.endIndex }
    public func index(after i: Int) -> Int { buffer.index(after: i) }
}

extension PythonList: RangeReplaceableCollection {
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Buffer.Element == C.Element {
        fatalError("NotImplemented")
    }
    
    public mutating func append(_ newElement: Buffer.Element) {
        PyList_Append(ref, newElement ?? .None)
        buffer = Self.newBuffer(ref)
    }
    
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Buffer.Element == S.Element {
        for element in newElements {
            PyList_Append(ref, element)
        }
        buffer = Self.newBuffer(ref)
    }
    
    public mutating func append(contentsOf newElements: PyPointer) {
        
        _ = ref.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            _PyList_Extend(pointer, newElements)
        }
        buffer = Self.newBuffer(ref)
    }
}

extension PythonList: PySerialize {
    public var pyPointer: PyPointer { ref }
}


extension PythonList {
    private class RefCounter {
        let ref: PyPointer
        
        init(ref: PyPointer, new: Bool = false) {
            if !new { Py_XINCREF(ref) }
            
            self.ref = ref
        }
        deinit {
            Py_XDECREF(ref)
        }
    }
}

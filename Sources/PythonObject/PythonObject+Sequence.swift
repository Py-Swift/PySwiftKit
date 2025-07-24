import Foundation
import PythonCore


class PyArray<T: PyConvertible> {

    
    var list: [T]
    
    init(list: [T]) {
        self.list = list
    }
    
    func __getitem__(idx: Int) -> PyPointer? {
        guard idx < list.count else { return nil }
        return list[idx].pyPointer
    }
}

class PySequence<T: PyConvertible> {

    
    let handler: (Int) -> T?
    init(_ handler: @escaping (Int) -> T?) {
        self.handler = handler
    }
    
    func __getitem__(idx: Int) -> PyPointer? {
        guard let value = handler(idx) else { return nil }
        return value.pyPointer
    }
}

extension PythonObject: Sequence {
//    __consuming public func makeIterator() -> PySequenceBuffer.Iterator {
//        ptr.getBuffer().makeIterator()
//    }
    
    
    
    @inlinable
    __consuming public func makeIterator() -> Array<PythonObject>.Iterator {
        let fast_list = PySequence_Fast(ptr, nil)
        //PySequence_Fast(UnsafeMutablePointer<PyObject>!, UnsafePointer<CChar>!)
		let list_count = PySequence_FastSize(fast_list)
		let fast_items = PySequence_FastItems(fast_list)
        let buffer = PySequenceBuffer(start: fast_items, count: list_count)
        //buffer.makeIterator()
        //            defer {
        //                print("Dec Ref \(fast_list)")
        Py_DecRef(fast_list)
		let result: [PythonObject] = buffer.map{.init(getter: $0!.xINCREF)}
        return result.makeIterator()
    }
    
//    @inlinable
//    public mutating func next() -> Self? {
//        if let next = iter?.next() {
//            return .init(next)
//        }
//        return nil
//    }
}

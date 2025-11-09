//
//  PySerialize+Collection.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension PySerialize where Self: Collection, Self.Element: PySerialize {
    
    public func pyPointer() -> PyPointer {
        
        let py_list = PyList_New(count)!
        
        py_list.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let ob_item = pointer.pointee.ob_item
            
            _ = self.reduce(ob_item) { partialResult, next in
                partialResult?.pointee = next.pyPointer()
                return partialResult?.advanced(by: 1)
            }
        }
        
        return py_list
    }
    
}


extension Array: PySerialize where Element: PySerialize {}



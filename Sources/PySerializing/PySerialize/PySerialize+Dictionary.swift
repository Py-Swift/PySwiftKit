//
//  PySwrialize+Dictionary.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Dictionary: PySerialize where Key: PySerialize & Hashable, Value: PySerialize {
    public func pyPointer() -> PyPointer {
        
        let pydict = PyDict_New()!
        
        for (k,v) in self {
            let py_key = k.pyPointer()
            let py_value = v.pyPointer()
            
            PyDict_SetItem(pydict, py_key, py_value)
            
            Py_DecRef(py_key)
            Py_DecRef(py_value)
        }
        
        return pydict
        
    }
}

extension Dictionary where Key: PySerialize & Hashable, Value == PyPointer {
    public func pyPointer() -> PyPointer {
        
        let pydict = PyDict_New()!
        
        for (k,v) in self {
            let py_key = k.pyPointer()
            
            PyDict_SetItem(pydict, py_key, v)
            
            Py_DecRef(py_key)
            
        }
        
        return pydict
        
    }
}

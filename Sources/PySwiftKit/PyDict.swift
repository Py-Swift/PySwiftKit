//
//  PyDict.swift
//  PySwiftKit
//
import CPython

//public func PyDict_GetItem() throws -> PyPointer {
//    
//}
public func PyDict_GetItem(_ mp: PyPointer, key: String) -> PyPointer {
    key.withCString({PyDict_GetItemString(mp, $0)})
}

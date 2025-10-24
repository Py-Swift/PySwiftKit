//
//  PyDeserialize+Set.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension Set: PyDeserialize where Element: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Set<Element> {
        guard PyObject_TypeCheck(object, .PySet) else { throw PyStandardException.typeError }
        let size = PySet_Size(object)
        let iter = PyObject_GetIter(object)
        var set = Set<Element>()
        while let next = PyIter_Next(iter) {
            set.insert(try .casted(from: next))
        }
        return set
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Set<Element> {
        let size = PySet_Size(object)
        let iter = PyObject_GetIter(object)
        var set = Set<Element>()
        while let next = PyIter_Next(iter) {
            set.insert(try .casted(from: next))
        }
        return set
    }
}

//
//  PySerialize+Set.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Set: PySerialize where Element: PySerialize {
    public func pyPointer() -> PyPointer {
        let pyset = PySet_New(nil)!
        for element in self {
            PySet_Add(pyset, element.pyPointer())
        }
        return pyset
    }
}


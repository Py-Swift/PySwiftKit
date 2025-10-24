//
//  PyDeserialize+Bool.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension Bool: PyDeserialize {
    
    public static func casted(unsafe object: PyPointer) throws -> Bool {
        if object == __Py_True__ {
            true
        } else if object == __Py_False__ {
            false
        } else {
            throw PyStandardException.typeError
        }
    }
    
    public static func casted(from object: PyPointer) throws -> Bool {
        if object == __Py_True__ {
            true
        } else if object == __Py_False__ {
            false
        } else {
            throw PyStandardException.typeError
        }
    }
}

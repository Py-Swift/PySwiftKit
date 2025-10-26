//
//  PyDeserialize+Dictionary.swift
//  PySwiftKit
//

import CPython
import PySwiftKit


extension Dictionary: PyDeserialize where Key: PyDeserialize,  Value: PyDeserialize {
    
    public static func casted(from object: PyPointer) throws -> Dictionary<Key, Value> {
        guard PyObject_TypeCheck(object, .PyDict) else { throw PyStandardException.typeError }
        var d: [Key:Value] = .init()
        var pos: Int = 0
        var key: PyPointer?
        var value: PyPointer?
        while PyDict_Next(object, &pos, &key, &value) == 1 {
            guard let key, let value else { throw PyStandardException.keyError }
            d[try Key.casted(from: key)] = try Value.casted(from: value)
        }
        return d
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Dictionary<Key, Value> {
        var d: [Key:Value] = .init()
        var pos: Int = 0
        var key: PyPointer?
        var value: PyPointer?
        while PyDict_Next(object, &pos, &key, &value) == 1 {
            guard let key, let value else { throw PyStandardException.keyError }
            d[try Key.casted(unsafe: key)] = try Value.casted(unsafe: value)
        }
        return d
    }
    
    
}

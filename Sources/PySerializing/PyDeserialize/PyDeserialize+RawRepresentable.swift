//
//  PyDeserialize+RawRepresentable.swift
//  PySwiftKit
//

import CPython
import PySwiftKit

extension PyDeserialize where Self: RawRepresentable, RawValue: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Self {
        guard
            let representable: Self = .init(rawValue: try RawValue.casted(from: object))
        else { throw PyStandardException.typeError }
        return representable
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Self {
        guard
            let representable: Self = .init(rawValue: try RawValue.casted(unsafe: object))
        else { throw PyStandardException.typeError }
        return representable
    }
}


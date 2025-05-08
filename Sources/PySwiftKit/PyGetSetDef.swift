//
//  PyGetSetDef.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 07/05/2025.
//

import PythonCore

fileprivate func handleDocString(_ string: String?) -> UnsafePointer<CChar>? {
    if let string { return cString(string) }
    return nil
}


public extension PyGetSetDef {
    static func new(name: String, get: PySwiftGetter, set: PySwiftSetter = nil, doc: String? = nil) -> Self {
        let _set: setter? = if let set {
            unsafeBitCast(set, to: setter.self)
        } else {
            nil
        }
        return .init(
            name: cString(name),
            get: unsafeBitCast(get, to: getter.self),
            set: _set,
            doc: handleDocString(doc),
            closure: nil
        )
    }
}

//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation
import PythonCore
import PySwiftCore

fileprivate func handleDocString(_ string: String?) -> UnsafePointer<CChar>? {
    if let string { return cString(string) }
    return nil
}

fileprivate func handleMLFlag(flag: Int32, class_static: Bool? = nil) -> Int32 {
    if let class_static {
        if class_static { return flag | METH_CLASS }
        return flag | METH_STATIC
    }
    return flag
}

public extension PyMethodDef {
    
    init(ml_name: String, class_static: Bool? = nil, ml_doc: String? = nil,  ml_meth: PySwiftFunctionFast) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: handleMLFlag(flag: METH_FASTCALL, class_static: class_static),
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, class_static: Bool? = nil, ml_doc: String? = nil,  ml_meth: PySwiftCMethodVectorCall) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: handleMLFlag(flag: METH_FASTCALL, class_static: class_static),
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, class_static: Bool? = nil, ml_doc: String? = nil,  ml_meth: PySwiftMethod) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: handleMLFlag(flag: METH_FASTCALL, class_static: class_static),
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, class_static: Bool? = nil, ml_doc: String? = nil,  ml_meth: PyCFunction) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: ml_meth,
            ml_flags: handleMLFlag(flag: METH_FASTCALL, class_static: class_static),
            ml_doc: handleDocString(ml_doc)
        )
    }
}

public extension PyMethodDef {
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: PySwiftFunctionFast) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: PySwiftCMethodVectorCall) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: PySwiftMethod) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: PySwiftFunction) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: _PyCFunctionFast) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
    
    init(ml_name: String, ml_flags: Int32, ml_doc: String? = nil,  ml_meth: PyCFunction) {
        self.init(
            ml_name: cString(ml_name),
            ml_meth: ml_meth,
            ml_flags: ml_flags,
            ml_doc: handleDocString(ml_doc)
        )
    }
}

@resultBuilder
public struct PyMethodBuilder {
    public static func buildBlock(_ components: PyMethodDef...) -> [PyMethodDef] {
        components
    }
}

extension Array where Element == PyMethodDef {
    public init(@PyMethodBuilder methods: () -> [PyMethodDef]) {
        self = methods()
    }
}

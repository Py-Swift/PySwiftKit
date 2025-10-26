//
//  PyMethodDef.swift
//  PySwiftKit
//
import CPython

fileprivate func handleDocString(_ string: String?) -> UnsafePointer<CChar>? {
    if let string { return cString(string) }
    return nil
}

public extension CPython.PyMethodDef {
    
    static func noArgs(name: String, doc: String? = nil,  ml_meth: PySwiftFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_NOARGS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func staticNoArgs(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_NOARGS | METH_STATIC,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func classNoArgs(name: String, doc: String? = nil,  ml_meth: PySwiftFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_NOARGS | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func pyObjectNoArgs(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_NOARGS | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func moduleNoArgs(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_NOARGS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func noArgsKeywords(name: String, doc: String? = nil, ml_meth: PySwiftFunctionWithKeywords) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_VARARGS | METH_KEYWORDS,
            ml_doc: handleDocString(doc)
        )
    }
}


public extension CPython.PyMethodDef {
    static func oneArg(name: String, doc: String? = nil,  ml_meth: PySwiftFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_O,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func staticOneArg(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_O | METH_STATIC,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func classOneArg(name: String, doc: String? = nil,  ml_meth: PySwiftFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_O | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func pyObjectOneArg(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_O | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func moduleOneArg(name: String, doc: String? = nil,  ml_meth: PyCFunction) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: ml_meth,
            ml_flags: METH_O,
            ml_doc: handleDocString(doc)
        )
    }
}

public extension CPython.PyMethodDef {
    static func withArgs(name: String, doc: String? = nil,  ml_meth: PySwiftFunctionFast) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_FASTCALL,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func staticWithArgs(name: String, doc: String? = nil,  ml_meth: _PyCFunctionFast) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_FASTCALL | METH_STATIC,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func classWithArgs(name: String, doc: String? = nil,  ml_meth: PySwiftFunctionFast) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_FASTCALL | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func pyObjectWithArgs(name: String, doc: String? = nil,  ml_meth: _PyCFunctionFast) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_FASTCALL | METH_CLASS,
            ml_doc: handleDocString(doc)
        )
    }
    
    static func moduleWithArgs(name: String, doc: String? = nil,  ml_meth: _PyCFunctionFast) -> Self {
        .init(
            ml_name: cString(name),
            ml_meth: unsafeBitCast(ml_meth, to: PyCFunction.self),
            ml_flags: METH_FASTCALL,
            ml_doc: handleDocString(doc)
        )
    }
}

//
//  PyTypeObjectStruct.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//

import Foundation
import SwiftSyntax
import PyWrapperInfo

public struct PyTypeObjectStruct {
    
    let name: String
    let pyname: String
    let bases: [PyClassBase]
    let base_type: PyTypeObjectBaseType
    let unretained: Bool
    let hasMethods: Bool
    let hasGetSets: Bool
    let external: Bool
    
    
    public init(
        name: String,
        pyname: String,
        bases: [PyClassBase],
        base_type: PyTypeObjectBaseType = .none,
        unretained: Bool = false,
        hasMethods: Bool,
        hasGetSets: Bool,
        external: Bool
    ) {
        self.name = name
        self.pyname = pyname
        self.bases = bases
        self.base_type = base_type
        self.unretained = unretained
        self.hasMethods = hasMethods
        self.hasGetSets = hasGetSets
        self.external = external
    }
    
}

extension PyTypeObjectLabels {
    func asLabel(_ expr: ExprSyntaxProtocol) -> LabeledExprSyntax {
        .init(label: rawValue, expression: expr)
    }
    func asLabel(_ expr: String) -> LabeledExprSyntax {
        .init(label: rawValue, expression: expr.expr)
    }
}

extension PyTypeObjectStruct {
    
    
    
    fileprivate func setLabel(_ label: PyTypeObjectLabels) -> LabeledExprSyntax {
        
        let dot_or = external ? "_" : "."
        let out: ExprSyntaxProtocol? = switch label {
            
        case .ob_base:
            ob_base()
        case .tp_name:
            tp_name()
        case .tp_basicsize:
            tp_basicsize()
        case .tp_itemsize:
            tp_itemsize()
        case .tp_dealloc:
            tp_dealloc(label: label, sep: dot_or)
        case .tp_vectorcall_offset:
            tp_vectorcall_offset()
        case .tp_getattr: nil
        case .tp_setattr: nil
        case .tp_as_async:
            tp_as_async(label: label, sep: dot_or)
        case .tp_repr:
            tp_repr(label: label, sep: dot_or)
        case .tp_as_number:
            tp_as_number(label: label, sep: dot_or)
        case .tp_as_sequence:
            tp_as_sequence(label: label, sep: dot_or)
        case .tp_as_mapping:
            tp_as_mapping(label: label, sep: dot_or)
        case .tp_hash:
            tp_hash(label: label, sep: dot_or)
        case .tp_call:
            tp_call(label: label, sep: dot_or)
        case .tp_str:
            tp_str(label: label, sep: dot_or)
        case .tp_getattro:
            tp_getattro(label: label, sep: dot_or)
        case .tp_setattro:
            tp_setattro(label: label, sep: dot_or)
        case .tp_as_buffer:
            tp_as_buffer(label: label, sep: dot_or)
        case .tp_flags:
            tp_flags(label: label, sep: dot_or)
        case .tp_doc:
            tp_doc(label: label, sep: dot_or)
        case .tp_traverse:
            tp_traverse(label: label, sep: dot_or)
        case .tp_clear:
            tp_clear(label: label, sep: dot_or)
        case .tp_richcompare:
            tp_richcompare(label: label, sep: dot_or)
        case .tp_weaklistoffset:
            tp_weaklistoffset(label: label, sep: dot_or)
        case .tp_iter:
            tp_iter(label: label, sep: dot_or)
        case .tp_iternext:
            tp_iternext(label: label, sep: dot_or)
        case .tp_methods:
            tp_methods(label: label, sep: dot_or)
        case .tp_members:
            tp_members(label: label, sep: dot_or)
        case .tp_getset:
            tp_getset(label: label, sep: dot_or)
        case .tp_base:
            tp_base(label: label, sep: dot_or)
        case .tp_dict:
            tp_dict(label: label, sep: dot_or)
        case .tp_descr_get:
            tp_descr_get(label: label, sep: dot_or)
        case .tp_descr_set:
            tp_descr_set(label: label, sep: dot_or)
        case .tp_dictoffset:
            tp_dictoffset(label: label, sep: dot_or)
        case .tp_init:
            tp_init(label: label, sep: dot_or)
        case .tp_alloc:
            tp_alloc(label: label, sep: dot_or)
        case .tp_new:
            tp_new(label: label, sep: dot_or)
        case .tp_free:
            tp_free(label: label, sep: dot_or)
        case .tp_is_gc:
            tp_is_gc(label: label, sep: dot_or)
        case .tp_bases:
            tp_bases(label: label, sep: dot_or)
        case .tp_mro:
            tp_mro(label: label, sep: dot_or)
        case .tp_cache:
            tp_cache(label: label, sep: dot_or)
        case .tp_subclasses:
            tp_subclasses(label: label, sep: dot_or)
        case .tp_weaklist:
            tp_weaklist(label: label, sep: dot_or)
        case .tp_del:
            tp_del(label: label, sep: dot_or)
        case .tp_version_tag:
            tp_version_tag(label: label, sep: dot_or)
        case .tp_finalize:
            tp_finalize(label: label, sep: dot_or)
        case .tp_vectorcall:
            tp_vectorcall(label: label, sep: dot_or)
        case .tp_watched:
            tp_watched(label: label, sep: dot_or)
        case .tp_versions_used:
            tp_versions_used(label: label, sep: dot_or)
        }
        
        if label == .tp_vectorcall {
            return .init(label: label.rawValue, expression: NilLiteralExprSyntax())
        }
        return if let out {
            .init(label: label.rawValue, expression: out).newLineTab
        } else {
            .init(label: label.rawValue, expression: NilLiteralExprSyntax()).newLineTab
        }
    }
    
    fileprivate var arguments: LabeledExprListSyntax {
        
        
        
        return .init {
            for label in PyTypeObjectLabels.allCases {
                setLabel(label)
            }
        }
    }
    
}

extension PyTypeObjectStruct {
    func ob_base() -> ExprSyntax? {
        ".init()"
    }
    
    func tp_name() -> ExprSyntax? {
        .init(pyname.cString())
    }
    
    func tp_basicsize() -> ExprSyntax? {
        switch base_type {
        case .pyobject(_):
            "MemoryLayout<PyObject>.stride"
        default:
            "MemoryLayout<PySwiftObject>.stride"
        }
    }
    
    func tp_itemsize() -> ExprSyntax? {
        .init(literal: 0)
    }
    
    func tp_dealloc(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if !unretained {
            switch base_type {
            case .pyobject(_):
                nil
            default:
                "unsafeBitCast(\(name)\(sep)\(label), to: destructor.self)".expr
            }
        } else { nil }
    }

    func tp_vectorcall_offset() -> ExprSyntax? {
        .init(literal: 0)
    }
    
    func tp_as_async(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.async) {
            ".init(&\(name)\(sep)\(label))".expr
        } else { nil }
    }
    
    func tp_repr(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.repr) {
            switch base_type {
            case .pyobject(_):
                "\(name)\(sep)\(label)".expr
            default:
                "unsafeBitCast(\(name)\(sep)\(label), to: reprfunc.self)".expr
            }
        } else { nil }
    }
    
    func tp_as_number(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.number) {
            ".init(&\(name)\(sep)\(label))".expr
        } else { nil }
    }
    
    func tp_as_sequence(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.sequence) {
            ".init(&\(name)\(sep)\(label))".expr
        } else {
            nil
        }
    }
    
    func tp_as_mapping(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        bases.contains(.mapping) ? ".init(&\(name)\(sep)\(label))".expr : nil
    }
    
    func tp_hash(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.hash) {
            switch base_type {
            case .pyobject(_):
                "\(name)\(sep)\(label)".expr
            default:
                "unsafeBitCast(\(name)\(sep)\(label), to: hashfunc.self)".expr
            }
        } else { nil }
    }
    
    func tp_call(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_str(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        if bases.contains(.str) {
            switch base_type {
            case .pyobject(_):
                "\(name)\(sep)\(label)".expr
            default:
                "unsafeBitCast(\(name)\(sep)\(label), to: reprfunc.self)".expr
            }
        } else { nil }
    }
    
    func tp_getattro(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_setattro(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_as_buffer(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        bases.contains(.buffer) ? "\(name)\(sep)buffer_procs\(external ? "" : "()")".expr : nil
    }
    
    func tp_flags(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        "NewPyObjectTypeFlag.DEFAULT_BASETYPE"
    }
    
    func tp_doc(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_traverse(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_clear(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_richcompare(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_weaklistoffset(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        .init(literal: 0)
    }
    
    func tp_iter(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        bases.contains(.iterator) ? "unsafeBitCast(\(label), to: getiterfunc.self)".expr : nil
    }
    
    func tp_iternext(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        bases.contains(.iterator) ? "unsafeBitCast(\(label), to: iternextfunc.self)".expr : nil
    }
    
    func tp_methods(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        hasMethods ? ".init(&\(name)\(sep)PyMethodDefs)".expr : nil
    }
    
    func tp_members(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_getset(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        hasGetSets ? ".init(&\(name)\(sep)PyGetSetDefs)".expr : nil
    }
    
    func tp_base(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        switch base_type {
        case .pyobject(let type):
            type.expr
        case .pyswift(let type):
            "\(raw: type).PyType"
        case .none:
            nil
        }
    }

    func tp_dict(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_descr_get(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_descr_set(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_dictoffset(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        switch base_type {
        case .pyobject(_), .pyswift(_):
                .init(literal: 0)
        default:
            "MemoryLayout<PySwiftObject>.stride - MemoryLayout<PyObject>.stride"
        }
    }
    
    func tp_init(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        switch base_type {
        case .pyobject(let t):
            //"\(raw: t).pointee.tp_init"
            nil
        default:
            "unsafeBitCast(\(name)\(sep)tp_init, to: initproc.self)".expr
        }
    }
    
    
    
    func tp_alloc(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        "PyType_GenericAlloc"
    }
    
    func tp_new(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        switch base_type {
        case .pyobject(let t):
            //"\(raw: t).pointee.tp_new"
            nil
        default:
            "\(name)\(sep)tp_new".expr
        }
    }
    
    func tp_free(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_is_gc(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    
    func tp_bases(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_mro(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_cache(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    
    func tp_subclasses(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_weaklist(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_del(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }

    func tp_version_tag(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        "UInt32(Py_Version)"
    }
    
    func tp_finalize(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }
    
    func tp_vectorcall(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        nil
    }

    
    func tp_watched(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        .init(literal: 0)
    }
    
    func tp_versions_used(label: PyTypeObjectLabels, sep: String) -> ExprSyntax? {
        .init(literal: 0)
    }
}


extension PyTypeObjectStruct {
    public var output: FunctionCallExprSyntax {
        .init(
            calledExpression: ExprSyntax(stringLiteral: "PyTypeObject"),
            leftParen: .leftParenToken(),//(trailingTrivia: .newline), //.appending(.tab)
            arguments: arguments.with(\.leadingTrivia, .newline),
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
    
    public func createPyType() -> VariableDeclSyntax {
        let modifiers: DeclModifierListSyntax = .init {
            DeclModifierSyntax.public
            if !external {
                DeclModifierSyntax.static
            }
        }
        let pytype_name = external ? "\(name)_PyType" : "PyType"
        let pyTypeObject = external ? "\(name)_pyTypeObject" : "pyTypeObject"
        return .init(
            modifiers: modifiers, .let,
            name: .init(stringLiteral: pytype_name),
            type: .init(type: TypeSyntax(stringLiteral: "UnsafeMutablePointer<PyTypeObject>")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
            {
                let t: UnsafeMutablePointer<PyTypeObject> = .init(&\(pyTypeObject))
                if PyType_Ready(t) < 0 {
                    PyErr_Print()
                    fatalError("PyReady failed")
                }
                return t
            }()
            """)).with(\.trailingTrivia, .newlines(2))
        )
    }
}



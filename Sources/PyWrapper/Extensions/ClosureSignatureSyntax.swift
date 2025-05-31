//
//  ClosureSignatureSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder

fileprivate extension ReturnClauseSyntax {
    static var void: Self { .init(type: TypeSyntax(stringLiteral: "Void"))}
    static var pyPointer: Self { .init(type: TypeSyntax(stringLiteral: "PyPointer?"))}
    static var optPyPointer: Self { .init(type: TypeSyntax(stringLiteral: "PyPointer?"))}
    static var int32: Self { .init(type: TypeSyntax(stringLiteral: "Int32"))}
    static var int: Self { .init(type: TypeSyntax(stringLiteral: "Int"))}
    static var pySendResult: Self { .init(type: TypeSyntax(stringLiteral: "PySendResult"))}
}

extension ClosureSignatureSyntax {
    static func create(
        returnClause: ReturnClauseSyntax? = nil,
        @ClosureParameterListBuilder itemsBuilder: () -> ClosureParameterListSyntax
    ) -> Self {
        .init(parameterClause: .parameterClause(.new(itemsBuilder: itemsBuilder)), returnClause: returnClause)
    }
}

extension ClosureSignatureSyntax {
    static func allocfunc(_ type: ClosureParameterSyntax, _ size: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            type
            size
        }
    }
    
    static func destructor(_ s: ClosureParameterSyntax) -> Self {
        .create {
            s
        }
    }
    
    static func freefunc(_ raw: ClosureParameterSyntax) -> Self {
        .create {
            raw
        }
    }
    
    static func traverseproc(_ s: ClosureParameterSyntax, _ visit: ClosureParameterSyntax, _ raw: ClosureParameterSyntax ) -> Self {
        .create(returnClause: .int32) {
            [s, visit, raw]
        }
    }
    
    static func newfunc(_ s: ClosureParameterSyntax, _ args: ClosureParameterSyntax, _ kw: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            [s, args, kw]
        }
    }
    
    static func initproc(_ s: ClosureParameterSyntax, _ args: ClosureParameterSyntax, _ kw: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            [s, args, kw]
        }
    }
    
    static func reprfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            s
        }
    }
    
//    static func getattrfunc(_ s: ClosureParameterSyntax) -> Self {
//        .create(returnClause: .pyPointer) {
//            s
//        }
//    }
//    
//    static func setattrfunc(_ s: ClosureParameterSyntax) -> Self {
//        .create(returnClause: .int32) {
//            s
//        }
//    }
    
    static func getattrofunc(_ s: ClosureParameterSyntax, _ key: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            [s, key]
        }
    }
    
    static func setattrofunc(_ s: ClosureParameterSyntax, _ key: ClosureParameterSyntax, _ value: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            [s, key, value]
        }
    }
    
    static func descrgetfunc(_ s: ClosureParameterSyntax, _ x: ClosureParameterSyntax, _ y: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            [s, x, y]
        }
    }
    
    static func descrsetfunc(_ s: ClosureParameterSyntax, _ key: ClosureParameterSyntax, _ value: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            [s, key, value]
        }
    }
    
    static func hashfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int) {
            s
        }
    }
    
    static func richcmpfunc(_ l: ClosureParameterSyntax, _ r: ClosureParameterSyntax, _ cmp: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            [l, r, cmp]
        }
    }
    
    static func getiterfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            s
        }
    }
    
    static func iternextfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            s
        }
    }
    
    static func lenfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int) {
            s
        }
    }
    
    static func getbufferproc(_ s: ClosureParameterSyntax, _ buffer: ClosureParameterSyntax, _ size: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            [s, buffer, size]
        }
    }
    
    static func releasebufferproc(
        _ s: ClosureParameterSyntax,
        _ buffer: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .void) {
            [s, buffer]
        }
    }
    
    static func inquiry(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            s
        }
    }
    
    static func unaryfunc(_ s: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            s
        }
    }
    
    static func binaryfunc(
        _ s: ClosureParameterSyntax,
        _ o: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .pyPointer) {
            [s, o]
        }
    }
    
    static func ternaryfunc(
        _ s: ClosureParameterSyntax,
        _ o: ClosureParameterSyntax,
        _ kw: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .pyPointer) {
            [s, o, kw]
        }
    }
    
    static func ssizeargfunc(
        _ s: ClosureParameterSyntax,
        _ i: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .pyPointer) {
            [s, i]
        }
    }
    
    static func ssizeobjargproc(
        _ s: ClosureParameterSyntax,
        _ i: ClosureParameterSyntax,
        _ o: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .int32) {
            [s, i, o]
        }
    }
    
    static func objobjproc(
        _ s: ClosureParameterSyntax,
        _ x: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .int32) {
            [s, x]
        }
    }
    
    static func objobjargproc(
        _ s: ClosureParameterSyntax,
        _ x: ClosureParameterSyntax,
        _ y: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .int32) {
            [s, x, y]
        }
    }
    
    static func sendfunc(
        _ s: ClosureParameterSyntax,
        _ args: ClosureParameterSyntax,
        _ kw: ClosureParameterSyntax
    ) -> Self {
        .create(returnClause: .pySendResult) {
            [s, args, kw]
        }
    }
    
    static func void(_ s: ClosureParameterSyntax) -> Self {
        .init(parameterClause: .parameterClause(.void))
    }
    
    static func getset_getter(_ s: ClosureParameterSyntax,_ raw: ClosureParameterSyntax) -> Self {
        .create(returnClause: .pyPointer) {
            s
            raw
        }
    }
    
    static func getset_setter(_ s: ClosureParameterSyntax, _ newValue: ClosureParameterSyntax, _ raw: ClosureParameterSyntax) -> Self {
        .create(returnClause: .int32) {
            s
            newValue
            raw
        }
    }
}

extension ClosureSignatureSyntax.ParameterClause {
    static func new(@ClosureParameterListBuilder itemsBuilder: () -> ClosureParameterListSyntax) -> Self {
        .parameterClause(.new(itemsBuilder: itemsBuilder))
    }
}


extension ClosureSignatureSyntax {
    
    
    
    static func _inquiry(_ s: ClosureParameterSyntax) -> Self {
        .init(parameterClause: .new {
            s
        }, returnClause: .int32)
    }
    
    static func _unaryfunc(_ s: ClosureParameterSyntax) -> Self {
        .init(parameterClause: .parameterClause(.new {
            s
        }), returnClause: .pyPointer)
    }
    
    static func _binaryfunc(_ s: ClosureParameterSyntax,_ o: ClosureParameterSyntax) -> Self {
        .init(parameterClause: .parameterClause(.new {
            s
            o
        }), returnClause: .pyPointer)
    }
    
    static func _ternaryfunc(_ s: ClosureParameterSyntax,_ o: ClosureParameterSyntax,_ kw: ClosureParameterSyntax) -> Self {
        .init(parameterClause: .parameterClause(.new {
            s
            o
            kw
        }), returnClause: .pyPointer)
    }
}

extension ClosureParameterClauseSyntax {
    fileprivate static var __self__: ClosureParameterSyntax { "__self__" }
    
    fileprivate static var _type: ClosureParameterSyntax { "type" }
    
    fileprivate static var size: ClosureParameterSyntax { "size" }
    
    fileprivate static var __arg__: ClosureParameterSyntax { "__arg__" }
    
    fileprivate static var __args__: ClosureParameterSyntax { "__args__" }
    
    fileprivate static var kw: ClosureParameterSyntax { "kw" }
    
    fileprivate static var raw: ClosureParameterSyntax { "raw" }
    
    fileprivate static func new(@ClosureParameterListBuilder itemsBuilder: () -> ClosureParameterListSyntax) -> Self {
        .init(parameters: .init(itemsBuilder: itemsBuilder))
    }
}


//extension ParameterClauseSyntax {
//    static func new(@ClosureParameterListBuilder itemsBuilder: () -> ClosureParameterListSyntax) -> Self {
//        
//    }
//}

extension ClosureParameterClauseSyntax {
    
    static var allocfunc: Self { .new {
        _type
        size
    }}
    
    static var destructor: Self { .new { __self__ } }
    
    static var freefunc: Self { .new { raw } }
    
    static var traverseproc: Self { .new {
        __self__
        "visit"
        raw
    }}
    
    static var newfunc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var initproc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var reprfunc: Self { .new {
        __self__
    }}
    
    static var getattrfunc: Self { .new {
    }}
    
    static var setattrfunc: Self { .new {
        
    }}
    
    static var getattrofunc: Self { .new {
        __self__
        "key"
    }}
    
    static var setattrofunc: Self { .new {
        __self__
        "key"
        "newValue"
    }}
    
    static var descrgetfunc: Self { .new {
        __self__
        "key"
    }}
    
    static var descrsetfunc: Self { .new {
        __self__
        "key"
        "newValue"
    }}
    
    static var hashfunc: Self { .new {
        __self__
    }}
    
    static var richcmpfunc: Self { .new {
        "l"
        "r"
        "cmp"
    }}
    
    static var getiterfunc: Self { .new {
        __self__
    }}
    
    static var iternextfunc: Self { .new {
        __self__
    }}
    
    static var lenfunc: Self { .new {
        __self__
    }}
    
    static var getbufferproc: Self { .new {
        __self__
        "buffer"
    }}
    
    static var releasebufferproc: Self { .new {
        __self__
        "buffer"
    }}
    
    static var inquiry: Self { .new {
        __self__
    }}
    
    static var unaryfunc: Self { .new {
        __self__
    }}
    
    static var binaryfunc: Self { .new {
        __self__
        "o"
    }}
    
    static var ternaryfunc: Self { .new {
        __self__
        "o"
        kw
    }}
    
    static var ssizeargfunc: Self { .new {
        __self__
        "i"
    }}
    
    static var ssizeobjargproc: Self { .new {
        __self__
        "i"
        "o"
    }}
    
    static var objobjproc: Self { .new {
        __self__
        "x"
    }}
    
    static var objobjargproc: Self { .new {
        __self__
        "x"
        "y"
    }}
    
    static var sendfunc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var void: Self { .new {
        "_"
    }}
    
    static var getset_getter: Self { .new {
        __self__
        "clossure"
    }}
    
    static var getset_setter: Self { .new {
        __self__
        "clossure"
        "newValue"
    }}
}

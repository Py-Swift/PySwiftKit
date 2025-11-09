//
//  ClosureExprSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder


extension ClosureExprSyntax {
    static func allocfunc(
        s: ClosureParameterSyntax = "__self__",
        size: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .allocfunc(s, size), statementsBuilder: itemsBuilder)
    }
    
    static func destructor(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .destructor(s), statementsBuilder: itemsBuilder)
    }
    
    static func freefunc(
        raw: ClosureParameterSyntax = "raw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .freefunc(raw), statementsBuilder: itemsBuilder)
    }
    
    static func traverseproc(
        s: ClosureParameterSyntax = "__self__",
        visit: ClosureParameterSyntax = "visit",
        raw: ClosureParameterSyntax = "raw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .traverseproc(s, visit, raw), statementsBuilder: itemsBuilder)
    }
    
    static func newfunc(
        s: ClosureParameterSyntax = "__self__",
        args: ClosureParameterSyntax = "__args__",
        kw: ClosureParameterSyntax = "kw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .newfunc(s, args, kw), statementsBuilder: itemsBuilder)
    }
      
    static func initproc(
        s: ClosureParameterSyntax = "__self__",
        args: ClosureParameterSyntax = "__args__",
        kw: ClosureParameterSyntax = "kw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .initproc(s, args, kw), statementsBuilder: itemsBuilder)
    }
    
    static func reprfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .reprfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func getattrfunc(
        s: ClosureParameterSyntax = "__self__",
        key: ClosureParameterSyntax = "key",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getattrofunc(s, key), statementsBuilder: itemsBuilder)
    }
    
    static func setattrfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .setattrofunc("", "", ""), statementsBuilder: itemsBuilder)
    }
    
    static func getattrofunc(
        s: ClosureParameterSyntax = "__self__",
        key: ClosureParameterSyntax = "key",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getattrofunc(s, key), statementsBuilder: itemsBuilder)
    }
    
    static func setattrofunc(
        s: ClosureParameterSyntax = "__self__",
        key: ClosureParameterSyntax = "key",
        value: ClosureParameterSyntax = "value",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .setattrofunc(s, key, value), statementsBuilder: itemsBuilder)
    }
    
    static func descrgetfunc(
        s: ClosureParameterSyntax = "__self__",
        x: ClosureParameterSyntax = "x",
        y: ClosureParameterSyntax = "y",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .descrgetfunc(s, x, y), statementsBuilder: itemsBuilder)
    }
    
    static func descrsetfunc(
        s: ClosureParameterSyntax = "__self__",
        key: ClosureParameterSyntax = "key",
        value: ClosureParameterSyntax = "value",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .descrsetfunc(s, key, value), statementsBuilder: itemsBuilder)
    }
    
    static func hashfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .hashfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func richcmpfunc(
        l: ClosureParameterSyntax = "l",
        r: ClosureParameterSyntax = "r",
        cmp: ClosureParameterSyntax = "cmp",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .richcmpfunc(l, r, cmp), statementsBuilder: itemsBuilder)
    }
    
    static func getiterfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getiterfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func iternextfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .iternextfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func lenfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .lenfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func getbufferproc(
        s: ClosureParameterSyntax = "__self__",
        buffer: ClosureParameterSyntax = "buffer",
        size: ClosureParameterSyntax = "size",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getbufferproc(s, buffer, size), statementsBuilder: itemsBuilder)
    }
    
    static func releasebufferproc(
        s: ClosureParameterSyntax = "__self__",
        buffer: ClosureParameterSyntax = "buffer",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .releasebufferproc(s, buffer), statementsBuilder: itemsBuilder)
    }
    
    static func inquiry(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .inquiry(s), statementsBuilder: itemsBuilder)
    }
    
    static func unaryfunc(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .unaryfunc(s), statementsBuilder: itemsBuilder)
    }
    
    static func binaryfunc(
        s: ClosureParameterSyntax = "__self__",
        o: ClosureParameterSyntax = "o",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .binaryfunc(s, o), statementsBuilder: itemsBuilder)
    }
    
    static func ternaryfunc(
        s: ClosureParameterSyntax = "__self__",
        o: ClosureParameterSyntax = "o",
        kw: ClosureParameterSyntax = "kw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .ternaryfunc(s, o, kw), statementsBuilder: itemsBuilder)
    }
    
    static func ssizeargfunc(
        s: ClosureParameterSyntax = "__self__",
        i: ClosureParameterSyntax = "i",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .ssizeargfunc(s, i), statementsBuilder: itemsBuilder)
    }
    
    static func ssizeobjargproc(
        s: ClosureParameterSyntax = "__self__",
        i: ClosureParameterSyntax = "i",
        o: ClosureParameterSyntax = "o",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .ssizeobjargproc(s, i, o), statementsBuilder: itemsBuilder)
    }
    
    static func objobjproc(
        s: ClosureParameterSyntax = "__self__",
        x: ClosureParameterSyntax = "x",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .objobjproc(s, x), statementsBuilder: itemsBuilder)
    }
    
    static func objobjargproc(
        s: ClosureParameterSyntax = "__self__",
        x: ClosureParameterSyntax = "x",
        y: ClosureParameterSyntax = "y",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .objobjargproc(s, x, y), statementsBuilder: itemsBuilder)
    }
    
    static func sendfunc(
        s: ClosureParameterSyntax = "__self__",
        args: ClosureParameterSyntax = "args",
        kw: ClosureParameterSyntax = "kw",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .sendfunc(s, args, kw), statementsBuilder: itemsBuilder)
    }
    
    static func void(
        s: ClosureParameterSyntax = "__self__",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .void(s), statementsBuilder: itemsBuilder)
    }
    
    static func getset_getter(
        s: ClosureParameterSyntax = "__self__",
        raw: ClosureParameterSyntax = "_",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getset_getter(s, raw), statementsBuilder: itemsBuilder)
    }
    
    static func getset_setter(
        s: ClosureParameterSyntax = "__self__",
        newValue: ClosureParameterSyntax = "newValue",
        raw: ClosureParameterSyntax = "_",
        @CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax
    ) -> Self {
        .init(signature: .getset_setter(s, newValue, raw), statementsBuilder: itemsBuilder)
    }
}


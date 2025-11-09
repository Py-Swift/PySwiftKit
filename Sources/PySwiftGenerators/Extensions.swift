//
//  Extensions.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 29/04/2025.
//
import SwiftSyntax

enum PyMethodDefFlag: String {
    case METH_NOARGS
    case METH_O
    case METH_FASTCALL
    
}

extension String {
    var typeSyntax: TypeSyntax { .init(stringLiteral: self) }
    
    var decref: ExprSyntax { "Py_DecRef(\(raw: self))" }
}

extension FunctionCallExprSyntax {
    //    static func pyMethodDef() -> FunctionCallExprSyntax {
    //
    //
    //
    //
    //        return .init(calledExpression: <#T##ExprSyntaxProtocol#>, arguments: <#T##LabeledExprListSyntax#>)
    //    }
}

extension TypeSyntax {
    public static var PyClassProtocol: Self {
        .init(stringLiteral: "PyClassProtocol")
    }
}

extension AttributedTypeSyntax {
    public static let PyClassProtocol: Self = .init(
        specifiers: [],
        attributes: [.preconcurrency],
        baseType: TypeSyntax.PyClassProtocol
    )
    
}

extension AttributeListSyntax.Element {
    public static var preconcurrency: Self {
        .attribute(.init(stringLiteral: "@preconcurrency"))
    }
}

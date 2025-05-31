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

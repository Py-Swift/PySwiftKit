//
//  PyCasted.swift
//  PySwiftKit
//
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PyCastMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let args = node.arguments.compactMap(\.expression)
        
        let src = args[0]
        
        guard
            let member = args.last?.as(MemberAccessExprSyntax.self),
            let base = member.base
        else {
            fatalError("wasnt a member acceess expr")
        }
        
        switch src.as(ExprSyntaxEnum.self) {
        case .arrayExpr(let arrayExpr):
            let index = args[1]
            return "try \(base).casted(\(src.trimmed)[\(index)])"
        default:
            return "try \(base).casted(\(src))"
        }
    }
}

public struct PyCastMacroVectorArgs: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let args = node.arguments.compactMap(\.expression)
        
        let src = args[0]
        
        guard
            let member = args.last?.as(MemberAccessExprSyntax.self),
            let base = member.base
        else {
            fatalError("wasnt a member acceess expr")
        }
        let index = args[1]
        return "try \(base).casted(\(src.trimmed)[\(index)])"
        
    }
}



//
//  PySwiftKitMacroGenerator.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 27/04/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapper



public struct PySwiftFuncWrapper: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return []
//        guard let function =  declaration.as(FunctionDeclSyntax.self) else { fatalError() }
//        let function_name = function.name.text
//        
//        let parameters = function.signature.parameterClause.parameters
//        let nargs = parameters.count
//        let multi = nargs > 1
//        let call_parameters = parameters.lazy.enumerated().map { i, p in
//            
//            if let s_name = p.secondName, s_name.text == "_" {
//                LabeledExprSyntax(expression: ExprSyntax(stringLiteral: handleTypes(p.type, nil)))
//            } else {
//                LabeledExprSyntax(label: p.firstName, colon: .colonToken(), expression: ExprSyntax(stringLiteral: handleTypes(p.type, multi ? i : nil)))
//            }
//            
//        }
//        let f = FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: function_name), argumentList: {
//            for call_parameter in call_parameters {
//                call_parameter
//            }
//        })
//        
//        let many = nargs > 0
//        let methodType: TypeSyntax = nargs > 1 ? "_PyCFunctionFast" : "PyCFunction"
//        
//        let methodDecl: DeclSyntax = switch nargs {
//        case 0:
//            
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = { _, _ in
//                    \(raw: f)
//                    return .None
//                }
//                return PyMethodDef(ml_name: \(literal: function_name), ml_flags: METH_NOARGS, ml_meth: method)
//            }()
//                        
//            """
//        case 1:
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = { _, arg in
//                    \(raw: f)
//                    return .None
//                }
//                return PyMethodDef(ml_name: \(literal: function_name), ml_flags: METH_O, ml_meth: method)
//            }()
//                        
//            """
//        default:
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = { _, args, nargs in
//                    \(raw: f)
//                    return .None
//                }
//                return PyMethodDef(ml_name: \(literal: function_name), ml_flags: METH_FASTCALL, ml_meth: unsafeBitCast(method, to: PyCFunction.self))
//            }()
//                        
//            """
//        }
//        
//        
//        return [
//            methodDecl,
//            """
//            public static var py_\(raw: function_name): PyPointer { PyCFunction_New(&__\(raw: function_name)__, nil)! }
//            """
//        ]
    }
    
    
}




public struct PySwiftMethodWrapper: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let _ =  declaration.as(FunctionDeclSyntax.self) else { fatalError() }
        return []
//        let function_name = function.name.text
//        
//        let parameters = function.signature.parameterClause.parameters
//        let nargs = parameters.count
//        let multi = nargs > 1
//        let call_parameters = parameters.lazy.enumerated().map { i, p in
//            
//            if let s_name = p.secondName, s_name.text == "_" {
//                LabeledExprSyntax(expression: ExprSyntax(stringLiteral: handleTypes(p.type, nil)))
//            } else {
//                LabeledExprSyntax(label: p.firstName, colon: .colonToken(), expression: ExprSyntax(stringLiteral: handleTypes(p.type, multi ? i : nil)))
//            }
//            
//        }
//        let cls = "\(node.arguments!.as(LabeledExprListSyntax.self)!.first!.expression.as(MemberAccessExprSyntax.self)!.base!.description)"
//        let f_m = MemberAccessExprSyntax(base: ExprSyntax(stringLiteral: "\(cls)()"), name: .identifier(function_name))
//        let f = FunctionCallExprSyntax.init(callee: f_m, argumentList: {
//            for call_parameter in call_parameters {
//                call_parameter.with(\.leadingTrivia, .newline)
//            }
//        }).with(\.rightParen, nargs  > 0 ? .rightParenToken(leadingTrivia: .newline) : .rightParenToken())
//        
//        //let many = nargs > 0
//        let methodType: TypeSyntax = nargs > 1 ? "PySwiftFunctionFast" : "PyCFunction"
//        
//        let methodDecl: DeclSyntax = switch nargs {
//        case 0:
//            
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = \(raw: PyClossure(par_count: nargs, callExpr: f).output)
//                return PyMethodDef(ml_name: \(literal: function_name), ml_flags: METH_NOARGS, ml_meth: method)
//            }()
//                        
//            """
//        case 1:
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = \(raw: PyClossure(par_count: nargs, callExpr: f).output)
//                return PyMethodDef(ml_name: \(literal: function_name), ml_meth: method)
//            }()
//                        
//            """
//        default:
//            """
//            
//            private static var __\(raw: function_name)__ = {
//                var method: \(raw: methodType) = \(raw: PyClossure(par_count: nargs, callExpr: f).output)
//                return PyMethodDef(ml_name: \(literal: function_name), ml_meth: method)
//            }()
//                        
//            """
//        }
//        
//        
//        return [
//            methodDecl,
//            """
//            public static var py_\(raw: function_name): PyPointer { PyCFunction_New(&__\(raw: function_name)__, nil)! }
//            """
//        ]
    }
    
    
}



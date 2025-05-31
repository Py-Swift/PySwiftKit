//
//  PyMethodDef.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import PyWrapperInfo

func kwarg_option(f: FunctionDeclSyntax) -> Kwargs {
    if let pymethod = f.getPyMethod {
        switch pymethod.arguments {
        case .argumentList(let argumentList):
            for argument in argumentList {
                guard argument.label?.text == "kwargs" else { continue }
                switch argument.expression.as(ExprSyntaxEnum.self) {
                case .memberAccessExpr(let memberAccess):
                    if let option = Kwargs(rawValue: memberAccess.declName.baseName.text) { return option }
                default: break
                }
            }
        default: break
        }
    }
    
    return .none
}

public struct PyMethodDefGenerator {
    
    let f: FunctionDeclSyntax
    let parameters: [FunctionParameterSyntax]
    let call: FunctionCallExprSyntax
    let ftype: TypeSyntax
    let canThrow: Bool
    let is_static: Bool
    let module_or_class: Bool
    let kwargs: Kwargs
    
    public init(target: String, f: FunctionDeclSyntax, module_or_class: Bool = false) {
        self.f = f
        let kwargs = kwarg_option(f: f)
        self.kwargs = kwargs
        self.module_or_class = module_or_class
        let parameters = Array(f.signature.parameterClause.parameters)
        let nargs = parameters.count
        let multi = nargs > 1
        
        self.ftype = switch nargs {
        case 0: "PySwiftFunction".typeSyntax()
        case 1: "PySwiftFunction".typeSyntax()
        default: "PySwiftFunctionFast".typeSyntax()
        }
        
        self.parameters = parameters
        
        canThrow = f.signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil || parameters.canThrow
        is_static = f.modifiers.contains { mod in
            mod.name.text == "static"
        }
        let type: ExprSyntax = target.expr
        let call: ExprSyntaxProtocol = MemberAccessExprSyntax(
            base: (is_static || module_or_class) ? type : "Unmanaged<\(raw: type)>.fromOpaque(\(raw: "__self__").pointee.swift_ptr).takeUnretainedValue()",
            name: f.name
        )
        //FunctionParameterSyntax.init(stringLiteral: "").firstName.text
        
        self.call = .init(
            calledExpression: call,
            leftParen: .leftParenToken(),
            arguments: .init {
                if kwargs == .kw_only {
                    LabeledExprSyntax(leadingTrivia: .newline, label: "kwargs", colon: .colonToken(), expression: ExprSyntax(stringLiteral: "try .init(object: __kwargs__)"))
                } else {
                    for (i, parameter) in f.signature.parameterClause.parameters.lazy.enumerated() {
                        if let s_name = parameter.secondName, s_name.trimmed.text == "_" {
                            LabeledExprSyntax(leadingTrivia: .newline, expression: handleTypes(parameter.type, nil))
                        } else {
                            LabeledExprSyntax(leadingTrivia: .newline,label: parameter.firstName, colon: .colonToken(), expression: handleTypes(
                                parameter.type,
                                multi ? i : nil,
                                target: parameter.firstName.text
                            )
                            )
                        }
                    }
                }
            },
            rightParen: nargs > 0 ? .rightParenToken(leadingTrivia: .newline) : .rightParenToken()
        )
        
    }
    
}

extension PyMethodDefGenerator {
    
    fileprivate func _arguments(canThrow: Bool = true) -> LabeledExprListSyntax {
        let count = parameters.count
        let label: TokenSyntax = switch count {
        case 0: "noArgs"
        case 1: "oneArg"
        default: "withArgs"
        }
        
        let closure = PyClossure(
            par_count: count,
            callExpr: call,
            argsThrows: parameters.canThrow,
            funcThrows: f.throws,
            ex_parameters: parameters.enumerated().compactMap({ i, p in
                let many = count > 1
                let ex_label = many ? "__args__[\(i)]" : "__arg__"
                return switch p.type.as(TypeSyntaxEnum.self) {
                case .functionType(let functionTypeSyntax): "let _\((p.secondName ?? p.firstName).text) = \(ex_label)"
                default: nil
                }
            })
        ).output
    return .init {
        LabeledExprSyntax(leadingTrivia: .newline ,label: label, colon: .colonToken(), expression: f.name.text.makeLiteralSyntax())
        if is_static {
            LabeledExprSyntax(leadingTrivia: .newline ,label: "class_static", colon: .colonToken(), expression: false.makeLiteralSyntax())
        }
        LabeledExprSyntax(leadingTrivia: .newline, label: "ml_meth", colon: .colonToken(), expression: closure)
    }}
    
    fileprivate func methodName(_ count: Int) -> MemberAccessExprSyntax {
        let label: TokenSyntax = if module_or_class {
            switch count {
            case 0:
                "moduleNoArgs"
            case 1:
                "moduleOneArg"
            default:
                "moduleWithArgs"
            }
        } else {
            if kwargs == .kw_only {
                "noArgsKeywords"
            } else {
                switch count {
                case 0:
                    is_static ? "staticNoArgs" : "noArgs"
                case 1:
                    is_static ? "staticOneArg" : "oneArg"
                default:
                    is_static ? "staticWithArgs" : "withArgs"
                }
            }
        }
        return .init(name: label)
    }
    
    fileprivate func arguments(canThrow: Bool = true) -> LabeledExprListSyntax {
        let count = parameters.count
        
        let closure = PyClossure(
            par_count: count,
            callExpr: call,
            argsThrows: parameters.canThrow,
            funcThrows: f.throws,
            no_self: module_or_class || is_static,
            return_type: f.signature.returnClause?.type,
            ex_parameters: parameters.enumerated().compactMap({ i, p in
                let many = count > 1
                let ex_label = if kwargs == .kw_only {
                    "__kwargs__"
                } else {
                    many ? "__args__[\(i)]" : "__arg__"
                }
                return switch p.type.as(TypeSyntaxEnum.self) {
                case .functionType(_): "let _\((p.secondName ?? p.firstName).text) = \(ex_label)"
                case .attributedType(let attributedType):
                    switch attributedType.baseType.as(TypeSyntaxEnum.self) {
                    case .functionType(_): "let _\((p.secondName ?? p.firstName).text) = \(ex_label)"
                    default: nil
                    }
                default: nil
                }
            }),
            kwargs: kwarg_option(f: f)
        ).output
    return .init {
        LabeledExprSyntax(leadingTrivia: .newline ,label: "name", colon: .colonToken(), expression: f.name.text.makeLiteralSyntax())
        LabeledExprSyntax(leadingTrivia: .newline, label: "ml_meth", colon: .colonToken(), expression: closure)
    }}
    
    public var method: FunctionCallExprSyntax {
        
        return FunctionCallExprSyntax(
            calledExpression: methodName(parameters.count),
            leftParen: .leftParenToken(),
            arguments: arguments(canThrow: canThrow),
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
}


extension FunctionCallExprSyntax {

}

//
//  PyClossure.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 29/04/2025.
//

import SwiftSyntax
import PyWrapperInfo

public class PyClossure {
    
    var par_count: Int
    
    var callExpr: FunctionCallExprSyntax
    
    var argsThrows: Bool
    
    var funcThrows: Bool
    
    var no_self: Bool
    
    var return_type: TypeSyntax?
    
    var ex_parameters: [String]
    
    var kwargs: Kwargs
    
    public init(
        par_count: Int,
        callExpr: FunctionCallExprSyntax,
        argsThrows: Bool = true,
        funcThrows: Bool = false,
        no_self: Bool = false,
        return_type: TypeSyntax? = nil,
        ex_parameters: [String] = [],
        kwargs: Kwargs = .none
    ) {
        self.par_count = par_count
        self.callExpr = callExpr
        self.argsThrows = argsThrows
        self.funcThrows = funcThrows
        self.no_self = no_self
        self.return_type = return_type
        self.ex_parameters = ex_parameters
        self.kwargs = kwargs
    }
    
    
}

extension PyClossure {
    
    var extracts_conditions: ConditionElementListSyntax {
        .init {
            switch par_count {
            case 0:
                if !no_self {
                    ConditionElementSyntax(condition: .expression(" let __self__"), trailingTrivia: .space)
                }
            case 1:
                if !no_self {
                    ConditionElementSyntax(condition: .expression(" let __self__"))
                }
                if kwargs == .kw_only {
                    ConditionElementSyntax(condition: .expression(" let __kwargs__"), trailingTrivia: .space)
                } else {
                    if let parameter = ex_parameters.first {
                        ConditionElementSyntax(condition: .expression(parameter.expr), trailingTrivia: .space)
                    } else {
                        ConditionElementSyntax(condition: .expression(" let __arg__"), trailingTrivia: .space)
                    }
                }
            default:
                ConditionElementSyntax(condition: .expression(" nargs == \(raw: par_count)"))
                if !no_self {
                    ConditionElementSyntax(condition: .expression(" let __self__"))
                }
                ConditionElementSyntax(condition: .expression(" let __args__"), trailingTrivia: .space)
                for par in ex_parameters {
                    ConditionElementSyntax(condition: .expression(par.expr), trailingTrivia: .space)
                }
            }
            
        }
    }
    
    var extracts: GuardStmtSyntax {
       // .init(conditions: extracts_conditions, elseKeyword: .poundElseToken(leadingTrivia: .newline), body: .init {} )
            .init(conditions: extracts_conditions) {
                "return nil"
            }
    }
}

extension PyClossure {
    private var parameters: ClosureParameterListSyntax {.init {
        if no_self {
            "_"
        } else {
            "__self__"
        }
        switch par_count {
        case 0: 
            "_"
        case 1:
            if kwargs == .kw_only {
                "_"
                "__kwargs__"
            } else {
                "__arg__"
            }
        default:
            "__args__"
            "nargs"
        }
    }}
    
    private var signature: ClosureSignatureSyntax {
        return .init(parameterClause: .parameterClause(.init(parameters: parameters)), returnClause: .init(type: TypeSyntax.optPyPointer))
    }
    
    private var statements: CodeBlockItemListSyntax {
        let call: ExprSyntaxProtocol = if funcThrows {
            TryExprSyntax(expression: callExpr)
        } else {
            callExpr
        }
        let body: CodeBlockSyntax = .init {
            if no_self && par_count == 0 {
                
            } else {
                extracts
            }
            if let return_type {
                let rtn_call: ExprSyntaxProtocol = switch return_type.kind {
                case .optionalType:
                    MemberAccessExprSyntax(base: OptionalChainingExprSyntax(expression: call), name: .identifier("pyPointer"))
                default:
                    if return_type.isPyPointer {
                        call
                    } else {
                        MemberAccessExprSyntax(base: call, name: .identifier("pyPointer"))
                    }
                }
                    
                ReturnStmtSyntax(expression: rtn_call)
            } else {
                call
                "return .None"
            }
        }
        return .init {
            
            if argsThrows || funcThrows {
                DoStmtSyntax(
                    body: body,
                    catchClauses: .standardPyCatchClauses
                )
                "return nil"
            } else {
                body.statements
            }
            
        }
    }
    
    public var output: ClosureExprSyntax { .init(signature: signature, statements: statements) }
}

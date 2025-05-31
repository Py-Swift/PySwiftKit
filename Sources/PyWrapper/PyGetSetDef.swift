//
//  PyGetSetDef.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 07/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder


public struct PyGetSetDefGenerator {
    
    let cls: TypeSyntax
    let decl: VariableDeclSyntax
    var name: TokenSyntax = ""
    var type: TypeSyntax = .pyPointer
    var read_only: Bool = false
    
    
    init(cls: TypeSyntax, decl: VariableDeclSyntax) {
        self.cls = cls
        self.decl = decl
        read_only = decl.bindingSpecifier.trimmedDescription == "let"
        
        let bindings = decl.bindings
        if let binding = bindings.first?.as(PatternBindingSyntax.self) {
            name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier ?? ""
            if let t = binding.typeAnnotation?.type {
                type = t
            }
            if let initializer = binding.initializer {
                
            } else if let accessorBlock = binding.accessorBlock {
                switch accessorBlock.accessors  {
                case .accessors(let acclist):
                    read_only = !acclist.contains(where: {$0.accessorSpecifier.text == "set"})
                case .getter(_):
                    read_only = true
                }
            }
        }
        
    }
    
    var cast_cls: ExprSyntax {
        "Unmanaged<\(raw: cls)>.fromOpaque(__self__.pointee.swift_ptr).takeUnretainedValue()"
    }
    
    var get_code: CodeBlockItemListSyntax {
        .init {
            "guard let __self__ else { return nil }"
            ReturnStmtSyntax(
                expression:  MemberAccessExprSyntax(
                    base: cast_cls,
                    name: "\(raw: name).pyPointer"
                )
            )
        }
    }
    
    var set_code: CodeBlockItemListSyntax {
        .init {
            "guard let __self__, let __arg__ else { return 0 }"
            if type.canThrow {
                
            }
            InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(
                    base: cast_cls,
                    name: name
                ),
                operator: "= ".expr,
                rightOperand: handleTypes(type, nil)
            )
            ReturnStmtSyntax(expression: 0.makeLiteralSyntax())
        }
    }
    
    public var output: FunctionCallExprSyntax {
        .init(callee: ".new".expr) {
            LabeledExprSyntax(leadingTrivia: .newline, label: "name", colon: .colonToken(), expression: name.text.makeLiteralSyntax())
            LabeledExprSyntax(leadingTrivia: .newline, label: "get", colon: .colonToken(), expression: Getter(code: get_code).clossure)
            if !read_only {
                LabeledExprSyntax(leadingTrivia: .newline, label: "set", colon: .colonToken(), expression: Setter(type: type, code: set_code).clossure)
            }
        }.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
    }
    
    public var arrayElement: ArrayElementSyntax {
        .init(leadingTrivia: .newline, expression: output)
    }
}

extension PyGetSetDefGenerator {
    struct Getter {
        
        var code: CodeBlockItemListSyntax
        
        var clossure: ClosureExprSyntax {
            .getset_getter {
                code
            }
        }
    }
    
    struct Setter {
        
        var type: TypeSyntax
        var code: CodeBlockItemListSyntax
        
        var clossure: ClosureExprSyntax {
            .getset_setter(newValue: "__arg__") {
                if type.canThrow {
                    DoStmtSyntax(body: .init(statements: code), catchClauses: .standardPyCatchClauses)
                    "return 0"
                } else {
                    code
                }
            }
        }
    }
}

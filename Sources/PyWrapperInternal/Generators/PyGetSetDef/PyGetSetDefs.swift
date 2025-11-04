//
//  PyGetSetMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import Foundation
import SwiftSyntax
import PyWrapperInfo


public struct PyGetSetDefs {
    
    var cls: TypeSyntax
    var properties: [ VariableDeclSyntax ]
    var external: Bool
    var swift_mode: SwiftMode
    
    public init(cls: TypeSyntax, properties: [VariableDeclSyntax], external: Bool = false, swift_mode: SwiftMode) {
        self.cls = cls
        self.properties = properties
        self.external = external
        self.swift_mode = swift_mode
    }
    
    public var arrayExpr: ArrayExprSyntax {
        .init(elements: .init {
            for property in properties {
                PyGetSetDefGenerator(cls: cls, decl: property).arrayElement
            }
            ArrayElementSyntax(leadingTrivia: .newline ,expression: "PyGetSetDef()".expr)
        }, rightSquare: .rightSquareToken(leadingTrivia: .newline))
    }
    
    public var expr: ExprSyntax { .init(arrayExpr) }
    
    public var output: DeclSyntax {
        let name = external ? "\(cls.trimmedDescription)_PyGetSetDefs" : "PyGetSetDefs"
        let modifiers = DeclModifierListSyntax {
            DeclModifierSyntax.fileprivate
            if swift_mode == .v6 {
                DeclModifierSyntax.MainActor
            }
            if !external {
                DeclModifierSyntax.static
            }
        }
        
        return .init(
            VariableDeclSyntax(
                modifiers: modifiers,
                .var,
                name: .init(stringLiteral: name),
                type: .init(type: "[PyGetSetDef]".typeSyntax()),
                initializer: .init(value: arrayExpr)
            )
        )
        
    }
}


//struct PyGetSetProperty {
//    
//    var property: VariableDeclSyntax
//    var cls: String
//    var typeSyntax: TypeSyntax
//    
//    init(property: VariableDeclSyntax, cls: String) {
//        self.property = property
//        self.cls = cls
//        self.typeSyntax = property.bindings.last?.as(TypeAnnotationSyntax.self)?.type ?? .pyPointer
//        
//        
//    }
//    
//}
//
//extension PyGetSetProperty {
//    var getter: ClosureExprSyntax {
//        .getset_getter {
//            
//        }
//    }
//    
//    var setter: ClosureExprSyntax {
//        .getset_setter {
//            
//        }
//    }
//    
//    var pyGetSetDef: FunctionCallExprSyntax {
//        .init(calledExpression: "PyGetSetDef".expr) {
//            
//        }
//    }
//}

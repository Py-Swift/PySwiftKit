//
//  PyMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax


public class PyMethods {
    
    var cls: String
    var input: [FunctionDeclSyntax]
    let module_or_class: Bool
    let external: Bool
    
    public init(cls: String, input: [FunctionDeclSyntax], module_or_class: Bool = false, external: Bool = false) {
        self.cls = cls
        self.input = input
        self.module_or_class = module_or_class
        self.external = external
    }
    
}

extension PyMethods {
    
    fileprivate var arrayElements: ArrayElementListSyntax {
        
        return .init {
            for f in input {
                ArrayElementSyntax(leadingTrivia: .newline, expression: PyMethodDefGenerator(target: cls ,f: f, module_or_class: module_or_class).method)
            }
            ArrayElementSyntax(leadingTrivia: .newline, expression: "PyMethodDef()".expr)
        }
    }
    
    fileprivate var initializer: InitializerClauseSyntax {
        .init(value: ArrayExprSyntax(elements: arrayElements, rightSquare: .rightSquareToken(leadingTrivia: .newline)))
    }
    
    public var output: DeclSyntax {
        
        let modifiers: DeclModifierListSyntax = .init {
            DeclModifierSyntax.fileprivate
            if !external {
                DeclModifierSyntax.static
            }
        }
        
        return .init(VariableDeclSyntax(modifiers: modifiers, .var, name: "\(external ? "\(cls)_" : "")PyMethodDefs", type: .init(type: "[PyMethodDef]".typeSyntax()), initializer: initializer))
        
    }
}




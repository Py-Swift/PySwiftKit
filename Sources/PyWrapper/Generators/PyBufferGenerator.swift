//
//  PyBufferGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 25/05/2025.
//


import Foundation
import SwiftSyntax


struct PyBufferGenerator {
    let cls: String
    let external: Bool
    
    var variDecl: VariableDeclSyntax {
        let modifiers = DeclModifierListSyntax {
            if !external {
                DeclModifierSyntax.static
            } else {
                DeclModifierSyntax.fileprivate
            }
        }
        return .init(
            modifiers: modifiers, .var,
            name: .init(stringLiteral: external ? "\(cls)_buffer_procs" : "buffer_procs"),
            type: .init(type: TypeSyntax(stringLiteral: "UnsafeMutablePointer<PyBufferProcs>")),
            initializer: .init(value: "\(cls).buffer_procs()".expr)
        ).with(\.trailingTrivia, .newlines(2))
        
    }
    
    
    init(cls: String, external: Bool = false) {
        self.cls = cls
        self.external = external
    }
}

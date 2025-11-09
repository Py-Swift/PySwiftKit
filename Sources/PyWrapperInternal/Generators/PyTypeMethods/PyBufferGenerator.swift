//
//  PyBufferGenerator.swift
//  PySwiftWrapper
//


import Foundation
import SwiftSyntax
import PyWrapperInfo


struct PyBufferGenerator {
    let cls: String
    let external: Bool
    let swift_mode: SwiftMode
    
    var variDecl: VariableDeclSyntax {
        let modifiers = DeclModifierListSyntax {
            if swift_mode == .v6 {
                DeclModifierSyntax.MainActor
            }
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
    
    
    init(cls: String, external: Bool, swift_mode: SwiftMode) {
        self.cls = cls
        self.external = external
        self.swift_mode = swift_mode
    }
}

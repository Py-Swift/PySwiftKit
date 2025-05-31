//
//  PySwiftGenerators.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct PyMethodAttribute: PeerMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

struct PyPropertyAttribute: PeerMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

struct PeerDummy: PeerMacro {
    static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        []
    }
}

@main
struct PySwiftGeneratorsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PySwiftFuncWrapper.self,
        PyPropertyAttribute.self,
        PyMethodAttribute.self,
        AttachedTestMacro.self,
        PySwiftClassGenerator.self,
        PySwiftModuleGenerator.self,
        ExtractPySwiftObject.self,
        PyCallbackGenerator.self,
        PyCallFiller.self,
        PeerDummy.self,
        PyContainerMacro.self
        //PyMethodGenerator.self
    ]
}

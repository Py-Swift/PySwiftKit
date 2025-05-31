//
//  Expressions.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 04/05/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros


struct PyUnmanaged: ExpressionMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        return """
        Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
        """
    }
}

struct ExtractPySwiftObject: CodeItemMacro, ExpressionMacro, DeclarationMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            guard
                PyObject_TypeCheck(object, Self.PyType),
                let pointee = unsafeBitCast(object, to: PySwiftObjectPointer.self)?.pointee
            else {
                throw PyStandardException.typeError
            }
            """
        ]
    }
    
    
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        """
        if
            PyObject_TypeCheck(object, Self.PyType),
            let pointee = unsafeBitCast(object, to: PySwiftObjectPointer.self)?.pointee
        {
            Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
        }
        else {
            throw PyStandardException.typeError
        }
        """
    }
    
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [CodeBlockItemSyntax] {
        return [
            """
            guard
                PyObject_TypeCheck(object, Self.PyType),
                let pointee = unsafeBitCast(object, to: PySwiftObjectPointer.self)?.pointee
            else {
                throw PyStandardException.typeError
            }
            """
        ]
    }
    
    
}

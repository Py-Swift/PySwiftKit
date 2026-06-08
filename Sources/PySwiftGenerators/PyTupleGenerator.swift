//
//  PyTupleGenerator.swift
//  PySwiftKit
//
import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapperInternal


struct PyTupleGenerator: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        
        let extracts: [String] = node.arguments.enumerated().map { i, label in
            "ob_item[\(i)] = \(label.expression.trimmedDescription).pyPointer()"
        }
        
        return """
        {
            let pyTuple = PyTuple_New(\(raw: node.arguments.count))!
        
            pyTuple.withMemoryRebound(to: PyTupleObject.self, capacity: 1) { pointer in
                guard let ob_item = pointer.pointer(to: \\.ob_item) else {
                    return
                }
                \(raw: extracts.joined(separator: "\n"))
            }
            
            return pyTuple
        }() 
        """
    }
}

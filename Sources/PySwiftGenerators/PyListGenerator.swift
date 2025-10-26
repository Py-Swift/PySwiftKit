import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapperInternal


struct PyListGenerator: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        
        let extracts: [String] = node.arguments.enumerated().map { i, label in
            "ob_item[\(i)] = \(label.expression.trimmedDescription).pyPointer()"
        }
        
        return """
        {
            let pyList = PyList_New(\(raw: node.arguments.count))! 
                
            pyList.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
                let ob_item = pointer.pointee.ob_item!
                \(raw: extracts.joined(separator: "\n"))
            }
            
            return pyList
        }() 
        """
    }
}

import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapper


struct MyListGenerator: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        
        
        return """
        if let new_list = PyList_New()
        """
    }
}

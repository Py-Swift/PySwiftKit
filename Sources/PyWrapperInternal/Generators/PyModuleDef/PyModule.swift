//
//  PyModule.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 03/05/2025.
//
// import SwiftSyntaxWrapper
import SwiftSyntax

public class PyModule {
    let name: String
    let classes: [TypeSyntax]
    let module_count: Int
    /// When set, `py_module` is built with `slots: &<customSlotsSymbol>` instead of the
    /// shared `baseSlots`. Used so a module's types are registered in its own `Py_mod_exec`
    /// slot (multi-phase init), since `PyModule_AddType` needs the real module object.
    let customSlotsSymbol: String?

    public init(name: String, classes: [TypeSyntax], module_count: Int, customSlotsSymbol: String? = nil) {
        self.name = name
        self.classes = classes
        self.module_count = module_count
        self.customSlotsSymbol = customSlotsSymbol
    }
}

fileprivate extension String {
    func asLabeledExpr(_ expression: ExprSyntaxProtocol) -> LabeledExprSyntax {
        .init(label: self, expression: expression)
    }
}

extension PyModule {
    public var variDecl: VariableDeclSyntax {
        let call = FunctionCallExprSyntax(callee: ".new".expr) {
            "name".asLabeledExpr(name.makeLiteralSyntax())
            "methods".asLabeledExpr(module_count > 0 ? "&PyMethodDefs".expr : NilLiteralExprSyntax())
            if let customSlotsSymbol {
                "slots".asLabeledExpr("&\(customSlotsSymbol)".expr)
            }
        }//.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
        
        
        
        
        return .init(
            leadingTrivia: .lineComment("// #### PyModuleDef ####").appending(.newlines(2) as Trivia),
            modifiers: [.static], .var,
            name: .init(stringLiteral: "py_module"),
            type: .init(type: TypeSyntax(stringLiteral: "PyModuleDef")),
            initializer: .init(value: call)
        ).with(\.trailingTrivia, .newlines(2))
    }
}

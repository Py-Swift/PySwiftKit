//
//  PyModule.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 03/05/2025.
//
import SwiftSyntax

public class PyModule {
    let name: String
    let classes: [TypeSyntax]
    let module_count: Int
    
    public init(name: String, classes: [TypeSyntax], module_count: Int) {
        self.name = name
        self.classes = classes
        self.module_count = module_count
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

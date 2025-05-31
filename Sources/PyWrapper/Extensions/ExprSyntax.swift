//
//  ExprSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax


public extension ExprSyntax {
    static func UnPackPySwiftObject(_ cls: String, arg: String = "__self__") -> Self {
        .init(stringLiteral: "UnPackPySwiftObject(with: \(arg), as: \(cls).self)")
    }
}

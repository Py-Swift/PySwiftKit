//
//  GuardStmtSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//

import SwiftSyntax

extension GuardStmtSyntax {
    static func nargs_kwargs(_ n: Int) -> Self {
        return try! .init("guard nkwargs + nargs >= \(raw: n) else") {
            FunctionCallExprSyntax.pyErr_SetString("Args missing needed \(n)")
            "return -1"
        }
    }
}

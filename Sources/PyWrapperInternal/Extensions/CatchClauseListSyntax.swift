//
//  CatchClauseListSyntax.swift
//  PyWrapperInternal
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension CatchClauseListSyntax {
    
    fileprivate static func catchItem(_ label: String) -> CatchItemListSyntax {
        .init(
            arrayLiteral: .init(pattern: IdentifierPatternSyntax(identifier: .identifier(label)))
        )
    }
    
    static var standardPyCatchClauses: Self {
        .init {
            CatchClauseSyntax(catchItem("let err as PyStandardException")) {
                //"setPyException(type: err, message: \(literal: function.name))"
                "err.pyExceptionError()"
                
            }
            CatchClauseSyntax(catchItem("let err as PyException")) {
                "err.pyExceptionError()"
            }
            CatchClauseSyntax(catchItem("let other_error")) {
                "other_error.anyErrorException()"
            }
        }
    }
}

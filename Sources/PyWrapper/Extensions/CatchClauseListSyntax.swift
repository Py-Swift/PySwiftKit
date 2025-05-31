//
//  File.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
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
//            CatchClauseSyntax(catchItem("let err as PythonError")) {
//                if arg_count > 1 {
//                    """
//                    switch err {
//                    case .call: err.triggerError("wanted \(raw: arg_count) got \\(__nargs__)")
//                    default: err.triggerError("hmmmmmm")
//                    }
//                    """
//                } else {
//                    """
//                    switch err {
//                    case .call: err.triggerError("arg type Error")
//                    default: err.triggerError("hmmmmmm")
//                    }
//                    """
//                }
//            }
            CatchClauseSyntax(catchItem("let other_error")) {
                "other_error.anyErrorException()"
            }
        }
    }
}

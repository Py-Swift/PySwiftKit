import SwiftSyntax
import Foundation
import SwiftSyntaxMacros
import SwiftParser
import PyWrapper
import PyWrapperInfo

class PyClassByExtensionUnpack {
    var bases: [PyClassBase] = []
    //var unretained = false
    var functions: [FunctionDeclSyntax] = []
    var properties: [VariableDeclSyntax] = []
    //var type: TypeSyntax
    
    init(arguments: LabeledExprListSyntax) throws {
        for argument in arguments {
            guard let label = argument.label else { continue }
            switch argument.label?.text {
            case "expr":
                if let expr = argument.expression.as(StringLiteralExprSyntax.self) {
                    let statements = Parser.parse(source: expr.segments.description).statements
                    let funcDecls = statements.compactMap { blockItem in
                        let item = blockItem.item
                        return switch item.kind {
                        case .functionDecl: item.as(FunctionDeclSyntax.self)
                        default: nil
                        }
                    }
                    functions = funcDecls
                    
                    let varDecls = statements.compactMap { blockItem in
                        let item = blockItem.item
                        return switch item.kind {
                        case .variableDecl: item.as(VariableDeclSyntax.self)
                        default: nil
                        }
                    }
                    properties = varDecls
                }
            case "bases":
                switch argument.expression.kind {
                case .arrayExpr:
                    guard let array = argument.expression.as(ArrayExprSyntax.self) else { fatalError() }
                    //fatalError("argumentList")
                    bases = array.elements.compactMap { element in
                        if let enum_case = element.expression.as(MemberAccessExprSyntax.self) {
                            //fatalError("argumentList")
                            return PyClassBase(rawValue: enum_case.declName.baseName.text)
                        } else { return nil }
                    }
                case .memberAccessExpr:
                    guard let member = argument.expression.as(MemberAccessExprSyntax.self) else { fatalError() }
                    if member.declName.baseName.text == "all" {
                        bases = .all
                    }
                default: break
                }
            default: continue
            }
        
        }
        
    }
    
    struct ArgError: Error {
        
    }
}

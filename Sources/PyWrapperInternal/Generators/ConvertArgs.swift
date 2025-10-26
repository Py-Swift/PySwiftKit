//
//  ConvertArgs.swift
//  PySwiftKit
//
import SwiftSyntax
import SwiftSyntaxBuilder

public func handleTypes(_ t: TypeSyntax, _ index: Int?, target: String? = nil) -> ExprSyntax {
    //getConvertType(t.trimmed).expr(index: index, target: target)
    fatalError()
}


enum PyConvertType {
    case raw
    case py_cast(TypeSyntaxProtocol)
    case optional_py_cast(TypeSyntaxProtocol)
    case casted(TypeSyntaxProtocol)
    case functionType(FunctionTypeSyntax)
    
    
}


extension PyConvertType {
    public func expr(index: Int?, target: String?) -> ExprSyntax {
        switch self {
        case .raw:
            if let index {
                "__args__[\(raw: index)]!"
            } else {
                "__arg__"
            }
        case .py_cast(let t):
            if let index {
                "#PyCasted(__arg__, index: \(raw: index), to: \(t).self"
            } else {
                "#PyCasted(__arg__, to: \(t).self"
            }
        case .optional_py_cast(let t):
            if let index {
                "#PyCasted(__arg__, index: \(raw: index), to: \(t).self"
            } else {
                "#PyCasted(__arg__, to: \(t).self"
            }
        case .casted(let t):
            if let index {
                "#PyCasted(__arg__, index: \(raw: index), to: \(t).self"
            } else {
                "#PyCasted(__arg__, to: \(t).self"
            }
        case .functionType(let t):
            if let index {
                "#PyCasted(__arg__, index: \(raw: index), to: \(t).self"
            } else {
                "#PyCasted(__arg__, to: \(t).self"
            }
        }
    }
}

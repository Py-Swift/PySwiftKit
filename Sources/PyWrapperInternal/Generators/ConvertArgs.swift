//
//  ConvertArgs.swift
//  PySwiftKit
//
import SwiftSyntax
import SwiftSyntaxBuilder

public func handleTypes(_ t: TypeSyntax, _ index: Int?, target: String? = nil) -> ExprSyntax {
    getConvertType(t.trimmed).expr(index: index, target: target)
}

extension FunctionTypeSyntax {
    func pyCallable(target: String) -> ClosureExprSyntax {
        
        
        return PyCallableClosure(
            funcType: self,
            codeBlock: PyCallableCodeBlock(syntax: self, target: target, gil: true).output
        ).output
    }
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
        case .functionType(let functionType):
            ExprSyntax(
                functionType.pyCallable(target: target!)
            )
        }
    }
}

func getConvertType(_ t: TypeSyntax) -> PyConvertType {
    
    switch t.as(TypeSyntaxEnum.self) {
    case .identifierType(let identifierType):
        
        if let _ = PyWrap.RawType(typeSyntax: identifierType) {
            return .raw
        } else if let _ = PyWrap.IntegerType(typeSyntax: identifierType) {
            return .casted(t)
        } else if let _ = PyWrap.FloatingPointType(typeSyntax: identifierType) {
            return .casted(t)
        } else if let _ = PyWrap.FoundationType(typeSyntax: identifierType) {
            return .casted(t)
        } else if let _ = PyWrap.ObjcType(typeSyntax: identifierType) {
            return .casted(t)
        } else {
            return .casted(t)
        }
        
    case .optionalType(let optionalType):
        return getConvertType(optionalType)
    case .implicitlyUnwrappedOptionalType(let unwrappedOptType):
        return getConvertType(unwrappedOptType.wrappedType)
    case .arrayType(let arrayType):
        return getConvertType(arrayType)
    case .dictionaryType(_): return  .py_cast(t)
    case .functionType(let functionType): return  .functionType(functionType)
    case .attributedType(let attributedType):
        return getConvertType(attributedType.baseType)
    default:
        fatalError(t.description)
    }
    
    
}

func getConvertType(_ t: ArrayTypeSyntax) -> PyConvertType {
    .py_cast(t)
}

func getConvertType(_ t: OptionalTypeSyntax) -> PyConvertType {
    switch PyWrap.RawType(typeSyntax: t.wrappedType) {
    case .PyPointer, .Void: .raw
    case .none: .casted(t)
    }
}

func getConvertType(_ t: ForceUnwrapExprSyntax) -> PyConvertType {
    let forcedType = t.expression.trimmedDescription.typeSyntax()
    return switch PyWrap.RawType(typeSyntax: forcedType) {
    case .PyPointer, .Void: .raw
    case .none: .casted(forcedType)
    }
}



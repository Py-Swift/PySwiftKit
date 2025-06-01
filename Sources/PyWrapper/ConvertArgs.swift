//
//  ConvertArgs.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 28/04/2025.
//
import SwiftSyntax
import SwiftSyntaxBuilder


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
    func expr(index: Int?, target: String?) -> ExprSyntax {
        
        
        
        return switch self {
        case .raw:
            if let index {
                "__args__[\(raw: index)]!"
            } else {
                "__arg__"
            }
        case .py_cast(_):
            if let index {
                "try pyCast(from: __args__, index: \(raw: index))"
            } else {
                "try pyCast(from: __arg__)"
            }
        case .optional_py_cast(_):
            if let index {
                "optionalPyCast(from: __args__[\(raw: index)])"
            } else {
                "optionalPyCast(from: __arg__)"
            }
        case .casted(let t):
            if let index {
                "try PyCast<\(raw: t)>.cast(from: __args__[\(raw: index)]!)"
            } else {
                "try PyCast<\(raw: t)>.cast(from: __arg__)"
            }
        case .functionType(let functionType):
            ExprSyntax(
                functionType.pyCallable(target: target!)
            )
        }
    }
}

public protocol SwiftTypeProtocol: RawRepresentable where RawValue == StringLiteralType {
    var canThrow: Bool { get }
}

extension SwiftTypeProtocol {
    public init?(typeSyntax: IdentifierTypeSyntax) {
        self.init(rawValue: typeSyntax.name.text)
    }
    
    public init?(typeSyntax: TypeSyntax) {
        self.init(rawValue: typeSyntax.trimmedDescription)
    }
}

public struct PyWrap {
    
    public enum IntegerType: String, SwiftTypeProtocol {
        case Int
        case UInt
        case Int32
        case UInt32
        case Int16
        case UInt16
        case Int8
        case UInt8
        
        public var canThrow: Bool { true }
        
    }
    
    public enum FloatingPointType: String, SwiftTypeProtocol{
        case Float
        case Double
        case CGFloat
        case Float32
        case Float16
        
        public var canThrow: Bool { true }
        
       
    }
    
    public enum RawType: String , SwiftTypeProtocol{
        case PyPointer
        case Void
        
        public var canThrow: Bool { false }
        
    }
    
    public enum FoundationType: String, SwiftTypeProtocol {
        case Data
        case Date
        case Calender
        
        public var canThrow: Bool { true }
    }
    
    public enum ObjcType: String, SwiftTypeProtocol {
        case NSObject
        case NSArray
        
        public var canThrow: Bool { true }
    }
    
    public enum SwiftType: String {
        
        
        case Int
        case UInt
        case Int32
        case UInt32
        case Int16
        case UInt16
        case Int8
        case UInt8
        case String
        
        case Float
        case Double
        case Float32
        case Float16
        
        case Data
        case Date
        case Calender
        
        case NSObject
        case NSArray
        case Void
        case PyPointer
        
        public var canThrow: Bool { true }
    }
    
//    public enum BaseTypes: String {
//        case Int
//        case UInt
//        case Int32
//        case UInt32
//        case Int16
//        case UInt16
//        case Int8
//        case UInt8
//        case String
//        
//        case Float
//        case Double
//        case Float32
//        case Float16
//        
//        case Data
//        case Date
//        case Calender
//        
//        case NSObject
//        case NSArray
//        case Void
//        case PyPointer
//        
//        init?(typeSyntax: TypeSyntax) {
//            self.init(rawValue: typeSyntax.trimmedDescription)
//        }
//        
//        
//    }
    
    
    
}

func getConvertType(_ t: TypeSyntax) -> PyConvertType {
    
    switch t.as(TypeSyntaxEnum.self) {
    case .identifierType(let identifierType):
        
        if let _ = PyWrap.RawType(typeSyntax: identifierType) {
            return .raw
        } else if let _ = PyWrap.IntegerType(typeSyntax: identifierType) {
            return .py_cast(t)
        } else if let _ = PyWrap.FloatingPointType(typeSyntax: identifierType) {
            return .py_cast(t)
        } else if let _ = PyWrap.FoundationType(typeSyntax: identifierType) {
            return .py_cast(t)
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
    
    //fatalError("\(t.description) - \(PyWrap.SwiftType(rawValue: t.element.trimmed))")
    .py_cast(t)
//    return switch PyWrap.SwiftType(rawValue: t.element) {
//    case .none: .casted(t)
//    default: .py_cast(t)
//    }
}

func getConvertType(_ t: OptionalTypeSyntax) -> PyConvertType {
    
    //return .py_cast(t)
    switch PyWrap.RawType(typeSyntax: t.wrappedType) {
    case .PyPointer, .Void: .raw
    case .none: .casted(t)
    }
//    return switch PyWrap.SwiftType(rawValue: t.wrappedType) {
//    case .PyPointer: .raw
//    case .none: .casted(t)
//    default: .optional_py_cast(t)
//    }
}

func getConvertType(_ t: ForceUnwrapExprSyntax) -> PyConvertType {
    let forcedType = t.expression.trimmedDescription.typeSyntax()
    //return .py_cast(t)
    return switch PyWrap.RawType(typeSyntax: forcedType) {
    case .PyPointer, .Void: .raw
    case .none: .casted(forcedType)
    }
//    return switch PyWrap.SwiftType(rawValue: t.wrappedType) {
//    case .PyPointer: .raw
//    case .none: .casted(t)
//    default: .optional_py_cast(t)
//    }
}

public func handleTypes(_ t: TypeSyntax, _ index: Int?, target: String? = nil) -> ExprSyntax {
    getConvertType(t.trimmed).expr(index: index, target: target)
}


//private func handleArrayType(_ t: ArrayTypeSyntax,_ index: Int?) -> String {
//    switch t.element.kind {
//    case .arrayType: break
//    case .optionalType: break
//    case .dictionaryType: break
//    default: break
//    }
//    
//    return switch PyWrap.BaseTypes(typeSyntax: t.element) {
//    case .none:
//        if let index {
//            "try \(t.description).casted(from: __args__[\(index)]!)"
//        } else {
//            "try \(t.description).casted(from: __arg__)"
//        }
//    default:
//        if let index {
//            "try pyCast(from: __args__, index: \(index))"
//        } else {
//            "try pyCast(from: __arg__)"
//        }
//    }
//    
//}
//
//
//private func handleOptionalType(_ t: OptionalTypeSyntax, _ index: Int?) -> String {
//    switch PyWrap.BaseTypes(rawValue: t.wrappedType.description) {
//    case .PyPointer:
//        if let index {
//            "noneOrNil(__args__[\(index)])"
//        } else {
//            "noneOrNil(__arg__)"
//        }
//    default:
//        if let index {
//            "optionalPyCast(from: __args__[\(index)])"
//        } else {
//            "optionalPyCast(from: __arg__)"
//        }
//    }
//}


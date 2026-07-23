//
//  PyCallMethod.swift
//  PySwiftKit
//
import SwiftSyntax

fileprivate extension String {
    var labelExpr: LabeledExprSyntax { .init(expression: self.expr) }
}

public class PyCallMethodGenerator {
    let parameters: [FunctionParameterSyntax]
    let returnType: TypeSyntax?
    let arg_count: Int
    //let function: FunctionDeclSyntax
    let call_name: String
    var canThrow: Bool
    var funcThrows: Bool
    var gil: Bool
    var method: String?
    var path: String?
    
    public init(function: FunctionDeclSyntax, gil: Bool, method: String?, path: String? = nil) {
        //self.function = function
        self.path = path
        self.call_name = function.name.trimmedDescription
        self.gil = gil
        self.method = method
        let signature = function.signature
        let parameters = Array(signature.parameterClause.parameters)
        self.parameters = parameters
        arg_count = parameters.count
        let rtn = signature.returnClause
        canThrow = function.throws
        funcThrows = function.throws
        if let rtn {
            returnType = rtn.type
            if rtn.canThrow {
                canThrow = true
            }
        } else {
            returnType = nil
        }
    }
    
//    public init(target: String, parameters: LabeledExprListSyntax,returnType: TypeSyntax? = nil , gil: Bool, method: Bool, canThrow: Bool, once: Bool) {
//        //self.function = function
//        self.target = target
//        self.call_name = ""
//        self.gil = gil
//        self.method = method
//        self.once = once
//        //let parameters = Array(signature.parameterClause.parameters)
//        let letters = Array("abcdefghijk")
//        
//        self.parameters = parameters.enumerated().map({ i, parameter in
//                .init(firstName: .identifier(.init(letters[i])), type: TypeSyntax("Any"))
//        })
//        arg_count = parameters.count
//        self.canThrow = canThrow
//        self.funcThrows = canThrow
//        self.gil = gil
//        self.method = method
//        self.returnType = returnType
////        let rtn = signature.returnClause
////        canThrow = function.throws
////        funcThrows = function.throws
////        if let rtn {
////            returnType = rtn.type
////            if rtn.canThrow {
////                canThrow = true
////            }
////        } else {
////            returnType = nil
////        }
//        
//    }
//    
    
}



extension PyCallMethodGenerator {
    
    
    
    public enum Mode {
        case single
        case multi
    }
    
    var callee: ExprSyntax {
            switch arg_count {
            case 0: "PyObject_CallMethodNoArgs"
            case 1: "PyObject_CallMethodOneArg"
            default: "PyObject_VectorcallMethod"
            }
        
        
    }
    
    var call: FunctionCallExprSyntax {
        return .init(callee: callee) {
            if arg_count < 2 {
                (self.path ?? "py_target").labelExpr
            }
            call_target.labelExpr
            if arg_count > 0 {
                switch arg_count {
                case 1:
                    "arg".labelExpr
                default:
                    "__args__".labelExpr
                    LabeledExprSyntax(expression: (arg_count + 1).makeLiteralSyntax())
                    "nil".labelExpr
                }
            }
        }
    }
    
    var call_target: String {
        method ?? "_\(call_name)"
    }
}

extension PyCallMethodGenerator {
    var condition: ConditionElementListSyntax {
        .init {
            ConditionElementSyntax(condition: .expression( " let result = \(raw: call)"))
        }
    }
    
    var pre_call: CodeBlockItemListSyntax {
        .init {
            switch arg_count {
            case 0: ""
            case 1:
                let parameter = parameters.first!
                "let arg = \(raw: (parameter.secondName ?? parameter.firstName)).pyPointer()"
            default:
                if let path {
                    VectorArgs(parameters: parameters, method: path).pre
                } else {
                    VectorArgs(parameters: parameters, method: "py_target").pre
                }
                
//                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: arg_count))"
//                if method {
//                    "__args__[0] = py_target"
//                }
//                for (index, parameter) in parameters.enumerated() {
//                    let pname = (parameter.secondName ?? parameter.firstName)
//                    "__args__[\(raw: method ? index + 1 : index)] = \(raw: pname).pyPointer"
//                }
            }
//            if arg_count > 1 {
//                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: arg_count))"
//                for (index, parameter) in parameters.enumerated() {
//                    let pname = (parameter.secondName ?? parameter.firstName)
//                    "__args__[\(raw: index)] = \(raw: pname).pyPointer\n"
//                }
//            }
        }
    }
    
    var post_call: CodeBlockItemListSyntax {
        .init {
            switch arg_count {
            case 0: ""
            case 1: "Py_DecRef(arg)"
            default:
//                for index in 0..<arg_count {
//                    "Py_DecRef(__args__[\(raw: method ? index + 1 : index)])"
//                }
//                "__args__.deallocate()"
                VectorArgs(parameters: parameters, method: path).post
            }
            
        }
    }
    
    private var code: CodeBlockItemListSyntax {
        //let manyArgs = arg_count > 1
        return .init {
            if gil {
                "let gil = PyGIL_Released() ? PyGILState_Ensure() : nil"
            }
            pre_call
            GuardStmtSyntax(conditions: condition, elseKeyword: .keyword(.else, leadingTrivia: .space)) {
                "PyErr_Print()"
                post_call
                if gil {
                    "if let gil { PyGILState_Release(gil) }"
                }
                if returnType != nil {
                    if funcThrows {
                        "throw PyStandardException.typeError"
                    } else {
                        "fatalError()"
                    }
                } else {
                    if funcThrows {
                        "throw PyStandardException.typeError"
                    } else {
                        "return"
                    }
                }
                
            }
            post_call
            
            if let returnType {
                if returnType.isPyPointer {
                    if gil {
                        "if let gil { PyGILState_Release(gil) }"
                    }
                    "return result"
                } else {
                    "let _result = try \(raw: returnType).casted(from: result)"
                    "Py_DecRef(result)"
                    if gil {
                        "if let gil { PyGILState_Release(gil) }"
                    }
                    "return _result"
                }
                
            } else {
                "Py_DecRef(result)"
                if gil {
                    "if let gil { PyGILState_Release(gil) }"
                }
            }
        }
    }
    
    public var output: CodeBlockItemListSyntax {
        .init {
//            if canThrow && !funcThrows {
//                DoStmtSyntax(body: .init(statements: code), catchClauses: .standardPyCatchClauses)
//                if returnType != nil {
//                    if funcThrows {
//                        "throw PyStandardException.typeError"
//                    } else {
//                        "fatalError()"
//                    }
//                }
//            } else {
                code
//            }
        }
    }
    
}


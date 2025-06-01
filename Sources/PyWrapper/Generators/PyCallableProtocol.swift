import SwiftSyntax

fileprivate extension String {
    var labelExpr: LabeledExprSyntax { .init(expression: self.expr) }
}

public protocol PyCallableProtocol {
    associatedtype S: SyntaxProtocol
    associatedtype P: SyntaxProtocol
    var target: String? { get set }
    var parameters: [P] { get set }
    var parameters_count: Int { get set }
    var returnType: TypeSyntax? { get set }
    var canThrow: Bool { get set }
    var gil: Bool { get set }
    
    init(syntax: S, target: String?, gil: Bool)
    
    var pre_call: CodeBlockItemListSyntax { get }
    
    var code: CodeBlockItemListSyntax { get }
    
    var output: CodeBlockItemListSyntax { get }
}


extension PyCallableProtocol {
//    var callee: ExprSyntax {
//        switch parameters_count {
//        case 0: "PyObject_CallNoArgs"
//        case 1: "PyObject_CallOneArg"
//        default: "PyObject_Vectorcall"
//        }
//    }
    
    var post_call: CodeBlockItemListSyntax {
        .init {
            switch parameters_count {
            case 0: ""
            case 1: "Py_DecRef(arg)"
            default:
                for index in 0..<parameters_count {
                    "Py_DecRef(__args__[\(raw: index)])"
                }
                "__args__.deallocate()"
            }
            
        }
    }
    
    var condition: ConditionElementListSyntax {
        .init {
            ConditionElementSyntax(condition: .expression( " let result = \(raw: call)"))
        }
    }
    
    var call: FunctionCallExprSyntax {
        
        let callee = "_\(target ?? "")"
        
        return switch parameters_count {
        case 0: PyObject_CallNoArgs(call: callee)
        case 1: PyObject_CallOneArg(call: callee, arg: "arg")
        default: PyObject_Vectorcall(call: callee, args: "__args__", nargs: parameters_count)
        }
//        
//        
//        return .init(callee: callee) {
//            "_\(target ?? "")".labelExpr
//            if parameters_count > 0 {
//                switch parameters_count {
//                case 1:
//                    "arg".labelExpr
//                default:
//                    "__args__".labelExpr
//                    LabeledExprSyntax(expression: parameters_count.makeLiteralSyntax())
//                    "nil".labelExpr
//                }
//            }
//        }
    }
    
    var code: CodeBlockItemListSyntax {
        //let manyArgs = parameters_count > 1
        return .init {
            if gil {
                "let gil = PyGILState_Ensure()"
            }
            pre_call
            GuardStmtSyntax(conditions: condition, elseKeyword: .keyword(.else, leadingTrivia: .space)) {
                "PyErr_Print()"
                post_call
                if gil {
                    "PyGILState_Release(gil)"
                }
                if returnType != nil {
                    "fatalError()"
                } else {
                    "return"
                }
                
            }
            post_call
            if let returnType {
                if returnType.isPyPointer {
                    if gil {
                        "PyGILState_Release(gil)"
                    }
                    "return result"
                } else {
                    "let _result = try \(raw: returnType)(object: result)"
                    "Py_DecRef(result)"
                    if gil {
                        "PyGILState_Release(gil)"
                    }
                    "return _result"
                }
                
                    
                
            } else {
                "Py_DecRef(result)"
                if gil {
                    "PyGILState_Release(gil)"
                }
            }
            
        }
    }
    
    public var output: CodeBlockItemListSyntax {
        .init {
            if canThrow {
                DoStmtSyntax(body: .init(statements: code), catchClauses: .standardPyCatchClauses)
                if returnType != nil {
                    "fatalError()"
                } else {
                    "return"
                }
            } else {
                code
            }
        }
    }

}

extension PyCallableProtocol where S == FunctionDeclSyntax, P == FunctionParameterListSyntax.Element {
    
    
    
    var pre_call: CodeBlockItemListSyntax {
        .init {
            switch parameters_count {
            case 0: ""
            case 1:
                let parameter = parameters.first!
                "let arg = \(raw: (parameter.secondName ?? parameter.firstName)).pyPointer"
            default:
                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: parameters_count))"
                for (index, parameter) in parameters.enumerated() {
                    let pname = (parameter.secondName ?? parameter.firstName)
                    "__args__[\(raw: index)] = \(raw: pname).pyPointer"
                }
            }
        }
    }
    
    
    
    
    
    
    
}

let pletters = (97...111).compactMap(UnicodeScalar.init)
extension PyCallableProtocol where S == FunctionTypeSyntax, P == TupleTypeElementListSyntax.Element {
   
    var pre_call: CodeBlockItemListSyntax {
        .init {
            switch parameters_count {
            case 0: ""
            case 1:
                let parameter = parameters.first!
                "let arg = a.pyPointer"
            default:
                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: parameters_count))"
                for (index, parameter) in parameters.enumerated() {
                    let pname = pletters[index]
                    "__args__[\(raw: index)] = \(raw: pname).pyPointer"
                }
            }
        }
    }
    
}

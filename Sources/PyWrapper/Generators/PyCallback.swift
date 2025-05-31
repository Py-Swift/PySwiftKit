//
//  PyCallback.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 04/05/2025.
//
import SwiftSyntax

fileprivate extension String {
    var labelExpr: LabeledExprSyntax { .init(expression: self.expr) }
}

class VectorArgs {
    
    var parameters: [Argument] = []
    
    var count = 0
    
    
    init(parameters: [FunctionParameterSyntax], method: Bool) {
        var start_index = 0
        if method {
            self.parameters.append(.init(parameter: .init(firstName: .identifier("py_target"), type: TypeSyntax.pyPointer), option: .cls("py_target")))
            start_index += 1
        }
        count = parameters.count + start_index
        self.parameters.append(contentsOf: parameters.enumerated().map({ i, parameter in
            .init(parameter: parameter, option: .arg, index: i + start_index)
        }))
    }
    
    
    var pre: CodeBlockItemListSyntax { .init {
        "let __args__ = VectorCallArgs.allocate(capacity: \(raw: count))"
        for parameter in parameters {
            parameter.insert()
        }
    }}
    
    var post: CodeBlockItemListSyntax { .init {
        for parameter in parameters {
            parameter.decref()
        }
        
        deallocate
    }}
    
    var deallocate: CodeBlockItemSyntax {
        "__args__.deallocate()"
    }
    
    struct Argument {
        let no_pyPointer: Bool
        let name: String
        let type: TypeSyntax
        let index: Int
        let option: Option
        
        init(parameter: FunctionParameterSyntax, option: Option, index: Int = 0) {
            self.option = option
            switch option {
            case .arg:
                name = (parameter.secondName ?? parameter.firstName).text
                type = parameter.type
                self.index = index
                no_pyPointer = false
            case .cls(let string):
                name = string
                type = .pyPointer
                self.index = 0
                no_pyPointer = true
            }
            
        }
        
        func insert() -> CodeBlockItemSyntax {
            switch option {
            case .arg:
                "__args__[\(raw: index)] = \(raw: name).pyPointer"
            case .cls(let string):
                "__args__[\(raw: index)] = \(raw: string)"
            }
            
        }
        
        func decref() -> CodeBlockItemSyntax {
            switch option {
            case .arg:
                "Py_DecRef(__args__[\(raw: index)])"
            case .cls(let string):
                ""
            }
        }
    }
    
    enum Option {
        case arg
        case cls(String)
    }
}


public class PyCallGenerator {
    let parameters: [FunctionParameterSyntax]
    let returnType: TypeSyntax?
    let arg_count: Int
    //let function: FunctionDeclSyntax
    let call_name: String
    var canThrow: Bool
    var funcThrows: Bool
    var gil: Bool
    var method: Bool
    
    public init(function: FunctionDeclSyntax, gil: Bool, method: Bool) {
        //self.function = function
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
    
    
}

extension PyCallGenerator {
    public enum Mode {
        case single
        case multi
    }
    
    var callee: ExprSyntax {
        switch arg_count {
        case 0: "PyObject_CallNoArgs"
        case 1: "PyObject_CallOneArg"
        default: "PyObject_Vectorcall"
        }
    }
    
    var call: FunctionCallExprSyntax {
        return .init(callee: callee) {
            "_\(call_name)".labelExpr
            if arg_count > 0 {
                switch arg_count {
                case 1:
                    "arg".labelExpr
                default:
                    "__args__".labelExpr
                    LabeledExprSyntax(expression: (arg_count).makeLiteralSyntax())
                    "nil".labelExpr
                }
            }
        }
    }
}

extension PyCallGenerator {
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
                "let arg = \(raw: (parameter.secondName ?? parameter.firstName)).pyPointer"
            default:
                VectorArgs(parameters: parameters, method: method).pre
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
                VectorArgs(parameters: parameters, method: method).post
            }
            
        }
    }
    
    private var code: CodeBlockItemListSyntax {
        let manyArgs = arg_count > 1
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
                if let returnType {
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


final class PyCallableCodeBlock: PyCallableProtocol {
    
    
    var target: String?
    
    var parameters: [P]
    
    var parameters_count: Int
    
    var returnType: SwiftSyntax.TypeSyntax?
    
    var canThrow: Bool
    
    var gil: Bool
    
    typealias S = FunctionTypeSyntax
    
    typealias P = TupleTypeElementListSyntax.Element
   
    init(syntax: SwiftSyntax.FunctionTypeSyntax, target: String?, gil: Bool) {
        self.target = target
        self.gil = gil
        let parameters = Array(syntax.parameters)
        self.parameters = parameters
        parameters_count = parameters.count
        let rtn = syntax.returnClause
        canThrow = syntax.effectSpecifiers?.throwsClause != nil
//        if parameters.contains(where: {$0.type.canThrow}) {
//            canThrow = true
//        }
        returnType = if rtn.type.trimmedDescription != "Void" {
            rtn.type
        } else { nil }
        if rtn.canThrow {
            canThrow = true
        }
       
    }
}


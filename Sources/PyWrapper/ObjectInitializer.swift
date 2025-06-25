import Foundation
import SwiftSyntaxBuilder
import SwiftSyntax



public class ObjectInitializer {
    
    let cls: String
    let decl: InitializerDeclSyntax?
    let pyInit: Bool
    var options: [Option] = []
    
    public init(cls: String, decl: InitializerDeclSyntax?) {
        self.cls = cls
        self.decl = decl
        if let decl {
            pyInit = true
            let signature = decl.signature
            let parameters = Array(signature.parameterClause.parameters)
            self.parameters = parameters
            if
                signature.effectSpecifiers?.throwsClause != nil,
                parameters.count == 1,
                let firstPar = parameters.first,
                firstPar.firstName.text == "object",
                firstPar.type.isPyPointer
            {
                options.append(.pySerialize_init)
            }
        } else {
            pyInit = false
            parameters = []
        }
    }
    
    var parameters: [FunctionParameterSyntax]
    
    var funcThrows: Bool {
        if let _ =  decl?.signature.effectSpecifiers?.throwsClause?.throwsSpecifier {
            return true
        }
        return false
    }
    
    var canThrow: Bool {
   
        
        return parameters.count > 0//parameters.canThrow
    }
    
    func process() {
        for _ in parameters {
            //parameter.type
        }
    }
}

extension ObjectInitializer {
    
    enum Option {
        case pySerialize_init
    }
    
//    public var output: CodeBlockItemListSyntax { .init {
//        if pyInit {
//            let parameters_count = parameters.count
//            if parameters_count > 0 {
//                DoStmtSyntax(catchClauses: .standardPyCatchClauses) {
//                    for initvar in initVars { initvar }
//                    "let nkwargs = (kw == nil) ? 0 : PyDict_Size(kw)"
//                    if_nkwargs(elseCode: .init {
//                        "let nargs = PyTuple_Size(_args_)"
//                        GuardStmtSyntax.nargs_kwargs(parameters_count)
//                        handle_args_n_kwargs
//                        
//                    })
//                    setPointer()
//                    "return 0"
//                }
//            } else {
//                setPointer()
//                "return 0"
//            }
//        } else {
//            """
//            PyErr_SetString(PyExc_NotImplementedError,"\(raw: cls) can only be inited from swift")
//            """
//            "return -1"
//        }
//        
//    }}
//    
//    
    /*
     { __self__, _args_, kw -> Int32 in
         do {
             let NARGS = 2
             var unit_id: String
             var height: Double
             
             if let kw {
                 let nkwargs = PyDict_Size(kw)
                 if nkwargs >= NARGS {
                     unit_id = try PyDict_GetItem(kw, "unit_id")
                     height = try PyDict_GetItem(kw, "height")
                 } else if let _args_ {
                     let nargs = PyTuple_Size(_args_)
                     guard
                         nkwargs + nargs == NARGS
                     else {
                         PyErr_SetString(PyExc_IndexError, "Args missing requires NARG")
                         return -1
                     }
                     if nargs > 0 {
                         unit_id = try PyTuple_GetItem(_args_, index: 0)
                     } else {
                         unit_id = try PyDict_GetItem(kw, "unit_id")
                     }
                     if nargs > 1 {
                         height = try PyTuple_GetItem(_args_, index: 1)
                     } else {
                         height = try PyDict_GetItem(kw, "height")
                     }
                 } else {
                     PyErr_SetString(PyExc_IndexError, "Args missing requires NARGS")
                     return -1
                 }
             } else if let _args_, PyTuple_Size(_args_) == NARGS {
                 unit_id = try PyTuple_GetItem(_args_, index: 0)
                 height = try PyTuple_GetItem(_args_, index: 1)
             } else {
                 PyErr_SetString(PyExc_IndexError, "Args missing requires NARGS")
                 return -1
             }
             __self__?.pointee.swift_ptr = Unmanaged.passRetained(
                 BannerAd(unit_id: unit_id, height: height)
             ).toOpaque()
             return 0
         } catch let err as PyStandardException {
             err.pyExceptionError()
         } catch let err as PyException {
             err.pyExceptionError()
         } catch let other_error {
             other_error.anyErrorException()
         }
         return -1
     }
     */
    
    var outputNew: CodeBlockItemListSyntax {
        let pcount = parameters.count
        let code = CodeBlockItemListSyntax {
            switch pcount {
            case 0:
                ""
            case 1:
                if let parameter = parameters.first {
                    let name = parameter.secondName ?? parameter.firstName
                    if options.contains(.pySerialize_init) {
                        VariableDeclSyntax(
                            .var,
                            name: .init(stringLiteral: name.text),
                            type: .init(type: parameter.type),
                            initializer: .init(value: "try PySwiftKit.PyTuple_GetItem(\(ForceUnwrapExprSyntax(expression: "__arg__".expr).description), 0)".expr)
                        )
                    } else {
                        if parameter.type.isOptPyPointer || parameter.type.isPyPointer {
                            VariableDeclSyntax(
                                .var,
                                name: .init(stringLiteral: name.text),
                                type: .init(type: parameter.type),
                                initializer: .init(value: "try PySwiftKit.PyTuple_GetItem(\( ForceUnwrapExprSyntax(expression: "__arg__".expr).description), 0)".expr)
                            )
                        } else {
                            VariableDeclSyntax(
                                .var,
                                name: .init(stringLiteral: name.text),
                                type: .init(type: parameter.type),
                                initializer: .init(value: "try PySerializing.PyTuple_GetItem(\(ForceUnwrapExprSyntax(expression: "__arg__".expr).description), index: 0)".expr)
                            )
                        }
//                        VariableDeclSyntax(
//                            .var,
//                            name: .init(stringLiteral: name.text),
//                            type: .init(type: parameter.type),
//                            initializer: .init(value: handleTypes(parameter.type, nil))
//                        )
                    }
                }
            default:
                for parameter in self.parameters {
                    let name = parameter.secondName ?? parameter.firstName
                    VariableDeclSyntax(
                        .var,
                        name: .init(stringLiteral: name.text),
                        type: .init(type: parameter.type)
                    )
                }
                ifKw
            }
            setPointer()
            ReturnStmtSyntax(expression: 0.makeLiteralSyntax())
        }
        return .init {
            // if @PyInit detected
            if pyInit {
                // if init or an argument can throw when error  
                if self.canThrow {
                    DoStmtSyntax(body: .init(statements: code), catchClauses: .standardPyCatchClauses)
                    ReturnStmtSyntax(expression: (-1).makeLiteralSyntax())
                } else {
                    code
                }
            } else {
                """
                PyErr_SetString(PyExc_NotImplementedError,"\(raw: cls) can only be inited from swift")
                """
                ReturnStmtSyntax(expression: (-1).makeLiteralSyntax())
            }
        }
    }
    
    var nargsErrorBody: CodeBlockSyntax {
        .init {"""
            PyErr_SetString(PyExc_IndexError, "Args missing requires NARGS")
            """
            ReturnStmtSyntax(expression: (-1).makeLiteralSyntax())
        }
    }
    
    var ifKw: IfExprSyntax {
        
        let pcount = parameters.count
        
        let kw_con: ConditionElementListSyntax = .init {
            "let kw ".expr
        }
        let args_con: ConditionElementListSyntax = .init {
            "let _args_ ".expr
        }
        
        let nkwargs_con = ConditionElementListSyntax {
            "nkwargs >= \(pcount)".expr
        }
        
        let if_args: IfExprSyntax = .init(conditions: args_con, elseKeyword: .keyword(.else), elseBody: .codeBlock(nargsErrorBody)) {
            "let nargs = PyTuple_Size(_args_)"
            for (i, arg) in self.parameters.enumerated() {
                let name = arg.secondName ?? arg.firstName
                IfExprSyntax.kwOrArg(index: i, key: name.trimmed.text, pyPointer: arg.type.isPyPointer, t: arg.type)
            }
        }
        
        return .init(conditions: kw_con, elseKeyword: .keyword(.else), elseBody: .ifExpr(elseIfArgs)) {
            "let nkwargs = PyDict_Size(kw)"
            IfExprSyntax(conditions: nkwargs_con, elseKeyword: .keyword(.else), elseBody: .ifExpr(if_args)) {
                for parameter in self.parameters {
                    let name = parameter.secondName ?? parameter.firstName
                    if parameter.type.isPyPointer {
                        "\(raw: name) = try PySwiftKit.PyDict_GetItem(kw, \(literal: name.trimmed.text))"
                    } else {
                        "\(raw: name) = try PyDict_GetItem<\(raw: parameter.type)>(kw, key: \(literal: name.trimmed.text))"
                    }
                }
            }
        }
    }
    
    var elseIfArgs: IfExprSyntax {
        let pcount = parameters.count
        let if_arg_con = ConditionElementListSyntax {
            "let _args_".expr
            "PyTuple_Size(_args_) == \(pcount)".expr
        }
        
        return .init(conditions: if_arg_con, elseKeyword: .keyword(.else), elseBody: .codeBlock(nargsErrorBody)) {
            for (i, parameter) in self.parameters.enumerated() {
                let name = parameter.secondName ?? parameter.firstName
                if parameter.type.isPyPointer {
                    "\(raw: name) = try PySwiftKit.PyTuple_GetItem(_args_, \(raw: i))"
                } else {
                    "\(raw: name) = try PyTuple_GetItem<\(raw: parameter.type)>(_args_, index: \(raw: i))"
                }
            }
        }
    }
}


extension IfExprSyntax {
    static func kwOrArg(index: Int, key: String, pyPointer: Bool, t: TypeSyntax) -> Self {
        let if_narg = ConditionElementListSyntax {
            "nargs > \(index)".expr
        }
        
        let elseBody = CodeBlockSyntax {
            if pyPointer {
                "\(raw: key) = try PyDict_GetItem<\(raw: t)>(kw, \(literal: key))"
            } else {
                "\(raw: key) = try PyDict_GetItem<\(raw: t)>(kw, key: \(literal: key))"
            }
        }
        
        return .init(conditions: if_narg, elseKeyword: .keyword(.else), elseBody: .codeBlock(elseBody)) {
            if pyPointer {
                "\(raw: key) = try PySwiftKit.PyTuple_GetItem(_args_, \(raw: index))"
            } else {
                "\(raw: key) = try PyTuple_GetItem<\(raw: t)>(_args_, index: \(raw: index))"
            }
        }
    }
}


fileprivate extension ObjectInitializer {
    
    var initVars: [VariableDeclSyntax] {
        parameters.map { arg in
            VariableDeclSyntax(.var, name: .init(stringLiteral: arg.firstName.text ), type: .init(type: arg.type))
            }
    }
    
    func if_nkwargs(elseCode: CodeBlockItemListSyntax) -> IfExprSyntax {
        let if_con = ConditionElementListSyntax {
            ExprSyntax(stringLiteral: "nkwargs >= \(parameters.count)")
        }
        return .init(
            conditions: if_con,
            body: .init(statements: handleKWArgs() ),
            elseKeyword: .keyword(.else),
            elseBody: .codeBlock(.init(statements: elseCode))
        )
    }
    
    func handleKWArgs() -> CodeBlockItemListSyntax {
        
        return .init {
            for arg in parameters {
                let arg_name = arg.firstName.text
                SequenceExprSyntax(elements: .init(itemsBuilder: {
                    //IdentifierExpr(stringLiteral: arg.name)
                    //ExprSyntax(stringLiteral: "\( arg_name)")
                    arg_name.expr
                    AssignmentExprSyntax()
                    TryExprSyntax.pyDict_GetItem("kw", "\(arg_name)")
                }))
            }
        }
    }
    
//    var handle_args_n_kwargs: CodeBlockItemListSyntax {
//        
//        return .init {
//            for arg in parameters {
//                let con_list = ConditionElementListSyntax {
//                    .init {
//                        SequenceExprSyntax(elements: .init {
//                            //IdentifierExpr(stringLiteral: "__nargs__")
//                            "nargs".expr
//                            BinaryOperatorExprSyntax(operator: .rightAngleToken(leadingTrivia: .space))
//                            0.makeLiteralSyntax()
//                        })
//                    }
//                }
//                IfExprSyntax(
//                    conditions: con_list,
//                    body: .init {
//                        //SequenceExprSyntax(pyTuple: arg)
//                    },
//                    elseKeyword: .keyword(.else),
//                    elseBody: .codeBlock(.init {
//                        //SequenceExprSyntax(pyDict: arg)
//                    })
//                )
//                //                IfStmt(leadingTrivia: .newline, conditions: con_list) {
//                //                    SequenceExprSyntax(pyTuple: arg)
//                //                } elseBody: {
//                //                    SequenceExprSyntax(pyDict: arg)
//                //
//                //                }
//                
//            }
//        }
//        
//        
//    }
    
    func setPointer() -> SequenceExprSyntax {
        //let _throws_ = __init__?.throws ?? false
        let _throws_ = funcThrows
        let cls_unretained = false
        //let unmanaged = IdentifierExpr(stringLiteral: "Unmanaged")
        let unmanaged = ExprSyntax(stringLiteral: "Unmanaged")
//        let _passRetained = MemberAccessExprSyntax(base: unmanaged, dot: .periodToken(), name: .identifier(cls_unretained ? "passUnretained" : "passRetained"))
        let _passRetained = MemberAccessExprSyntax(base: unmanaged, period: .periodToken(), name: .identifier(cls_unretained ? "passUnretained" : "passRetained"))
        var initExpr: ExprSyntaxProtocol {
            if _throws_ {
                return initPySwiftTargetThrows().with(\.leadingTrivia, .newline)
            } else {
                return initPySwiftTarget().with(\.leadingTrivia, .newline)
            }
        }
        
        let pass = FunctionCallExprSyntax(
            calledExpression: _passRetained,
            leftParen: .leftParenToken(),
            arguments: [.init(expression: initExpr)],
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
        
        let toOpaque = FunctionCallExprSyntax(callee: MemberAccessExprSyntax(
            base: pass,
            period: .periodToken(),
            name: .identifier("toOpaque")
        ))
        
        
        return .init {
            //Expr(stringLiteral: "PySwiftObject_Cast(__self__).pointee.swift_ptr")
            //            ExprSyntax(stringLiteral: "PySwiftObject_Cast(__self__).pointee.swift_ptr")
            "__self__?.pointee.swift_ptr".expr
            AssignmentExprSyntax()
            toOpaque
        }
    }
    
    func initPySwiftTarget() -> FunctionCallExprSyntax {
        let id = DeclReferenceExprSyntax(baseName: .identifier(cls))
        
        let tuple = LabeledExprListSyntax {
            if options.contains(.pySerialize_init) {
                LabeledExprSyntax(label: "object", expression: "object".expr)
            } else {
                for parameter in self.parameters {
                    let name = parameter.secondName ?? parameter.firstName
                    LabeledExprSyntax(label: parameter.firstName.text, expression: name.text.expr)
                }
            }
            //LabeledExprSyntax(label: "with", expression: .init(IdentifierExprSyntax(stringLiteral: src)))
            //let many = args.count > 1
//            for arg in args {
//                let arg_name = arg.optional_name ?? arg.name
//                let label = arg.no_label ? nil : arg_name
//                
//                LabeledExprSyntax(label: label, expression: ExprSyntax(stringLiteral: arg_name))
////                if let _arg = arg as? ArgSyntax {
////                    _arg.callTupleElement(many: many)
////                }
//            }
            
        }
        let f_exp = FunctionCallExprSyntax(
            calledExpression: id,
            leftParen: .leftParenToken(),
            arguments: tuple,
            rightParen: .rightParenToken()
        )
        return f_exp
        
        //return TryExprSyntax(tryKeyword: .tryKeyword(trailingTrivia: .space), expression: f_exp)
    }
    
    func initPySwiftTargetThrows() -> TryExprSyntax {
        return .init(expression: initPySwiftTarget())
    }
}

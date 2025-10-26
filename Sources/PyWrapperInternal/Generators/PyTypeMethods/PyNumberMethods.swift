//
//  PyNumberMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax


fileprivate extension String {
    func asLabeledExpr(_ expression: ExprSyntaxProtocol) -> LabeledExprSyntax {
        .init(label: self, expression: expression)
    }
    func asExpr() -> ExprSyntax { .init(stringLiteral: self)}
}


enum PyNumberMethodsEnum: String, CaseIterable {
    case nb_add
    case nb_subtract
    case nb_multiply
    case nb_remainder
    case nb_divmod
    case nb_power
    case nb_negative
    case nb_positive
    case nb_absolute
    case nb_bool
    case nb_invert
    case nb_lshift
    case nb_rshift
    case nb_and
    case nb_xor
    case nb_or
    case nb_int
    case nb_reserved
    case nb_float
    case nb_inplace_add
    case nb_inplace_subtract
    case nb_inplace_multiply
    case nb_inplace_remainder
    case nb_inplace_power
    case nb_inplace_lshift
    case nb_inplace_rshift
    case nb_inplace_and
    case nb_inplace_xor
    case nb_inplace_or
    case nb_floor_divide
    case nb_true_divide
    case nb_inplace_floor_divide
    case nb_inplace_true_divide
    case nb_index
    case nb_matrix_multiply
    case nb_inplace_matrix_multiply
}
extension PyNumberMethodsEnum {
    func getTypeDef() -> PyType_typedefs {
        switch self {
        case .nb_add, .nb_subtract, .nb_multiply, .nb_remainder, .nb_divmod,
                .nb_lshift, .nb_rshift, .nb_and, .nb_xor, .nb_or,
                .nb_inplace_add, .nb_inplace_subtract, .nb_inplace_multiply, .nb_inplace_remainder,
                .nb_inplace_lshift, .nb_inplace_rshift, .nb_inplace_and, .nb_inplace_xor, .nb_inplace_or,
                .nb_floor_divide, .nb_true_divide, .nb_inplace_floor_divide, .nb_inplace_true_divide,
                .nb_matrix_multiply, .nb_inplace_matrix_multiply:
            // Handle binary functions
            return .binaryfunc
        case .nb_power, .nb_inplace_power:
            // Handle ternary function
            return .ternaryfunc
        case .nb_negative, .nb_positive, .nb_absolute, .nb_invert, .nb_int, .nb_float, .nb_index:
            // Handle unary functions
            return .unaryfunc
        case .nb_bool:
            // Handle inquiry function
            return .inquiry
        case .nb_reserved:
            // Handle reserved case
            return .void
        }
    }
    
    
    
}

struct PyNumberMethodsGenerator {
    
    let cls: String
    let external: Bool
    
    var methods: [PyNumberMethodProtocol] {
        var out: [PyNumberMethodProtocol] = []
        for _case in PyNumberMethodsEnum.allCases {
            let typeDef = _case.getTypeDef()
            switch typeDef {
            case .binaryfunc:
                out.append(_binaryfunc(label: _case.rawValue, cls: cls))
            case .ternaryfunc:
                out.append(_ternaryfunc(label: _case.rawValue, cls: cls))
            case .unaryfunc:
                out.append(_unaryfunc(label: _case.rawValue, cls: cls))
            case .inquiry:
                out.append(_inquiry(label: _case.rawValue, cls: cls))
            case .void:
                out.append(_void(label: _case.rawValue, cls: cls))
            default: continue
            }
        }
        return out
    }
    
    var variDecl: VariableDeclSyntax {
        let call = FunctionCallExprSyntax(callee: ".PySwiftMethods".expr) {
            let methods = methods
            let size = methods.count - 1
            for (i, method) in methods.enumerated() {
                switch i {
                case 0: method.labeledExpr().newLineTab.with(\.leadingTrivia, .newline)
                case size:
                    method.labeledExpr()
                    
                default:
                    
                    if method.label != "nb_reserved" {
                        method.labeledExpr().newLineTab
                    } else {
                        method.label.asLabeledExpr(NilLiteralExprSyntax())
                    }
                }
            }
            
        }.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
        let modifiers = DeclModifierListSyntax {
            if !external {
                DeclModifierSyntax.static
            } else {
                DeclModifierSyntax.fileprivate
            }
        }
        return .init(
            leadingTrivia: .lineComment("// #### PyNumberMethods ####").appending(.newlines(2) as Trivia),
            modifiers: modifiers, .var,
            name: .init(stringLiteral: external ? "\(cls)_tp_as_number" : "tp_as_number"),
            type: .init(type: TypeSyntax(stringLiteral: "PyNumberMethods")),
            initializer: .init(value: call)
        ).with(\.trailingTrivia, .newlines(2))
        
    }
}

protocol PyNumberMethodProtocol {
    var label: String { get }
    var cls: String { get }
    var type: PyType_typedefs { get }
    func closureExpr() -> ClosureExprSyntax
    //func _protocol() -> FunctionDeclSyntax?
}

extension PyNumberMethodProtocol {
    func labeledExpr() -> LabeledExprSyntax {
        //label.asLabeledExpr(closureExpr())
       // label.asLabeledExpr(unsafeBitCast(pymethod: closureExpr(), from: "PySwift_\(type)", to: "\(type).self"))
        label.asLabeledExpr(closureExpr())
    }
}

fileprivate func unPackSelf(_ cls: String, arg: String = "__self__") -> ExprSyntax {
    //.UnPackPySwiftObject(cls, arg: arg)
    "Unmanaged<\(raw: cls)>.fromOpaque(\(raw: arg).pointee.swift_ptr).takeUnretainedValue()"
}

extension PyNumberMethodsGenerator {
    struct _binaryfunc: PyNumberMethodProtocol {
        let label: String
        let cls: String
        let type: PyType_typedefs = .binaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .binaryfunc {
                """
                if let __self__, let o {
                    \(raw: unPackSelf(cls)).\(raw: label)(o)
                } else { nil }
                """
            }
        }
    }
    
    struct _ternaryfunc: PyNumberMethodProtocol {
        let label: String
        let cls: String
        let type: PyType_typedefs = .ternaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .ternaryfunc {
                """
                if let __self__, let o {
                    \(raw: unPackSelf(cls)).\(raw: label)(o, kw)
                } else { nil }
                """
            }
        }
    }
    
    struct _unaryfunc: PyNumberMethodProtocol {
        let label: String
        let cls: String
        let type: PyType_typedefs = .unaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .unaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).\(raw: label)()
                } else { nil }
                """
            }
        }
    }
    
    // inquiry
    struct _inquiry: PyNumberMethodProtocol {
        let label: String
        let cls: String
        let type: PyType_typedefs = .inquiry
        
        func closureExpr() -> ClosureExprSyntax {
            .inquiry {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).\(raw: label)()
                } else { 0 }
                """
            }
        }
    }
    
    // void
    struct _void: PyNumberMethodProtocol {
        let label: String
        let cls: String
        let type: PyType_typedefs = .void
        
        func closureExpr() -> ClosureExprSyntax {
            .void {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).\(raw: label)()
                }
                """
                //"return 0"
            }
        }
    }
}


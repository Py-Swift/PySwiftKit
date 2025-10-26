
//
//  PySequenceMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 03/05/2025.
//

import Foundation
import SwiftSyntax

fileprivate extension String {
	func asLabeledExpr(_ expression: ExprSyntaxProtocol) -> LabeledExprSyntax {
		.init(label: self, expression: expression)
	}
	func asExpr() -> ExprSyntax { .init(stringLiteral: self)}
}


/*
 typedef struct {
 lenfunc sq_length; 0
 binaryfunc sq_concat; 1
 ssizeargfunc sq_repeat; 2
 ssizeargfunc sq_item; 3
 void *was_sq_slice; 4
 ssizeobjargproc sq_ass_item; 5
 void *was_sq_ass_slice; 6
 objobjproc sq_contains; 7
 
 binaryfunc sq_inplace_concat; 8
 ssizeargfunc sq_inplace_repeat; 9
 } PySequenceMethods;
 
 
 
 
*/
struct PySequenceMethodsGenerator {
	
	let cls: String
    let external: Bool
	
	var methods: [any PySequenceMethodProtocol] {
		return [
			_sq_length(cls: cls),
			_sq_concat(cls: cls),
			_sq_repeat(cls: cls),
			_sq_item(cls: cls),
			_sq_ass_item(cls: cls),
			_sq_contains(cls: cls),
			_sq_inplace_concat(cls: cls),
			_sq_inplace_repeat(cls: cls)
		]
	}
	
	var variDecl: VariableDeclSyntax {
		var _methods = methods.compactMap({$0.labeledExpr()})
		_methods.insert(
			"was_sq_slice".asLabeledExpr(NilLiteralExprSyntax()),
			at: 4
		)
		_methods.insert(
			"was_sq_ass_slice".asLabeledExpr(NilLiteralExprSyntax()),
			at: 6
		)
        let call = FunctionCallExprSyntax(callee: "PySequenceMethods".expr) {
			let last = _methods.count - 1
			for (i, method) in _methods.enumerated() {
				switch i {
				case 0: method.newLineTab.with(\.leadingTrivia, .newline)
				case last: method//.labeledExpr()
				default: method.newLine//.labeledExpr().newLineTab
				}
				
			}
		}.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
        
        let name = external ? "\(cls)_tp_as_sequence" : "tp_as_sequence"
        let modifiers = DeclModifierListSyntax {
            if external {
                DeclModifierSyntax.fileprivate
            } else {
                DeclModifierSyntax.static
            }
        }
		return .init(
			leadingTrivia: .lineComment("// #### PySequenceMethods ####").appending(.newlines(2) as Trivia),
            modifiers: modifiers, .var,
            name: .init(stringLiteral: name),
			type: nil,//.init(type: TypeSyntax(stringLiteral: "PySequenceMethods")),
			initializer: .init(value: call)
		).with(\.trailingTrivia, .newlines(2))
		
	}
	
    init(cls: String, external: Bool = false) {
		self.cls = cls
        self.external = external
	}
	
}

protocol PySequenceMethodProtocol {
	var label: String { get }
	var cls: String { get }
	var type: PyType_typedefs { get }
	func closureExpr() -> ClosureExprSyntax
	//func _protocol() -> FunctionDeclSyntax
}

extension PySequenceMethodProtocol {
	func labeledExpr() -> LabeledExprSyntax {
		//label.asLabeledExpr(closureExpr())
		label.asLabeledExpr(unsafeBitCast(pymethod: closureExpr(), from: "PySwift_\(type)", to: "\(type).self"))
	}
}

fileprivate func unPackSelf(_ cls: String, arg: String = "__self__") -> ExprSyntax {
    //.UnPackPySwiftObject(cls, arg: arg)
    "Unmanaged<\(raw: cls)>.fromOpaque(\(raw: arg).pointee.swift_ptr).takeUnretainedValue()"
}

extension PySequenceMethodsGenerator {
	
	
	
	struct _sq_length: PySequenceMethodProtocol {
		let label = "sq_length"
		let cls: String
		let type: PyType_typedefs = .lenfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .lenfunc {
			"""
			if let __self__ {
				\(raw: unPackSelf(cls)).__len__()
			} else { 0 }
			"""
			}
		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __len__() -> Int
			""")
		}
	}
	
	struct _sq_concat: PySequenceMethodProtocol {
		let label = "sq_concat"
		let cls: String
		let type: PyType_typedefs = .binaryfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .binaryfunc {
                """
                if let __self__, let o {
                    \(raw: unPackSelf(cls)).__add__(o)
                } else { nil }
                """
			}
		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __add__(_ other: PyPointer?) -> PyPointer?
			""")
		}
	}
	
	struct _sq_repeat: PySequenceMethodProtocol {
		let label = "sq_repeat"
		let cls: String
		let type: PyType_typedefs = .ssizeargfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .ssizeargfunc {
				"""
				if let __self__ {
					\(raw: unPackSelf(cls)).__mul__(i)
				} else { nil }
				"""
			}
		}
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __mul__(_ n: Int) -> PyPointer?
			""")
		}
	}
	
	struct _sq_item: PySequenceMethodProtocol {
		let label = "sq_item"
		let cls: String
		let type: PyType_typedefs = .ssizeargfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .ssizeargfunc {
				"""
				if let __self__ {
					\(raw: unPackSelf(cls)).__getitem__(i)
				} else { nil }
				"""
			}
		}
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __getitem__(_ i: Int) -> PyPointer?
			""")
		}
	}

	struct _sq_ass_item: PySequenceMethodProtocol {
		let label = "sq_ass_item"
		let cls: String
		let type: PyType_typedefs = .ssizeobjargproc
		
		func closureExpr() -> ClosureExprSyntax {
            .ssizeobjargproc {
				"""
				if let __self__ {
					\(raw: unPackSelf(cls)).__setitem__(i, o)
				} else { 0 }
				"""
			}
		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __setitem__(_ i: Int,_ item: PyPointer?) -> Int32
			""")
		}
		
	}
	
	struct _sq_contains: PySequenceMethodProtocol {
		let label = "sq_contains"
		let cls: String
		let type: PyType_typedefs = .objobjproc
		
		func closureExpr() -> ClosureExprSyntax {
            .objobjproc {
				"""
				if let __self__, let x {
					\(raw: unPackSelf(cls)).__contains__(x)
				} else { 0 }
				"""
			}
		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __contains__(_ item: PyPointer?) -> Int32
			""")
		}
	}
	
	struct _sq_inplace_concat: PySequenceMethodProtocol {
		let label = "sq_inplace_concat"
		let cls: String
		let type: PyType_typedefs = .binaryfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .binaryfunc {
				"""
				if let __self__, let o {
					\(raw: unPackSelf(cls)).__iadd__(o)
				} else { nil }
				"""
			}
		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __iadd__(_ item: PyPointer?) -> PyPointer?
			""")
		}
	}
	
	struct _sq_inplace_repeat: PySequenceMethodProtocol {
		let label = "sq_inplace_repeat"
		let cls: String
		let type: PyType_typedefs = .ssizeargfunc
		
		func closureExpr() -> ClosureExprSyntax {
            .ssizeargfunc {
				"""
				if let __self__ {
					\(raw: unPackSelf(cls)).__imul__(i)
				} else { nil }
				"""
			}

		}
		
		func _protocol() -> FunctionDeclSyntax {
			try! .init("""
			func __imul__(_ n: Int) -> PyPointer?
			""")
		}
	}
}


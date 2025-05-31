//
//  PyMappingMethodsGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import Foundation
import SwiftSyntax

protocol PyMappingMethodProtocol {
    var label: String { get }
    var cls: String { get }
    var type: PyType_typedefs { get }
    func closureExpr() -> ClosureExprSyntax
    func _protocol() -> FunctionDeclSyntax
}

extension PyMappingMethodProtocol {
    func labeledExpr() -> LabeledExprSyntax {
        .init(label: label, expression: unsafeBitCast(pymethod: closureExpr(), from: "PySwift_\(type)", to: "\(type).self"))
    }
}

struct PyMappingMethodsGenerator {
	
    let cls: String
    let external: Bool
	
	var methods: [any PyMappingMethodProtocol] {
		return [
			_mp_length(cls: cls),
			_mp_subscript(cls: cls),
			_mp_ass_subscript(cls: cls),
		]
	}
	
	var variDecl: VariableDeclSyntax {
        let call = FunctionCallExprSyntax(callee: ".init".expr) {
			_mp_length(cls: cls).labeledExpr().with(\.leadingTrivia, .newline).newLineTab
			_mp_subscript(cls: cls).labeledExpr().newLineTab
			_mp_ass_subscript(cls: cls).labeledExpr()
		}.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
        let name = external ? "\(cls)_tp_as_mapping" : "tp_as_mapping"
        let modifiers = DeclModifierListSyntax {
            if external {
                DeclModifierSyntax.fileprivate
            } else {
                DeclModifierSyntax.static
            }
        }
		return .init(
			leadingTrivia: .lineComment("// #### PyMappingMethods ####").appending(.newlines(2) as Trivia),
            modifiers: modifiers, .var,
			name: .init(stringLiteral: name),
			type: .init(type: TypeSyntax(stringLiteral: "PyMappingMethods")),
			initializer: .init(value: call)
		).with(\.trailingTrivia, .newlines(2))
		
	}
	
    init(cls: String, external: Bool = false) {
		self.cls = cls
        self.external = external
	}
	
}

fileprivate func unPackSelf(_ cls: String, arg: String = "__self__") -> ExprSyntax {
    //.UnPackPySwiftObject(cls, arg: arg)
    "Unmanaged<\(raw: cls)>.fromOpaque(\(raw: arg).pointee.swift_ptr).takeUnretainedValue()"
}

extension PyMappingMethodsGenerator {
    
    
    
    struct _mp_length: PyMappingMethodProtocol {
        let label = "mp_length"
        let cls: String
        let type: PyType_typedefs = .lenfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .lenfunc {"""
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
    
    struct _mp_subscript: PyMappingMethodProtocol {
        let label = "mp_subscript"
        let cls: String
        let type: PyType_typedefs = .binaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .binaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__getitem__(o)
                } else { nil }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __getitem__(_ key: PyPointer?) -> PyPointer?
            """)
        }
    }
    
    struct _mp_ass_subscript: PyMappingMethodProtocol {
        let label = "mp_ass_subscript"
        let cls: String
        let type: PyType_typedefs = .objobjargproc
        
        func closureExpr() -> ClosureExprSyntax {
            .objobjargproc {
                """
                if let __self__, let x {
                    \(raw: unPackSelf(cls)).__setitem__(x, y)
                } else { 0 }
                """
            }
        }
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __setitem__(_ key: PyPointer?,_ item: PyPointer?) -> Int32
            """)
        }
    }
    
    
}

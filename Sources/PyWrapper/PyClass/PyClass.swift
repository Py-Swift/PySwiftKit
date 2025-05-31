//
//  PyClass.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import SwiftSyntax
import SwiftSyntaxBuilder
import PyWrapperInfo

public class PyClass {
    let name: String
    var initDecl: InitializerDeclSyntax?
    var bases: [PyClassBase]
    var unretained: Bool
    var external: Bool
    
    public init(name: String, cls: ClassDeclSyntax, bases: [PyClassBase] = [], unretained: Bool = false, external: Bool = false) {
        self.name = name
        self.bases = bases
        self.unretained = unretained
        self.external = external
        if cls.isPyContainer {
            let signature = FunctionSignatureSyntax.init(
                parameterClause: .init(parameters: .init {
                    FunctionParameterSyntax(stringLiteral: "object: PyPointer")
                }),
                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
            )
            initDecl = .init(signature: signature)
        } else {
            let inits = cls.memberBlock.members.compactMap { member in
                switch member.decl.as(DeclSyntaxEnum.self) {
                case .initializerDecl(let initializer):
                    if initializer.attributes.contains(where: \.isPyInit) {
                        return initializer
                    }
                default: break
                }
                return nil
            }
            initDecl = inits.first
        }
    }
    
    public init(name: String, ext: ExtensionDeclSyntax, bases: [PyClassBase] = [], unretained: Bool = false, external: Bool = false) {
        self.name = name
        self.bases = bases
        self.unretained = unretained
        self.external = external
        let inits = ext.memberBlock.members.compactMap { member in
            let decl = member.decl
            if decl.kind == .initializerDecl {
                return decl.as(InitializerDeclSyntax.self)
            }
            return nil
        }
        initDecl = inits.first
    }
    
}

extension PyClass {
    
    var extensionType: TypeSyntax { .init(stringLiteral: name) }
    
    public func decls() throws -> [DeclSyntax] {
        
        var out: [DeclSyntax] = [
            tp_new().declSyntax,
            tp_init(nil).declSyntax,
            tp_dealloc().declSyntax
        ]
        let name = name
        let base_methods = bases.lazy.compactMap {[unowned self] base -> VariableDeclSyntax? in
            switch base {
            case .async:
                PyAsyncMethodsGenerator(cls: name).variDecl
            case .sequence:
                PySequenceMethodsGenerator(cls: name).variDecl
            case .mapping:
                PyMappingMethodsGenerator(cls: name).variDecl
            case .buffer:
                nil
            case .number:
                PyNumberMethodsGenerator(cls: name, external: false).variDecl
            case .hash:
                tp_hash(target: name)
            case .str:
                tp_str(target: name)
            case .repr:
                tp_repr(target: name)
            default:
                nil
            }
        }
        out.append(contentsOf: base_methods.map(\.declSyntax))
        
        return out
    }
    
    public func extensions() throws -> ExtensionDeclSyntax {
        .init(modifiers: [], extendedType: extensionType) {
            if !external {
                tp_new()
                tp_init(nil)
                tp_dealloc()
                
                
                
                for base in self.bases {
                    switch base {
                    case .async:
                        PyAsyncMethodsGenerator(cls: name).variDecl
                    case .sequence:
                        PySequenceMethodsGenerator(cls: name).variDecl
                    case .mapping:
                        PyMappingMethodsGenerator(cls: name).variDecl
                    case .buffer:
                        ""
                    case .number:
                        PyNumberMethodsGenerator(cls: name, external: false).variDecl
                    case .hash:
                        tp_hash(target: name)
                    case .str:
                        tp_str(target: name)
                    case .repr:
                        tp_repr(target: name)
                    default:
                        ""
                    }
                }
            }
            self.asPyPointer(nil)
            self.asUnretainedPyPointer(nil)
        }
    }
    
    public func externalDecls() throws -> [DeclSyntax] {
        var output: [DeclSyntaxProtocol] = [
            _tp_new(),
            _tp_init(nil),
            _tp_dealloc()
        ]
        output.append(
            contentsOf: self.bases.compactMap{ base -> VariableDeclSyntax? in
                switch base {
                case .async:
                    PyAsyncMethodsGenerator(cls: name, external: true).variDecl
                case .sequence:
                    PySequenceMethodsGenerator(cls: name, external: true).variDecl
                case .mapping:
                    PyMappingMethodsGenerator(cls: name, external: true).variDecl
                case .buffer:
                    PyBufferGenerator(cls: name, external: true).variDecl
                case .number:
                    PyNumberMethodsGenerator(cls: name, external: true).variDecl
                case .hash:
                    _tp_hash(target: name)
                case .str:
                    _tp_str(target: name)
                case .repr:
                    _tp_repr(target: name)
                default:
                    nil
                }
            }
        )
        
        return output.map(DeclSyntax.init)
    }
}


public extension PyClass {
    
    var create_tp_init_new: ClosureExprSyntax {
        .initproc {
            
        }
    }
    
    var create_tp_init: ClosureExprSyntax {
 
        let closure = if let initDecl {
            ExprSyntax(stringLiteral: "{ __self__, \(initDecl.signature.parameterClause.parameters.count > 1 ? "_args_" : "__arg__"), kw -> Int32 in }").as(ClosureExprSyntax.self)!
        } else {
            ExprSyntax(stringLiteral: "{ _, _, _ -> Int32 in }").as(ClosureExprSyntax.self)!
        }
        return closure.with(\.statements, .init {
            ObjectInitializer(cls: name, decl: initDecl).outputNew
        })
        
    }
    
    func tp_init(_ external_name: String?) -> VariableDeclSyntax {
        
        return .init(
            modifiers: [ .static ], .var,
            name: .init(stringLiteral: external_name ?? "tp_init"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_initproc")),
            initializer: .init(value: create_tp_init)
        ).with(\.trailingTrivia, .newlines(2))
    }
    
    func _tp_init(_ target: String?) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .fileprivate ], .let,
            name:  .init(stringLiteral: "\(target ?? name)_tp_init"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_initproc")),
            initializer: .init(value: create_tp_init)
        ).with(\.trailingTrivia, .newlines(2))
    }
    
    func tp_new() -> VariableDeclSyntax {

        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
//            modifiers: [.init(name: .keyword(.fileprivate)), .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_new"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_newfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { type, _, _ -> PyPointer? in PySwiftObject_New(type) }                
                """))
        ).with(\.leadingTrivia, .newlines(2)).with(\.trailingTrivia, .newlines(2))
    }
    
    func _tp_new()-> FunctionDeclSyntax {
        let parameters: FunctionParameterListSyntax = .init {
            FunctionParameterSyntax(firstName: .identifier("type"), type: TypeSyntax(stringLiteral: "UnsafeMutablePointer<PyTypeObject>?"))
            FunctionParameterSyntax(firstName: .identifier("args"), type: TypeSyntax.optPyPointer)
            FunctionParameterSyntax(firstName: .identifier("kwargs"), type: TypeSyntax.optPyPointer)
        }
        let signature: FunctionSignatureSyntax = .init(parameterClause: .init(parameters: parameters), returnClause: .init(type: TypeSyntax.optPyPointer))
        return .init(
            modifiers: [.fileprivate],
            name: .init(stringLiteral: "\(name)_tp_new"),
            signature: signature,
            body: """
            { PySwiftObject_New(type) }
            """
        )
    }
    
    func tp_dealloc(target: String? = nil) -> VariableDeclSyntax {
        
        return .init(
            modifiers: [ .static ], .var,
            name: .init(stringLiteral: "tp_dealloc"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_destructor")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
            { s in
            if let ptr = s?.pointee.swift_ptr {
            Unmanaged<\(target ?? name)>.fromOpaque(ptr).release()
            }
            }
            """)).with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func _tp_dealloc(target: String? = nil) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .fileprivate ], .let,
            name: .init(stringLiteral: "\(target ?? name)_tp_dealloc"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_destructor")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
            { s in
            if let ptr = s?.pointee.swift_ptr {
            Unmanaged<\(target ?? name)>.fromOpaque(ptr).release()
            }
            }
            """)).with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func asPyPointer(_ external_name: String?) -> DeclSyntax {
        let pytype_name = if let external_name { "\(external_name)_PyType"} else { "\(name).PyType" }
        return """
        public static func asPyPointer(_ target: \(raw: name)) -> PyPointer {
            let new = PySwiftObject_New(\(raw: pytype_name))
            PySwiftObject_Cast(new).pointee.swift_ptr = Unmanaged.passRetained(target).toOpaque()
            return new!
        }
        """
    }
    
    func asUnretainedPyPointer(_ external_name: String?) -> DeclSyntax {
        let pytype_name = if let external_name { "\(external_name)_PyType"} else { "\(name).PyType" }
        return """
        public static func asPyPointer(unretained target: \(raw: name)) -> PyPointer {
            let new = PySwiftObject_New(\(raw: pytype_name))
            PySwiftObject_Cast(new).pointee.swift_ptr = Unmanaged.passUnretained(target).toOpaque()
            return new!
        }
        """
    }
    
    func tp_hash(target: String) -> VariableDeclSyntax {
        let expr = ExprSyntax(stringLiteral: """
            { __self__ -> Int in
                Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__hash__()
            }
            """).as(ClosureExprSyntax.self)!
        
        return .init(
            modifiers: [ .static], .var,
            name: .init(stringLiteral: "tp_hash"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_hashfunc")),
            initializer: .init(value: expr).with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func _tp_hash(target: String) -> VariableDeclSyntax {
        let expr = ExprSyntax(stringLiteral: """
            { __self__ -> Int in
                Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__hash__()
            }
            """).as(ClosureExprSyntax.self)!
        
        return .init(
            modifiers: [ .fileprivate ], .let,
            name: .init(stringLiteral: "\(target ?? name)_tp_hash"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_hashfunc")),
            initializer: .init(value: expr).with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func tp_str(target: String) -> VariableDeclSyntax {
        return .init(
            modifiers: [.static ], .var,
            name: .init(stringLiteral: "tp_str"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_reprfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { __self__ in
                    Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__str__().pyPointer
                }
                """)
            )//.with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func _tp_str(target: String) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .fileprivate ], .let,
            name: .init(stringLiteral: "\(target ?? name)_tp_str"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_reprfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { __self__ in
                    Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__str__().pyPointer
                }
                """)
            )
        )
    }
    
    func tp_repr(target: String) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .static ], .var,
            name: .init(stringLiteral: "tp_repr"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_reprfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { __self__ in
                    Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__repr__().pyPointer
                }
                """)
            )//.with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func _tp_repr(target: String) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .fileprivate ], .let,
            name: .init(stringLiteral: "\(target)_tp_repr"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_reprfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { __self__ in
                    Unmanaged<\(target)>.fromOpaque(__self__!.pointee.swift_ptr).takeUnretainedValue().__repr__().pyPointer
                }
                """)
            )
        )
    }
    
}

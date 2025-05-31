//
//  PySwiftClassGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapper
import PyWrapperInfo


class PyClassArguments {
    
    var name: String?
    var bases: [PyClassBase] = []
    var unretained = false
    var base_type: TypeSyntax?
    var external: Bool = false
    
    init(node: AttributeSyntax) {
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let labeledExprList):
                for arg in labeledExprList {
                    guard let label = arg.label, let arg_name = Argument(rawValue: label.text) else { continue }
                    
                    switch arg_name {
                    case .name:
                        if let string = arg.expression.as(StringLiteralExprSyntax.self) {
                            name = string.segments.description
                        }
                    case .unretained:
                        unretained = .init(arg.expression.description) ?? false
                    case .bases:
                        switch arg.expression.as(ExprSyntaxEnum.self) {
                        case .arrayExpr(let arrayExpr):
                            bases = arrayExpr.elements.compactMap { element in
                                if let enum_case = element.expression.as(MemberAccessExprSyntax.self) {
                                    PyClassBase(rawValue: enum_case.declName.baseName.text)
                                } else { nil }
                            }
                        case .memberAccessExpr(let memberAccessExpr):
                            if memberAccessExpr.declName.baseName.text == "all" {
                                bases = .all
                            }
                        default: break
                        }
                    case .base_type:
                        switch arg.expression.as(ExprSyntaxEnum.self) {
                        case .memberAccessExpr(let memberAccessExpr):
                            if let base = memberAccessExpr.base {
                                switch base.as(ExprSyntaxEnum.self) {
                                case .declReferenceExpr(let declRef):
                                    base_type = declRef.baseName.text.typeSyntax()
                                default: break
                                }
                            }
                        default: break
                        }
                    case .external:
                        if let bool = arg.expression.as(BooleanLiteralExprSyntax.self) {
                            external = Bool(bool.literal.text) ?? false
                        }
                    }
                }
            default: break
            }
        }
    }
    
    
    enum Argument: String {
        case name
        case unretained
        case bases
        case base_type
        case external
    }
}

final class PyClassResult {
    var py_functions: [FunctionDeclSyntax]
    var py_properties: [VariableDeclSyntax]
    var py_cls: PyClass
    var type_struct: PyTypeObjectStruct
    var decls: [DeclSyntax]
    
    init(py_functions: [FunctionDeclSyntax], py_properties: [VariableDeclSyntax], py_cls: PyClass, type_struct: PyTypeObjectStruct, decls: [DeclSyntax]) {
        self.py_functions = py_functions
        self.py_properties = py_properties
        self.py_cls = py_cls
        self.type_struct = type_struct
        self.decls = decls
    }
    
    static func new(classDecl: ClassDeclSyntax, info: PyClassArguments) throws -> Self {
        let cls_name = classDecl.name.text
        let members = classDecl.memberBlock.members
        let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                fdecl
            } else { nil }
        }
        
        let py_properties = members.compactMap { member -> VariableDeclSyntax? in
            let decl = member.decl
            return if decl.is(VariableDeclSyntax.self), let vdecl = decl.as(VariableDeclSyntax.self), vdecl.isPyProperty {
                vdecl
            } else { nil }
        }
        
        let hasMethods = py_functions.count > 0
        let hasGetSets = py_properties.count > 0
        
        let type_struct = PyTypeObjectStruct(
            name: cls_name,
            pyname: info.name ?? cls_name,
            bases: info.bases,
            unretained: info.unretained,
            hasMethods: hasMethods,
            hasGetSets: hasGetSets,
            external: true
        )
        let py_cls = PyClass(
            name: cls_name,
            cls: classDecl,
            bases: info.bases,
            unretained: info.unretained,
            external: true
        )
        var decls: [DeclSyntax] = try py_cls.externalDecls() + [
            "\nfileprivate var \(raw: cls_name)_pyTypeObject = \(raw: type_struct.output)",
            .init(type_struct.createPyType())
        ]
        
        if hasGetSets {
            let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties, external: info.external)
            decls.append(getsets.output)
        }
        if hasMethods {
            decls.append(PyMethods(cls: cls_name, input: py_functions, external: info.external).output)
        }
        
        return .init(py_functions: py_functions, py_properties: py_properties, py_cls: py_cls, type_struct: type_struct, decls: decls)
    }
    
    static func new(extDecl: ExtensionDeclSyntax, info: PyClassArguments, arguments: LabeledExprListSyntax) throws -> Self {
        let cls_name = extDecl.extendedType.trimmedDescription
        let members = extDecl.memberBlock.members
        var py_functions = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                fdecl
            } else { nil }
        }
        
        var py_properties = members.compactMap { member -> VariableDeclSyntax? in
            let decl = member.decl
            return if decl.is(VariableDeclSyntax.self), let vdecl = decl.as(VariableDeclSyntax.self), vdecl.isPyProperty {
                vdecl
            } else { nil }
        }
        
        let py_ext = try PyClassByExtensionUnpack(arguments: arguments)
        py_functions.append(contentsOf: py_ext.functions)
        py_properties.append(contentsOf: py_ext.properties)
        
        let hasMethods = py_functions.count > 0
        let hasGetSets = py_properties.count > 0
        
        let type_struct = PyTypeObjectStruct(
            name: cls_name,
            pyname: info.name ?? cls_name,
            bases: info.bases,
            unretained: info.unretained,
            hasMethods: hasMethods,
            hasGetSets: hasGetSets,
            external: true
        )
        let py_cls = PyClass(
            name: cls_name,
            ext: extDecl,
            bases: info.bases,
            unretained: info.unretained,
            external: true
        )
        var decls: [DeclSyntax] = try py_cls.externalDecls() + [
            "\nfileprivate var \(raw: cls_name)_pyTypeObject = \(raw: type_struct.output)",
            .init(type_struct.createPyType()),
            py_cls.asPyPointer(cls_name),
            py_cls.asUnretainedPyPointer(cls_name)
        ]
        
        if hasGetSets {
            let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties, external: info.external)
            decls.append(getsets.output)
        }
        if hasMethods {
            decls.append(PyMethods(cls: cls_name, input: py_functions, external: info.external).output)
        }
        
        return .init(py_functions: py_functions, py_properties: py_properties, py_cls: py_cls, type_struct: type_struct, decls: decls)
    }
    
}

struct PySwiftClassGenerator: MemberMacro {
    
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        
//        guard
//            node.attributeName.description == "PyClass"
//        else { return []}
        
        let info = PyClassArguments(node: node)
        let members = Array(declaration.memberBlock.members)
        //
        switch declaration.kind {
        case .classDecl:
            if info.external { return [] }
            let cls_decl = declaration.cast(ClassDeclSyntax.self)
            
            
            let cls_name = cls_decl.name.text
            
            let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
                let decl = member.decl
                return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                    fdecl
                } else { nil }
            }
            
            let py_properties = members.compactMap { member -> VariableDeclSyntax? in
                let decl = member.decl
                return if decl.is(VariableDeclSyntax.self), let vdecl = decl.as(VariableDeclSyntax.self), vdecl.isPyProperty {
                    vdecl
                } else { nil }
            }
            
            let hasMethods = py_functions.count > 0
            let hasGetSets = py_properties.count > 0
            
            let type_struct = PyTypeObjectStruct(
                name: cls_name,
                pyname: info.name ?? cls_name,
                bases: info.bases,
                unretained: info.unretained,
                hasMethods: hasMethods,
                hasGetSets: hasGetSets,
                external: info.external
            )
//            let py_cls = PyClass(
//                name: cls_name,
//                cls: cls_decl,
//                bases: info.bases,
//                unretained: info.unretained
//            )
            var decls: [DeclSyntax] = [
                "\nstatic var pyTypeObject = \(raw: type_struct.output)",
                .init(type_struct.createPyType())
            ]
            
            if hasGetSets {
                let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties)
                decls.append(getsets.output)
            }
            if hasMethods {
                decls.append(PyMethods(cls: cls_decl.name.text, input: py_functions).output)
            }
                
            return decls
            
        case .extensionDecl:
            if info.external { return [] }
            guard let extDecl = declaration.as(ExtensionDeclSyntax.self) else { fatalError("not ext")}
            let cls_name = extDecl.extendedType.trimmedDescription
            
            
//            let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
//                let decl = member.decl
//                return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
//                    fdecl
//                } else { nil }
//            }
//
            
            var py_properties = [VariableDeclSyntax]()
            var methods = [FunctionDeclSyntax]()
            
            for member in members {
                let decl = member.decl
                switch decl.kind {
                case .variableDecl:
                    if let v = decl.as(VariableDeclSyntax.self), v.isPyProperty {
                        py_properties.append(v)
                    }
                case .functionDecl:
                    if let f = decl.as(FunctionDeclSyntax.self), f.isPyMethod {
                        methods.append(f)
                    }
                case .macroExpansionDecl:
                    if let exp = member.decl.as(MacroExpansionDeclSyntax.self), exp.macroName.text == "PyWrapCode" {
//                        let pywrapcode = try PyWrapCodeArguments(arguments: exp.arguments)
//                        py_properties.append(contentsOf: pywrapcode.properties)
//                        methods.append(contentsOf: pywrapcode.functions)
                    }
                default: continue
                }
            }
            var bases: [PyClassBase] = []
            if let arguments = node.arguments {
                switch arguments {
                case .argumentList(let listexpr):
                    let py_ext = try PyClassByExtensionUnpack(arguments: listexpr)
                    bases = py_ext.bases
                    methods.append(contentsOf: py_ext.functions)
                    py_properties.append(contentsOf: py_ext.properties)
                default: break
                }
                
            }
            
            let hasMethods = methods.count > 0
            let hasGetSets = py_properties.count > 0
            
            let type_struct = PyTypeObjectStruct(
                name: cls_name,
                pyname: info.name ?? cls_name,
                bases: bases,
                unretained: info.unretained,
                hasMethods: hasMethods,
                hasGetSets: hasGetSets,
                external: info.external
            )
            
            
            
            let py_cls = PyClass(
                name: cls_name,
                ext: extDecl,
                bases: bases,
                unretained: info.unretained,
                external: info.external
            )
            let py_methods = PyMethods(cls: cls_name, input: methods)
            
            var decls = try py_cls.decls()
            
            if hasMethods {
                decls.append(py_methods.output)
            }
            
            if hasGetSets {
                let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties)
                decls.append(getsets.output)
            }
            
            return decls + [
                "\nstatic var pyTypeObject = \(raw: type_struct.output)",
                .init(type_struct.createPyType()),
                py_cls.asPyPointer(nil),
                py_cls.asUnretainedPyPointer(nil)
            ]
        default:
            return []
        }
        
    }
}

extension PySwiftClassGenerator: MemberAttributeMacro {
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
        
        
        return [
           // .init("Hello".typeSyntax)
        ]
    }
}


extension PySwiftClassGenerator: ExtensionMacro {
    
    
    static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        
        let pyclass_args = PyClassArguments(node: node)
        
        let external = pyclass_args.external
        
        
        if let cls = declaration.as(ClassDeclSyntax.self) {
            let py_cls = PyClass(
                name: cls.name.text,
                cls: cls,
                bases: pyclass_args.bases,
                unretained: pyclass_args.unretained,
                external: external
            )
            
            var output: [ExtensionDeclSyntax] = []
            if !external {
                output.append(try py_cls.extensions())
            }
            output.append(.init(
                extendedType: TypeSyntax(stringLiteral: cls.name.text),
                inheritanceClause: .init {
                    [InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "PyClassProtocol"))]
                },
                memberBlock: .init(members: [])
            ))
            return output
        }
        
        return []
    }
}

enum PyPeerMacro: Error {
    case wrongType(_ message: String)
}

extension PySwiftClassGenerator: PeerMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let info = PyClassArguments(node: node)
        let name =  switch declaration.kind {
        case .classDecl: declaration.cast(ClassDeclSyntax.self).name.text
        case .extensionDecl: declaration.cast(ExtensionDeclSyntax.self).extendedType.trimmedDescription
        default: throw PyPeerMacro.wrongType(declaration.description)
        }
        if info.external {
            switch declaration.kind {
            case .classDecl:
                let classDecl = declaration.cast(ClassDeclSyntax.self)
                return try PyClassResult.new(classDecl: classDecl, info: info).decls
//                let cls_name = classDecl.name.text
//                let members = classDecl.memberBlock.members
//                let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
//                    let decl = member.decl
//                    return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
//                        fdecl
//                    } else { nil }
//                }
//                
//                let py_properties = members.compactMap { member -> VariableDeclSyntax? in
//                    let decl = member.decl
//                    return if decl.is(VariableDeclSyntax.self), let vdecl = decl.as(VariableDeclSyntax.self), vdecl.isPyProperty {
//                        vdecl
//                    } else { nil }
//                }
//                
//                let hasMethods = py_functions.count > 0
//                let hasGetSets = py_properties.count > 0
//                
//                let type_struct = PyTypeObjectStruct(
//                    name: cls_name,
//                    pyname: info.name ?? cls_name,
//                    bases: info.bases,
//                    unretained: info.unretained,
//                    hasMethods: hasMethods,
//                    hasGetSets: hasGetSets,
//                    external: true
//                )
//                let py_cls = PyClass(
//                    name: name,
//                    cls: classDecl,
//                    bases: info.bases,
//                    unretained: info.unretained,
//                    external: true
//                )
//                var decls: [DeclSyntax] = try py_cls.externalDecls() + [
//                    "\nfileprivate var \(raw: cls_name)_pyTypeObject = \(raw: type_struct.output)",
//                    .init(type_struct.createPyType())
//                ]
//                
//                if hasGetSets {
//                    let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties, external: info.external)
//                    decls.append(getsets.output)
//                }
//                if hasMethods {
//                    decls.append(PyMethods(cls: cls_name, input: py_functions, external: info.external).output)
//                }
//                
//                return decls
            case .extensionDecl:
                let extensionDecl = declaration.cast(ExtensionDeclSyntax.self)
                if let arguments = node.arguments {
                    switch arguments {
                    case .argumentList(let listexpr):
                        return try PyClassResult.new(extDecl: extensionDecl, info: info, arguments: listexpr).decls
                    default: return []
                    }
                    
                }
//                return try PyClass(
//                    name: name,
//                    ext: extensionDecl,
//                    bases: info.bases,
//                    unretained: info.unretained,
//                    external: info.external
//                ).externalDecls()
            default: throw PyPeerMacro.wrongType(declaration.description)
            }
        }
        return []
    }
    
    
}

struct AttachedTestMacro: CodeItemMacro, DeclarationMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        ["print()"]
    }
    
    
    
    
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let closure = node.trailingClosure else { fatalError() }
        return [
            """
            let _ = if PyGILState_Check() == 0 {
                if let state = PyThreadState_Get() {
                    \(raw: closure.statements)
                } else {
                    let gil = PyGILState_Ensure()
                    \(raw: closure.statements)
                    PyGILState_Release(gil)
                }
            } else {
                \(raw: closure.statements)
                PyEval_SaveThread()
            }
            """
        ]
    }
    
    
    static func _expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard let closure = node.trailingClosure else { fatalError() }
        return """
        let _ = if PyGILState_Check() == 0 {
            if let state = PyThreadState_Get() {
                \(raw: closure.statements)
            } else {
                let gil = PyGILState_Ensure()
                \(raw: closure.statements)
                PyGILState_Release(gil)
            }
        } else {
            \(raw: closure.statements)
            PyEval_SaveThread()
        }
        """
    }
    
    static func _expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        return []
    }
    
    
}


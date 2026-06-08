//
//  PyStructGenerator.swift
//  PySwiftKit
//
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapperInternal
import PyWrapperInfo




class PyStructArguments {
    
    var name: String?
    var bases: [PyClassBase] = []
    //var unretained = false
    //var base_type: TypeSyntax?
    //var base_type: PyTypeObjectBaseType = .none
    var external: Bool = false
    var swift_mode: SwiftMode = .v5
    
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
                                
                            case .external:
                                if let bool = arg.expression.as(BooleanLiteralExprSyntax.self) {
                                    external = Bool(bool.literal.text) ?? false
                                }
                            case .swift_mode:
                                if let member = arg.expression.as(MemberAccessExprSyntax.self) {
                                    swift_mode = switch member.declName.baseName.text {
                                        case "v6": .v6
                                        default: .v5
                                    }
                                }
                        }
                    }
                    
                default: break
            }
        }
    }
    
    
    enum Argument: String {
        case name
        //case unretained
        case bases
        //case base_type
        case external
        case swift_mode
    }
    
    enum BaseTypeInput: String {
        case pyobject
        case pyswift
        case none
        
        init(token: TokenSyntax) {
            self = .init(rawValue: token.text) ?? .none
        }
    }
}

struct PyStructGenerator: MemberMacro {
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let info = PyStructArguments(node: node)
        let members = Array(declaration.memberBlock.members)
        let swift_mode = info.swift_mode
        
        switch declaration.kind {
            case .structDecl:
                let structDecl = declaration.cast(StructDeclSyntax.self)
                let structName = structDecl.name
                let structNameString = structName.text
                
                let isPublic = structDecl.isPublic
                
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
                
                var type_struct_options: [PyTypeObjectStruct.Option] = []
                
                if hasMethods { type_struct_options.append(.hasMethods) }
                if hasGetSets { type_struct_options.append(.hasGetSets) }
                if info.external { type_struct_options.append(.isExternal) }
                if isPublic { type_struct_options.append(.isPublic) }
                
                let type_struct = PyTypeObjectStruct(
                    name: structNameString,
                    pyname: info.name ?? structNameString,
                    bases: info.bases,
                    base_type: .none,
                    options: type_struct_options
                )
                
                let swift6_prefix = switch swift_mode {
                    case .v5: ""
                    case .v6: "@MainActor "
                }
                let publicString = isPublic ? "public " : ""
                var decls: [DeclSyntax] = [
                    "\n\(raw: swift6_prefix)\(raw: publicString)static var pyTypeObject = \(raw: type_struct.output)",
                    .init(type_struct.createPyType(swift_mode: swift_mode))
                ]
                
                if hasGetSets {
                    let getsets = PyGetSetDefs(cls: structNameString.typeSyntax, properties: py_properties, swift_mode: swift_mode)
                    decls.append(getsets.output)
                }
                if hasMethods {
                    decls.append(PyMethods(cls: structNameString, input: py_functions, base_type: .none, swift_mode: swift_mode).output)
                }
                
                return decls
                
            case .extensionDecl:
                if info.external { return [] }
                let extDecl = declaration.cast(ExtensionDeclSyntax.self)
                let structType = extDecl.extendedType
                let structName = structType.trimmedDescription
                
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
                var ext_init: InitializerDeclSyntax? = nil
                if let arguments = node.arguments {
                    switch arguments {
                        case .argumentList(let listexpr):
                            let py_ext = try PyClassByExtensionUnpack(arguments: listexpr)
                            bases = py_ext.bases
                            methods.append(contentsOf: py_ext.functions)
                            py_properties.append(contentsOf: py_ext.properties)
                            ext_init = py_ext.inits.first
                        default: break
                    }
                    
                }
                
                let hasMethods = methods.count > 0
                let hasGetSets = py_properties.count > 0
                
                var type_struct_options: [PyTypeObjectStruct.Option] = []
                
                if hasMethods { type_struct_options.append(.hasMethods) }
                if hasGetSets { type_struct_options.append(.hasGetSets) }
                if info.external { type_struct_options.append(.isExternal) }
                
                let type_struct = PyTypeObjectStruct(
                    name: structName,
                    pyname: info.name ?? structName,
                    bases: bases,
                    options: type_struct_options
                )
                
                
                
                let py_cls = PyClass(
                    name: structName,
                    ext: extDecl,
                    ext_init: ext_init,
                    bases: bases,
                    base_type: .none,
                    external: info.external,
                    swift_mode: swift_mode
                )
                let py_methods = PyMethods(cls: structName, input: methods, base_type: .none, swift_mode: swift_mode)
                
                var decls = try py_cls.decls()
                
                if hasMethods {
                    decls.append(py_methods.output)
                }
                
                if hasGetSets {
                    let getsets = PyGetSetDefs(cls: structName.typeSyntax, properties: py_properties, swift_mode: swift_mode)
                    decls.append(getsets.output)
                }
                let swift6_prefix = switch swift_mode {
                    case .v5: ""
                    case .v6: "@MainActor "
                }
                return decls + [
                    "\n\(raw: swift6_prefix)static var pyTypeObject = \(raw: type_struct.output)",
                    .init(type_struct.createPyType(swift_mode: swift_mode)),
                    py_cls.asPyPointer(nil),
                    py_cls.asUnretainedPyPointer(nil)
                ]
                
                
            default:
                break
        }
        
        return []
    }
}

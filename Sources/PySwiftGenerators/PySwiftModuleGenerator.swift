//
//  PySwiftModuleGenerator.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 29/04/2025.
//
// import SwiftSyntaxWrapper
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapperInternal
import PyWrapperInfo

extension AttributeListSyntax.Element {
    var isPyFunction: Bool {
        trimmedDescription.contains("@PyFunction")
        
    }
    var isPyMethod: Bool {
        trimmedDescription.contains("@PyMethod")
    }
    
    var isPyMethodEx: Bool {
        trimmedDescription.contains("#PyMethodEx")
    }
    
    var isPyProperty: Bool {
        trimmedDescription.contains("@PyProperty")
    }
    
    var isPyPropertyEx: Bool {
        trimmedDescription.contains("#PyPropertyEx")
    }
    
    var isMainActor: Bool {
        trimmedDescription.contains("@MainActor")
        
    }
    
    var isPyModule: Bool {
        trimmedDescription.contains("@PyModule")
    }
    
    var isPySubModule: Bool {
        trimmedDescription.contains("@PySubModule")
        
    }
}

extension AttributeListSyntax {
    var isPyFunction: Bool {
        contains(where: \.isPyFunction)
    }
    var isPyMethod: Bool {
        contains(where: \.isPyMethod)
    }
    var isPyProperty: Bool {
        contains(where: \.isPyProperty)
    }
    var isMainActor: Bool {
        contains(where: \.isMainActor)
    }
    
    var isPyModule: Bool {
        contains(where: \.isPyModule)
    }
    
    var isPySubModule: Bool {
        contains(where: \.isPySubModule)
    }
}

extension DeclModifierListSyntax {
    var isPublic: Bool {
        contains { element in
            element.trimmedDescription == "public"
        }
    }
}

extension FunctionDeclSyntax {
    var isPyFunction: Bool {
        attributes.isPyFunction
    }
    var isPyMethod: Bool {
        attributes.isPyMethod
    }
}

extension VariableDeclSyntax {
    var isPyProperty: Bool {
        attributes.isPyProperty
    }
}

extension ClassDeclSyntax {
    var isMainActor: Bool {
        attributes.isMainActor
    }
    var isPublic: Bool {
        modifiers.isPublic
    }
    
    var isPyModule: Bool {
        attributes.isPyModule
    }
    
    var isPySubModule: Bool {
        attributes.isPySubModule
    }
}

extension StructDeclSyntax {
    var isMainActor: Bool {
        attributes.isMainActor
    }
    var isPublic: Bool {
        modifiers.isPublic
    }
    
    var isPyModule: Bool {
        attributes.isPyModule
    }
    
    var isPySubModule: Bool {
        attributes.isPySubModule
    }
}

class PyModuleNodeInfo {
    var name: String?
    var py_modules_exist: Bool = false
    
    init(node: AttributeSyntax) {
        for arg in node.arguments?.as(LabeledExprListSyntax.self) ?? [] {
            guard let label = arg.label?.text else { continue }
            switch Argument(rawValue: label) {
            case .name:
                switch arg.expression.as(ExprSyntaxEnum.self) {
                case .stringLiteralExpr(let string):
                    name = string.representedLiteralValue
                default: break
                }
            case .none:
                continue
            }
        }
    }
    
    enum Argument: String {
        case name
    }
}

struct PySwiftModuleGenerator: MemberMacro {
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let members = declaration.memberBlock.members
        
        let node_info = PyModuleNodeInfo(node: node)
        
        guard let module_name = switch declaration.kind {
        case .classDecl:
            declaration.as(ClassDeclSyntax.self)?.name
        case .structDecl:
            declaration.as(StructDeclSyntax.self)?.name
        default:
            nil
        } else { fatalError()}
        
        node_info.py_modules_exist = members.contains(where: { member in
            switch member.decl.as(DeclSyntaxEnum.self) {
            case .variableDecl(let variableDeclSyntax):
                return variableDeclSyntax.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmedDescription == "modules"
            default: return false
            }
        })
        
        
        
        let module_functions = members.compactMap { member in
            let decl = member.decl
            switch decl.kind {
            case .functionDecl:
                if let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyFunction {
                    return fdecl
                }
                return nil
            default:
                return nil
            }
        }
        let _module_name = node_info.name ?? module_name.text.camelCaseToSnakeCase()
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }

        let classes = pyClassNames(decl: structDecl)

        var output: [DeclSyntax] = [
            PyMethods(cls: module_name.text, input: module_functions, module_or_class: true, base_type: .none, swift_mode: .v5).output,
            .init(PyModule(name: _module_name, classes: [], module_count: module_functions.count, customSlotsSymbol: classes.isEmpty ? nil : "py_module_slots").variDecl),
            "public static let py_name = \(literal: _module_name)",
        ]
        output.append(contentsOf: processPyModuleImportFunc(classes: classes))

        if !node_info.py_modules_exist {
            let sub_names = getSubmodules(declaration: structDecl).map { sub_decl in
                "\(sub_decl.name.text).self"
            }
            output.append("static let modules: [any (PyModuleProtocol).Type] = [\(raw: sub_names.joined(separator: ","))]")
        }
        
        return output
    }
    
    
    
    /// Names of the types listed in the module's `py_classes` array literal.
    fileprivate static func pyClassNames(decl: StructDeclSyntax) -> [String] {
        extractPyClasses(decl: decl)?
            .bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements
            .compactMap { element in
                element.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            } ?? []
    }

    /// Generates the module's multi-phase init entry point.
    ///
    /// `PyModuleDef_Init` returns the *module definition* object, not a created module, so
    /// `PyModule_AddType` (which requires a real module) cannot run here. Instead the types
    /// are registered in a per-module `Py_mod_exec` slot, which CPython invokes with the
    /// actual module object during import.
    fileprivate static func processPyModuleImportFunc(classes: [String]) -> [DeclSyntax] {
        let initDecl: DeclSyntax = """
        public static let py_init: PythonModuleImportFunc = {
            PyModuleDef_Init(.init(&py_module))
        }
        """

        guard !classes.isEmpty else { return [initDecl] }

        let addTypes = classes
            .map { "PyModule_AddType(m, \($0).PyType)" }
            .joined(separator: "\n            ")

        let execDecl: DeclSyntax = """
        // Runs during multi-phase init against the real module object `m`.
        static let py_module_exec: inquiry = { m in
            \(raw: addTypes)
            return 0
        }
        """

        let slotsDecl: DeclSyntax = """
        static var py_module_slots: [PyModuleDef_Slot] = [
            .init(slot: Py_mod_exec, value: unsafeBitCast(PyModuleDef.emptyPackagePath, to: UnsafeMutableRawPointer.self)),
            .init(slot: Py_mod_exec, value: unsafeBitCast(py_module_exec, to: UnsafeMutableRawPointer.self)),
            .init()
        ]
        """

        return [execDecl, slotsDecl, initDecl]
    }
}


enum PyModuleError: Error {
    case classes(String)
}


extension ExtensionDeclSyntax {
    static func pyModuleExtension(struct_name: String, py_name: String, py_classes:  VariableDeclSyntax?, members: MemberBlockItemListSyntax?) -> ExtensionDeclSyntax {
        let classes = py_classes?.bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements.compactMap({ element in
            element.expression.as(MemberAccessExprSyntax.self)!.base!.as(DeclReferenceExprSyntax.self)!.baseName.text
        }) ?? []
        let addTypes = Array( classes.map({cls in "PyModule_AddType(m, \(cls).PyType)"})).joined(separator: "\n")
        
        let module_functions = (members ?? []).compactMap { member in
                    let decl = member.decl
                    switch decl.kind {
                    case .functionDecl:
                        if let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyFunction {
                            return fdecl
                        }
                        return nil
                    default:
                        return nil
                    }
                }
                
        
        return .init(extendedType: struct_name.typeSyntax()) {
            PyMethods(cls: struct_name, input: module_functions, module_or_class: true, base_type: .none, swift_mode: .v5).output
            PyModule(name: py_name, classes: [], module_count: module_functions.count).variDecl
            "public static let py_name = \(literal: py_name)"
#if !PIP_MODE
            """
            public static let py_init: PythonModuleImportFunc = {
                if let m = PyModule_Create2(.init(&py_module), 3) {
                    \(raw: addTypes)
                    return m
                }
                return nil
            }
            """
#endif
        }
    }
}



extension StructDeclSyntax {
    func getPyName() -> String? {
        for member in memberBlock.members {
            switch member.decl.as(DeclSyntaxEnum.self) {
            case .variableDecl(let variableDecl):
                if
                    let first = variableDecl.bindings.first,
                    let identifier = first.as(IdentifierPatternSyntax.self)
                {
                    //fatalError("found py name \(identifier.identifier.text)")
                    return identifier.identifier.text
                }
            default: continue
            }
        }
        return nil
    }
}

extension PySwiftModuleGenerator: ExtensionMacro {
    
    private static func getSubmodules(declaration: some DeclGroupSyntax) -> [StructDeclSyntax] {
        declaration.memberBlock.members.compactMap { member in
            switch member.decl.as(DeclSyntaxEnum.self) {
            case .structDecl(let structDecl): structDecl
            default: nil
            }
        }
    }
    
    private static func extractPyClasses(decl: StructDeclSyntax) -> VariableDeclSyntax? {
        let var_decls = decl.memberBlock.members.compactMap { member in
            let decl = member.decl
            return if decl.kind == .variableDecl {
                decl.as(VariableDeclSyntax.self)
            } else {
                nil
            }
        }
        return (var_decls.first { decl in
            let bindings = decl.bindings
            return if let binding = bindings.first {
                binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "py_classes"
            } else {
                false
            }
        })
    }
    
    private static func processSubmodules(modules: [StructDeclSyntax], parent: String?) -> [ExtensionDeclSyntax] {
        modules.flatMap { decl -> [ExtensionDeclSyntax] in
            
            var output = [ExtensionDeclSyntax]()
            guard decl.isPyModule else { return output }
            
            let classes_decl = extractPyClasses(decl: decl)
            let module_name = decl.name.text
            let py_module_name = decl.name.text
            let members = decl.memberBlock.members
            if let parent {
                output.append(
                    .pyModuleExtension(
                        struct_name: "\(parent).\(module_name)",
                        py_name: py_module_name,
                        py_classes: classes_decl,
                        members: members
                    )
                )
            } else {
                output.append(
                    .pyModuleExtension(
                        struct_name: module_name,
                        py_name: py_module_name,
                        py_classes: classes_decl,
                        members: members
                    )
                )
            }
            let parent_parent = if let parent {
                "\(parent).\(module_name)"
            } else {
                module_name
            }
            output.append(
                contentsOf: processSubmodules(modules: getSubmodules(declaration: decl), parent: parent_parent)
            )
            return output
        }
    }
    
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        //guard let module = declaration.as(ClassDeclSyntax.self) else { fatalError() }
        //let module_name = module.name.text
        
        
        
        guard let module_name = switch declaration.kind {
        case .classDecl:
            declaration.as(ClassDeclSyntax.self)?.name.text
        case .structDecl:
            declaration.as(StructDeclSyntax.self)?.name.text
        default:
            nil
        } else { fatalError()}
        //let _module_name = module_name.camelCaseToSnakeCase()
        let members = declaration.memberBlock.members
        let var_decls = members.compactMap { member in
            let decl = member.decl
            return if decl.kind == .variableDecl {
                decl.as(VariableDeclSyntax.self)
            } else {
                nil
            }
        }
        let classes_decl = (var_decls.first { decl in
            let bindings = decl.bindings
            return if let binding = bindings.first {
                binding.pattern.as(IdentifierPatternSyntax.self)?.description == "py_classes"
                //binding.pattern.as(IdentifierPatternSyntax.self)?.identifier == "py_classes"
            } else {
                false
            }
        })
        let modules_decl = (var_decls.first { decl in
            let bindings = decl.bindings
            return if let binding = bindings.first {
                binding.pattern.as(IdentifierPatternSyntax.self)?.description == "modules"
                //binding.pattern.as(IdentifierPatternSyntax.self)?.identifier == "py_classes"
            } else {
                false
            }
        })
        
        let classes = classes_decl?.bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements.compactMap({ element in
            element.expression.as(MemberAccessExprSyntax.self)!.base!.as(DeclReferenceExprSyntax.self)!.baseName.text
        }) ?? []
        _ = modules_decl?.bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements.compactMap({ element in
            element.expression.as(MemberAccessExprSyntax.self)!.base!.as(DeclReferenceExprSyntax.self)!.baseName.text
        }) ?? []
        //guard classes_decl != nil else { throw PyModuleError.classes(classes.description) }
        let addTypes = Array( classes.map({cls in "PyModule_AddType(m, \(cls).PyType)"})).joined(separator: "\n")
        
        var output: [ExtensionDeclSyntax] = [
            .pyModuleExtension(
                struct_name: module_name,
                py_name: module_name.camelCaseToSnakeCase(),
                py_classes: classes_decl,
                members: members
            )
        ]
        
        output.append(contentsOf: processSubmodules(modules: getSubmodules(declaration: declaration), parent: module_name))

        return []
    }

}


extension PySwiftModuleGenerator: PeerMacro {
    static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var decls: [DeclSyntax] = []

#if PIP_MODE
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        let structName = structDecl.name

        let node_info = PyModuleNodeInfo(node: node)

        let py_name = node_info.name ?? structName.text.camelCaseToSnakeCase()

        let classes_decl = (structDecl.memberBlock.members.compactMap({$0.decl.as(VariableDeclSyntax.self)}).first { decl in
            let bindings = decl.bindings
            return if let binding = bindings.first {
                binding.pattern.as(IdentifierPatternSyntax.self)?.description == "py_classes"
                //binding.pattern.as(IdentifierPatternSyntax.self)?.identifier == "py_classes"
            } else {
                false
            }
        })

        let classes = classes_decl?.bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements.compactMap({ element in
            element.expression.as(MemberAccessExprSyntax.self)!.base!.as(DeclReferenceExprSyntax.self)!.baseName.text
        }) ?? []
        // Delegates to the member macro's own `py_init`, generated by
        // processPyModuleImportFunc above: it already does the right thing
        // for both cases (PyModuleDef_Init alone when there are no classes,
        // or the multi-phase py_module_exec/py_module_slots path that
        // registers them via PyModule_AddType once CPython creates the real
        // module object). Calling PyModule_Create2 (single-phase) here
        // instead — as this used to — conflicts with m_slots always being
        // set on py_module (see PyModuleDef.new's baseSlots fallback), and
        // fails at runtime with "PyModule_Create is incompatible with
        // m_slots".
        decls.append(
            """
            @_cdecl("PyInit_\(raw: py_name)")
            public func PyInit_\(raw: py_name)() -> PyPointer? {
                \(raw: structName).py_init()
            }
            """
        )
#endif



        return decls
    }
}

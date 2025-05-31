//
//  PySwiftModuleGenerator.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 29/04/2025.
//
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapper

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

struct PySwiftModuleGenerator: MemberMacro {
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let members = declaration.memberBlock.members
        guard let module_name = switch declaration.kind {
        case .classDecl:
            declaration.as(ClassDeclSyntax.self)?.name
        case .structDecl:
            declaration.as(StructDeclSyntax.self)?.name
        default:
            nil
        } else { fatalError()}
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
        let _module_name = module_name.text.camelCaseToSnakeCase()
        
        
        return [
            PyMethods(cls: module_name.text, input: module_functions, module_or_class: true).output,
            .init(PyModule(name: _module_name, classes: [], module_count: module_functions.count).variDecl)
        ]
    }
}


enum PyModuleError: Error {
    case classes(String)
}

extension PySwiftModuleGenerator: ExtensionMacro {
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
        let _module_name = module_name.camelCaseToSnakeCase()
        let members = declaration.members.members
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
            return if let binding = bindings.first?.as(PatternBindingSyntax.self) {
                binding.pattern.as(IdentifierPatternSyntax.self)?.description == "py_classes"
                //binding.pattern.as(IdentifierPatternSyntax.self)?.identifier == "py_classes"
            } else {
                false
            }
        })
        
        let classes = classes_decl?.bindings.first?.initializer?.value.as(ArrayExprSyntax.self)?.elements.compactMap({ element in
            element.expression.as(MemberAccessExprSyntax.self)!.base!.as(DeclReferenceExprSyntax.self)!.baseName.text
        }) ?? []
        //guard classes_decl != nil else { throw PyModuleError.classes(classes.description) }
        let addTypes = Array( classes.map({cls in "PyModule_AddType(m, \(cls).PyType)"})).joined(separator: "\n")
        
        return [
            .init(extendedType: module_name.typeSyntax()) {
                """
                public static let py_init: PythonModuleImportFunc = {
                    if let m = PyModule_Create2(.init(&py_module), 3) {
                        \(raw: addTypes)
                        return m
                    }
                    return nil
                }
                """
            },
//            .init(modifiers: [.init(name: .keyword(.public))] ,extendedType: "PySwiftModuleImport".typeSyntax()) {
//                "static let \(raw: _module_name) = PySwiftModuleImport(name: \(literal: _module_name), module: \(raw: module_name).py_init)"
//            }
        ]
    }
    static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        []
    }
}

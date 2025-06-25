import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapper

class PyContainerArguments {
    
    var weak_ref = false
    
    init(node: AttributeSyntax) {
        switch node.arguments {
        case .argumentList(let labeledExprList):
            for _arg in labeledExprList.compactMap({(Argument(rawValue: $0.label?.text ?? ""), $0.expression)}) {
                switch _arg.0 {
                case .name:
                    break
                case .weak_ref:
                    if let bool = _arg.1.as(BooleanLiteralExprSyntax.self) {
                        weak_ref = .init(bool.literal.text) ?? false
                    }
                case .none:
                    break
                }
            }
        default: break
        }
    }
    
    
    enum Argument: String {
        case name
        case weak_ref
    }
}

fileprivate extension AttributeSyntax {
    static var dynamicMemberLookup: Self {
        .init(stringLiteral: "@dynamicMemberLookup")
    }
}

fileprivate extension AttributeListSyntax.Element {
    static var dynamicMemberLookup: Self {
        .attribute(.dynamicMemberLookup)
    }
}


struct PyContainerMacro: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let container_info = PyContainerArguments(node: node)
        
        let weak_ref = container_info.weak_ref
        
        let members = Array(declaration.memberBlock.members)
        
        let py_calls = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyCall {
                fdecl
            } else { nil }
        }
        
        var output: [DeclSyntax] = [
            "let py_target: PyPointer"
        ]
        
        
        
        for py_call in py_calls {
            let call_name = py_call.name
            output.append("""
            let _\(raw: call_name): PyPointer
            """)
        }
        
        let initSignature = FunctionSignatureSyntax(
            parameterClause: .init(parameters: .init {
                .init(firstName: .identifier("object"), type: "PyPointer".typeSyntax)
            }),
            effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
        )
        
        let super_init = if let inheritedTypes = declaration.inheritanceClause?.inheritedTypes {
            inheritedTypes.contains(where: {$0.trimmedDescription.contains("NSObject")})
        } else { false }
        
        let initDeclModifiers: DeclModifierListSyntax = .init {
            if declaration.modifiers.contains(where: {$0.name.text == "public"}) {
                DeclModifierSyntax(name: .keyword(.public))
            }
        }
        let initDecl = InitializerDeclSyntax(modifiers: initDeclModifiers, signature: initSignature) {
            "pyPrint(object)"
            if weak_ref {
                "py_target = object"
            } else {
                "py_target = Py_NewRef(object)"
            }
            for py_call in py_calls {
                """
                _\(raw: py_call.name) = if PyObject_HasAttr(object, "\(raw: py_call.name)") {
                    PyObject_GetAttr(object, "\(raw: py_call.name)")!
                } else { fatalError() }
                """
            }
            if super_init {
                "super.init()"
            }
            
            
        }
        
        output.append(.init(initDecl))
        
        let deinitializerDecl = DeinitializerDeclSyntax {
            for py_call in py_calls {
                "Py_DecRef(_\(raw: py_call.name))"
            }
            "Py_DecRef(py_target)"
        }
        
        output.append(.init(deinitializerDecl))
        if declaration.attributes.contains(where: {$0.isDynamicMember}) {
            output.append("""
            subscript<T: PySerializable>(dynamicMember member: String) -> T? {
                get {
                    do {
                        if let object = PyObject_GetAttr(py_target, member) {
                           return try T(consuming: object)
                        } else {
                            print("\\(member) doesn't exist")
                        }
                    } catch let err as PyStandardException {
                        err.pyExceptionError()
                    } catch let err as PyException {
                        err.pyExceptionError()
                    } catch let other_error {
                        other_error.anyErrorException()
                    }
                    return nil
                }
                set {
                    _ = member.withCString { key in
                        if let newValue {
                            PyObject_SetAttrString(py_target, key, newValue.pyPointer)
                        } else {
                            PyObject_SetAttrString(py_target, key, .None)
                        }
                    }
                    
                }
            }
            
            """)
        }
        
        return output
    }

}




extension PyContainerMacro: ExtensionMacro {
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        
        let inheritedTypes = InheritedTypeListSyntax {
            InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "PyDeserialize"))
            //InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "PyCallProtocol"))
            
        }
        return [
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: .init(inheritedTypes: inheritedTypes),
                memberBlock: .init(members: [])
            )
        ]
    }
}



//
//  PyCallbackGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 04/05/2025.
//
import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapperInternal

extension AttributeListSyntax.Element {
    var isPyCall: Bool { trimmedDescription.contains("@PyCall") }
    var isDynamicMember: Bool { trimmedDescription.contains("@dynamicMemberLookup") }
    var IsPyClass: Bool { trimmedDescription.contains("@PyClass") }
}

extension AttributeListSyntax {
    var isPyCall: Bool { contains(where: \.isPyCall) }
    var isPyClass: Bool { contains(where: \.IsPyClass) }
}

extension FunctionDeclSyntax {
    var isPyCall: Bool { attributes.isPyCall }
}

enum ProtocolsError: Error {
    case protocols_isEmpty(decl: String)
    case NSObject(_ message: String)
}

struct PyCallbackGenerator: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
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
            
            "py_target = object"
            for py_call in py_calls {
                """
                _\(raw: py_call.name) = if PyObject_HasAttr(object, "\(raw: py_call.name)") {
                    try PyObject_GetAttr(object, key: "\(raw: py_call.name)")
                } else { fatalError() }
                """
            }
            if super_init {
                "super.init()"
            }
        }
        
        output.append(.init(initDecl))
        
        return output
    }
}

class PyCallArguments {
    var name: String
    var gil = true
    var method = false
    var target: String?
    //var once: Bool = false
    
    init(node: AttributeSyntax) {
        let macroName = node.attributeName.trimmedDescription
        name = macroName
        //once = macroName.contains("Once")
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let labeledExprList):
                setAttributes(arguments: labeledExprList)
            default: break
            }
        }
    }
    
    init(node: FreestandingMacroExpansionSyntax) {
        let macroName = node.macroName.text
        
        name = macroName
        //once = macroName.contains("Once")
        setAttributes(arguments: node.arguments)
        
    }
    
    private func setAttributes(arguments: LabeledExprListSyntax) {
        for arg in arguments {
            guard let label = arg.label, let argument = Argument(rawValue: label.text) else { continue }
            switch argument {
            case .target:
                
                switch arg.expression.as(ExprSyntaxEnum.self) {
                case .stringLiteralExpr(let string):
                    target = string.segments.trimmedDescription
                case .simpleStringLiteralExpr(let string):
                    target = string.segments.trimmedDescription
                default:
                    target = arg.expression.trimmedDescription
                }
                
            case .gil:
                gil = .init(arg.expression.description) ?? true
 
                
            case .method:
                method = .init(arg.expression.description) ?? false
            }
        }
    }
    
    
    
    enum Argument: String {
        case target
        case gil
        case method
    }
}

struct PyCallFiller: BodyMacro {
    
    static func expansion(of node: AttributeSyntax, providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax, in context: some MacroExpansionContext) throws -> [CodeBlockItemSyntax] {
        guard let fdecl = declaration.as(FunctionDeclSyntax.self) else { return [] }
        let info = PyCallArguments(node: node)
        
        
        let pycall = PyCallGenerator(
            function: fdecl,
            gil: info.gil,
            method: info.method,
            target: info.target,
            once: false
        )
        
        return .init(pycall.output)
//
//        return ["""
//        do \(raw: pycall.output)
//        catch let err as PyStandardException {
//            err.pyExceptionError()
//        } catch let err as PyException {
//            err.pyExceptionError()
//        } catch let other_error {
//            other_error.anyErrorException()
//        }
//        """]
    }
    
    static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        []
    }
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        
        var output = [DeclSyntax]()
        output.append("""
        """)
        return output
    }
}

class PyCallableArguments {
    var gil = true
    var method = false
    var target: ExprSyntax = "Void"
    var types: [TypeSyntax]
    var macroName: String
    var once: Bool = false
    
    init(node: FreestandingMacroExpansionSyntax) {
        let _macroName = node.macroName.text
        macroName = _macroName
        types = node.genericArgumentClause?.arguments.compactMap({ generic in
            switch generic.argument {
            case .type(let t): t
            default: nil
            }
        }) ?? []
        setAttributes(arguments: node.arguments)
        
    }
    
    private func setAttributes(arguments: LabeledExprListSyntax) {
        for arg in arguments {
            if let label = arg.label {
                guard let argument = Argument(rawValue: label.text) else { continue }
                switch argument {
                case .target:
                    break
                case .gil:
                    break
                case .method:
                    break
                case .once:
                    once = .init(arg.expression.description) ?? false
                }
            } else {
                target = arg.expression
            }
            
        }
    }
    
    enum Argument: String {
        case target
        case gil
        case method
        case once
    }
}

extension PyCallFiller: ExpressionMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        let info = PyCallableArguments(node: node)
        let macroName = info.macroName
        let (types, rtype): ([TypeSyntax], TypeSyntax?) = switch macroName {
        case let v where v.hasSuffix("_V"):
            (info.types, nil)
        case let pp where pp.hasSuffix("_P"):
            (info.types, TypeSyntax(stringLiteral: "PyPointer"))
        default:
            (Array(info.types.dropLast()), info.types.last)
        }
        
        let letters = "abcdefghijklmnop".map(String.init)
        let args: LabeledExprListSyntax = .init {
            for i in 0..<types.count {
                LabeledExprSyntax(label: letters[i], expression: ExprSyntax(stringLiteral: "Void"))
            }
        }
        let pycall = PyCallGenerator(
            target: "__call__",
            parameters: args ,
            returnType: rtype,
            gil: info.gil,
            method: info.method,
            canThrow: false,
            once: info.once
        )
        
        
        let parameters: ClosureSignatureSyntax.ParameterClause = .parameterClause(.init(parameters: .init {
            //.init(firstName: .identifier("__call__"))
            if types.count > 0 {
                for i in (0..<types.count) {
                    ClosureParameterSyntax(firstName: .identifier(letters[i]))
                }
            }
        }))
        let returnClause: ReturnClauseSyntax? = if let rtype {
            .init(type: rtype)
        } else {
            nil
        }
        let signature = ClosureSignatureSyntax(
            parameterClause: parameters,
            returnClause: returnClause
        )
        let inner = ClosureExprSyntax(
            signature: signature,
            statements: pycall.output
        )
        return """
        {
        let __call__: PyPointer = \(raw: info.target)\(raw: info.once ? ".newRef" : "")
        
        return \(raw: inner.formatted())
        }()
        """
    }
    
    
}

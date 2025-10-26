//
//  Extensions.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax

extension AttributeSyntax {
    func isName(text: String) -> Bool {
        attributeName.trimmedDescription == text
    }
}

extension AttributeListSyntax.Element {
    
    func isAttribute(label: String) -> Bool {
        switch self {
        case .attribute(let attributeSyntax):
            attributeSyntax.attributeName.trimmedDescription == label
        case .ifConfigDecl(_):
            false
        }
    }
    
    var isPyFunction: Bool { isAttribute(label: "PyFunction") }
    var isPyMethod: Bool { isAttribute(label: "PyMethod") }
    var isPyInit: Bool { isAttribute(label: "PyInit") }
    var isPyModule: Bool { isAttribute(label: "PyModule") }
    var isPyClass: Bool { isAttribute(label: "PyClass") }
    var isPyClassExt: Bool { isAttribute(label: "PyClassByExtension") }
    var isPyCallback: Bool { isAttribute(label: "PyCallback") }
    var isPyContainer: Bool { isAttribute(label: "PyContainer") }
    var isPyCall: Bool { isAttribute(label: "PyCall") }
    var isPyProperty: Bool { isAttribute(label: "PyProperty") }
}

extension AttributeListSyntax {
    var isPyFunction: Bool { contains(where: \.isPyFunction) }
    var isPyMethod: Bool { contains(where: \.isPyMethod) }
    var isPyInit: Bool { contains(where: \.isPyInit) }
    var isPyModule: Bool { contains(where: \.isPyModule) }
    var isPyClass: Bool { contains(where: \.isPyClass) }
    var isPyClassExt: Bool { contains(where: \.isPyClassExt) }
    var isPyCallback: Bool { contains(where: \.isPyCallback) }
    var isPyContainer: Bool { contains(where: \.isPyContainer) }
    var isPyCall: Bool { contains(where: \.isPyCall) }
    var isPyProperty: Bool { contains(where: \.isPyProperty) }
}

extension FunctionDeclSyntax {
    var isPyFunction: Bool { attributes.isPyFunction }
    var isPyMethod: Bool { attributes.isPyMethod }
    var isPyCall: Bool { attributes.isPyCall }
    
    var getPyMethod: AttributeSyntax? {
        if let attr = attributes.first(where: \.isPyMethod) {
            switch attr {
            case .attribute(let attributeSyntax):
                attributeSyntax
            case .ifConfigDecl(_):
                nil
            }
        } else { nil }
    }
}

extension ClassDeclSyntax {
    var isPyClass: Bool { attributes.isPyClass }
    var isPyContainer: Bool { attributes.isPyContainer }
}

extension ExtensionDeclSyntax {
    var isPyClassExt: Bool { attributes.isPyClassExt }
}

extension StructDeclSyntax {
    var isPyModule: Bool { attributes.isPyModule }
}

extension VariableDeclSyntax {
    var isPyProperty: Bool { attributes.isPyProperty }
}

extension DeclModifierSyntax {
    static var `public`: Self { .init(name: .keyword(.public)) }
    static var `private`: Self { .init(name: .keyword(.private)) }
    static var `fileprivate`: Self { .init(name: .keyword(.fileprivate)) }
    static var `static`: Self { .init(name: .keyword(.static)) }
}



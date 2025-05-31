//
//  VariableDeclSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax


extension VariableDeclSyntax {
    var read_only: Bool {
        false
//        if bindingSpecifier == .keyword(.let) { return true }
//        guard let last = bindings.last else { return false }
//
//        return switch last.kind {
//        case .accessorBlock:
//            if let block = last.as(AccessorBlockSyntax.self) {
//                switch block.accessors {
//                case .accessors(let acc_list):
//                    false
//                case .getter(let getter):
//                    true
//                }
//            } else {
//                true
//            }
//            
//        case .initializerClause:
//            false
//        default:
//            fatalError()
//        }
    }
    
    public var declSyntax: DeclSyntax { .init(self) }
}

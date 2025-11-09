

import SwiftSyntax

public class PyCallableClosure {
    
    var par_count: Int
    
    var funcType: FunctionTypeSyntax
    
    
    
    var argsThrows: Bool
    
    var funcThrows: Bool
    
    
    var return_type: TypeSyntax
    
    var codeBlock: CodeBlockItemListSyntax
    
    public init(funcType: FunctionTypeSyntax, codeBlock: CodeBlockItemListSyntax) {
        self.par_count = funcType.parameters.count
        self.funcType = funcType
        self.argsThrows = funcType.parameters.contains(where: {$0.type.canThrow})
        self.funcThrows = funcType.effectSpecifiers?.throwsClause != nil
        self.return_type = funcType.returnClause.type
        self.codeBlock = codeBlock
        
        
    }
    
    
}

extension PyCallableClosure {
    private var parameters: ClosureParameterListSyntax {.init {
        
        for (i, _) in funcType.parameters.enumerated() {
            "\(raw: pletters[i])"
        }
    }}
    
    private var signature: ClosureSignatureSyntax {
        return .init(parameterClause: .parameterClause(.init(parameters: parameters)), returnClause: .init(type: return_type))
    }
    
    public var output: ClosureExprSyntax { .init(signature: signature, statements: codeBlock) }
}

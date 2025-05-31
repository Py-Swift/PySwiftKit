
import SwiftSyntax


extension TryExprSyntax {
    
    static func pyDict_GetItem(_ o: String, _ key: String) -> Self {
        
        return .init(expression: FunctionCallExprSyntax.pyDict_GetItem(o, key))
    }
    
    static func pyTuple_GetItem(_ o: String, _ key: Int) -> Self {
        
        return .init(expression: FunctionCallExprSyntax.pyTuple_GetItem(o, key))
    }
}

import Foundation
import PySwiftKit
//import PythonTypeAlias


public final class PySwiftModuleImport {
    public let name: CString
    public let module: PythonModuleImportFunc
    
    
    public init(name: String, module: PythonModuleImportFunc) {
        self.name = makeCString(from: name)
        self.module = module
    }
}


@resultBuilder
public struct PySwiftModuleImports {
    public static func buildBlock(_ components: PySwiftModuleImport...) -> [PySwiftModuleImport] {
        components
    }
    
}

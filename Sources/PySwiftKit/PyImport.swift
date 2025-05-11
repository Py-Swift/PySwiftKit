import Foundation
import PythonCore
//import PythonTypeAlias

private var importedModules = [String: PythonPointer]()
private var importedModulesItems = [String: PythonPointer]()

public func PyImport(from mod: String, import_name: String) -> PythonPointer? {
    let module_item_name = "\(mod)_\(import_name)"
    
    if let _import_ = importedModulesItems[module_item_name] {
        return _import_
    }
    
    var module: PythonPointer?
    var module_item: PythonPointer?
    
    if let _module = importedModules[mod] {
        module = _module
    } else {
        let _module = PyImport_ImportModule(mod)
        module = _module
        if _module == nil {
            PyErr_Print()
        }
        print("module imported", _module!)
        importedModules[mod] = _module
    }
    
    guard let module = module else { return nil }
    
    
    if let _module_item = importedModulesItems[module_item_name] {
        module_item = _module_item
    } else {
        let _module_item = PyObject_GetAttrString(module, import_name)
        module_item = _module_item
        importedModulesItems[module_item_name] = _module_item
    }
    
    
    return module_item
}


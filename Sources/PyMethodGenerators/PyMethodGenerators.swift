import Foundation
import PythonCore

import Accelerate




@inlinable public func generatePySwiftMethod(name: String, _func: PyCFunction!, docs: String!) -> UnsafeMutablePointer<PyMethodDef> {
    var count = 0
    let method_name_ptr: UnsafeMutablePointer<CChar> = makeCString(from: "spam")
    
    let pymethod: UnsafeMutablePointer<PyMethodDef> = .allocate(capacity: 1)
    pymethod.pointee =  PyMethodDef(
        ml_name: method_name_ptr,
        ml_meth: _func,
        ml_flags: METH_VARARGS,
        ml_doc: nil
        )
    method_name_ptr.deinitialize(count: count)
    method_name_ptr.deallocate()
    return pymethod
}


public enum PyMethodError: Error {
    case import_error
}
var tp_call: vectorcallfunc?
public class _PySwiftMethod: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: _PySwiftMethod, rhs: _PySwiftMethod) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    
    public let name: UnsafeMutablePointer<CChar>
    public let name_count: Int
    public var swiftFunc: PyCFunction!
    public var pyMethod: PyMethodDef
    
    public init(_module: PythonPointer ,func_name: String, _func: @escaping PyCFunction) throws {
        var ncount = 0
        let _name: UnsafeMutablePointer<CChar> = makeCString(from: func_name)
        name = _name
        name_count = ncount
        swiftFunc = _func
        pyMethod = PyMethodDef(
                ml_name: _name,
                ml_meth: _func,
                ml_flags: METH_VARARGS,
                ml_doc: nil
                )
        
        
        
        //guard let py_func = PyCFunction_New(&pyMethod, nil) else { PyErr_Print(); throw PyMethodError.import_error }
        //let newobj = PyModule_NewObject("spam2".python_str)
        //PyModule_AddObject(_module, _name, py_func)

        PyErr_Print()
//
  
        //test_obj([],arg_count: 0)
    }
    
    deinit {
        name.deallocate()
    }
}


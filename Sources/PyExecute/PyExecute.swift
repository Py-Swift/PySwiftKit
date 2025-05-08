import Foundation
import PySwiftKit
//import PythonTypeAlias
import PythonCore
public enum PyEvalFlag: Int32 {
    case single = 256
    case file = 257
    case eval = 258
    case func_type = 345
    case fstring = 800
    
    
    
}
//#if BEEWARE

public func Py_ValidateCode(code: String,  filename: String, flag: PyEvalFlag) -> Bool {
    print("Py_CompileString:\n", code)
    PyErr_Clear()
    return code.withCString { str in
        //let gil = PyGILState_Ensure()
        //return true
        
        if let result = Py_CompileString(str, filename, flag.rawValue) {
            print(result)
            result.decref()
            return true
        }
        
        return false
        //PyGILState_Release(gil)
        
        
        //return result
    }
}

public func Py_CompileString(code: String,  filename: String, flag: PyEvalFlag) -> PyPointer? {
    print("Py_CompileString:\n\n", code)
    PyErr_Clear()
    return code.withCString { str in
        //let gil = PyGILState_Ensure()
		//return .None
        
		guard let result = Py_CompileString(str, filename, flag.rawValue) else {
			PyErr_Print()
			return nil
		}
		result.decref()
        return result
    }
}
//#endif

public func PyRun_String(string: String, flag: PyEvalFlag, globals: PyPointer, locals: PyPointer) -> PyPointer? {
    string.withCString { str in
        PyRun_String(str, flag.rawValue, globals, locals)
    }
}

public func PyRun_URL(url: URL, flag: PyEvalFlag, globals: PyPointer, locals: PyPointer) -> PyPointer? {
	guard let string = try? String(contentsOf: url) else { fatalError() }
    return string.withCString { str in
        PyRun_String(str, flag.rawValue, globals, locals)
    }
}



public extension PyMethodDef {
    
    enum MethFlag: Int32 {
        case FASTCALL = 0x0080
        case METHOD = 0x0200
        case CLASS = 0x0010
        case STATIC = 0x0020
        case VARARGS = 0x0001
        case KEYWORDS = 0x0002
        case NOARGS = 0x0004
        case ONE_ARG = 0x0008
        case COEXIST = 0x0040
        
        public static func | (l: Self, r: Self) -> Int32 {
            l.rawValue | r.rawValue
        }
        
        public static func | (l: Self, r: Self) -> Self {
            .init(rawValue: l | r )!
        }
    }
    
    static func new(name: String, meth: PyCFunction, flags: MethFlag) -> Self {
        
        return name.withCString { string in
            return .init(
                ml_name: string,
                ml_meth: meth,
                ml_flags: flags.rawValue,
                ml_doc: nil
            )
        }
    }
    static func oneArgMethod(name: String, meth: PyCFunction) -> Self {
        .new(
            name: name,
            meth: meth,
            flags: .ONE_ARG
        )
    }
}

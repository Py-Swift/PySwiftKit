import Foundation
import PythonCore
//import PythonTypeAlias



public let pyBuiltins = PyEval_GetBuiltins()
public let print_obj = PyDict_GetItemString(pyBuiltins, "print")


public func pyPrint(_ o: PyPointer) {
	PyObject_Print(o, stdout, Py_PRINT_RAW)
	print()
}
extension PyPointer {
    
    public func IsInstance(_ type: PyPointer) -> Bool {
        PyObject_IsInstance(self, type) == 1
    }
    
}


public struct NewPyObjectTypeFlag {
    
    
    //#if os(OSX)
    #if BEEWARE
    static public let DEFAULT = UInt(Py_TPFLAGS_DEFAULT)
    #else
    //static public let DEFAULT = UInt(Python_TPFLAGS_DEFAULT)
	static public let DEFAULT = UInt(Py_TPFLAGS_DEFAULT)
    #endif
//    #elseif os(iOS)
//    static public let DEFAULT = UInt(Python_TPFLAGS_DEFAULT)
//    #endif
    static public let BASETYPE = Py_TPFLAGS_BASETYPE
    static public let DEFAULT_BASETYPE = DEFAULT | BASETYPE
    static public let GC = Py_TPFLAGS_HAVE_GC
    static public let VECTORCALL = Py_TPFLAGS_HAVE_VECTORCALL
    static public let GC_BASETYPE = GC | BASETYPE
    static public let DEFAULT_BASE_GC = DEFAULT | BASETYPE | GC
}

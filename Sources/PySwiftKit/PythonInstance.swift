import Foundation
import PythonCore
//import PythonTypeAlias



public let pyBuiltins = PyEval_GetBuiltins()
public let print_obj = PyDict_GetItemString(pyBuiltins, "print")


public func pyPrint(_ o: PyPointer) {
    //PyObject_CallOneArg(print_obj, o)
	PyObject_Print(o, stdout, Py_PRINT_RAW)
	print()
}
extension PyPointer {
    
    public func IsInstance(_ type: PyPointer) -> Bool {
        PyObject_IsInstance(self, type) == 1
    }
    
}


class PythonInstance {
    
    static let shared = PythonInstance()
    
    init() {
        
        
    }
    
    @inlinable public func start() {
        let resourcePath = Bundle.main.resourcePath!
        var config: PyConfig = .init()
        print("Configuring isolated Python...")
        PyConfig_InitIsolatedConfig(&config)

        // Configure the Python interpreter:
        // Run at optimization level 1
        // (remove assertions, set __debug__ to False)
        config.optimization_level = 1
        // Don't buffer stdio. We want output to appears in the log immediately
        config.buffered_stdio = 0
        // Don't write bytecode; we can't modify the app bundle
        // after it has been signed.
        config.write_bytecode = 0
        // Isolated apps need to set the full PYTHONPATH manually.
        config.module_search_paths_set = 1

        var status: PyStatus

        let python_home = "\(resourcePath)/Support/Python/Resources"

        var wtmp_str = Py_DecodeLocale(python_home, nil)

        var config_home = config.home

        status = PyConfig_SetString(&config, &config_home, wtmp_str)

        PyMem_RawFree(wtmp_str)

        config.home = config_home

        status = PyConfig_Read(&config)

        print("PYTHONPATH:")

        let path = "\(resourcePath)/Support/Python/Resources/lib/python3.10"
        print("- \(path)")
        wtmp_str = Py_DecodeLocale(path, nil)
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)

        PyMem_RawFree(wtmp_str)

        print("Initializing Python runtime...",status)
        status = Py_InitializeFromConfig(&config)
    }
    
    deinit {
        Py_Finalize()
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

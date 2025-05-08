import XCTest
@testable import PySwiftKit
@testable import PythonCore
@testable import PyExecute
@testable import PyDictionary
//@testable import PythonTestSuite
fileprivate extension PyPointer {
    
    var refCount: Int { Py_REFCNT(self) }
}

fileprivate var call_counts = 0

private func createPyTestFunction(name: String, _ code: String) throws -> PyPointer? {
    guard
        let kw = PyDict_New(),
        let lkw = PyDict_New(),
        let result = PyRun_String(string: code, flag: .file, globals: kw, locals: lkw)
    else {
        PyErr_Print()
        throw CocoaError(.coderInvalidValue)
    }
	let pyfunc: PyPointer = PyDict_GetItem(lkw, name).xINCREF
    kw.decref()
    lkw.decref()
    result.decref()
    return pyfunc
}
private var pythonIsRunning = false

var pystdlib: URL {
    Bundle.module.url(forResource: "python_stdlib", withExtension: nil)!
}
func initPython() {
    if pythonIsRunning { return }
    pythonIsRunning.toggle()
//    let resourcePath = "/Users/musicmaker/Library/Mobile Documents/com~apple~CloudDocs/Projects/xcode_projects/touchBay_files/touchBay/touchBay"
    let resourcePath: String
    if #available(macOS 13, iOS 16, *) {
        resourcePath = pystdlib.path()
    } else {
        resourcePath = pystdlib.path
    }
    print(resourcePath)
    var config: PyConfig = .init()
    print("Configuring isolated Python for Testing...")
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
    
    let python_home = "\(resourcePath)"
    
    var wtmp_str = Py_DecodeLocale(python_home, nil)
    
    var config_home: UnsafeMutablePointer<wchar_t>!// = config.home
    
    status = PyConfig_SetString(&config, &config_home, wtmp_str)
    
    PyMem_RawFree(wtmp_str)
    
    config.home = config_home
    
    status = PyConfig_Read(&config)
    
    print("PYTHONPATH:")
    
    let path = "\(resourcePath)"
    //let path = "\(resourcePath)/"
    
    print("- \(path)")
    wtmp_str = Py_DecodeLocale(path, nil)
    status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
    
    PyMem_RawFree(wtmp_str)
    
    
    //PyImport_AppendInittab(makeCString(from: "fib"), PyInitFib)
    
    //PyErr_Print()
    
    //let new_obj = NewPyObject(name: "fib", cls: Int.self, _methods: FibMethods)
    print("Initializing Python runtime...")
    status = Py_InitializeFromConfig(&config)
        
    PyEval_SaveThread()
}
final class PythonSwiftCoreTests: XCTestCase {
    
    

    
    
    func test_PythonSwiftCore_callingPyFunction_shouldNotChangeRefCount() throws {
        initPython()
        assert(!PyHasGIL())
        try withAutoGIL {
            
            
            let pyfunc = try createPyTestFunction(name: "doubleTest", """
            def doubleTest(a):
                print(a)
            """)
            let a: PyPointer = 4.56786442134.pyPointer
            let start_ref = a.refCount
            
            //print(_Py_REFCNT(a))
            XCTAssertNotNil(pyfunc)
            PyObject_CallOneArg(pyfunc, a)
            
            XCTAssertEqual(a.refCount, start_ref, "pyobject ref count should be equal after call")
            
            a.decref()
            //print(_Py_REFCNT(a))
            XCTAssertLessThan(Py_REFCNT(a), start_ref, "decref required after PyObject_CallOneArg")
            //XCTAssertEqual(start_start, _Py_REFCNT(a))
        }
    }
    
    private static func newDictionary() throws -> PyPointer {
        let _dict = PyDict_New()
        XCTAssertNotNil(_dict, "dictionary should not be nil")
        return _dict.unsafelyUnwrapped
    }
    
    private static  func newList() throws -> PyPointer {
        let object = PyList_New(0)
        XCTAssertNotNil(object, "list should not be nil")
        return object.unsafelyUnwrapped
    }
    
    private static func newTuple(_ size: Int) throws -> PyPointer {
        let object = PyTuple_New(size)
        XCTAssertNotNil(object, "list should not be nil")
        return object.unsafelyUnwrapped
    }
    
    private static func newDict() throws -> PyPointer {
        let object = PyDict_New()
        XCTAssertNotNil(object, "dict should not be nil")
        return object.unsafelyUnwrapped
    }
    
    func test_PythonSwiftCore_pyDict_shouldChangeRefCount() throws {
        initPython()
        assert(!PyHasGIL())
        try withAutoGIL {
            let dict = try Self.newDictionary()
            let string = "world!!!!".pyPointer
            let string_rc = string.refCount
            PyDict_SetItem(dict, "hello", string)
            XCTAssertGreaterThan(string.refCount, string_rc)
            string.decref()
            dict.decref()
        }
    }
	func test_PythonSwiftCore_pyDict_shouldChangeRefCount2() throws {
		initPython()
        try withAutoGIL {
            let dict = try Self.newDictionary()
            let string = "hello!!!!".pyPointer
            let string2 = "world!!!!".pyPointer
            let string_rc = string.refCount
            
            PyDict_SetItem(dict, "hello", string)
            XCTAssertGreaterThan(string.refCount, string_rc)
            if PyDict_Contains(dict, "hello") {
                PyDict_DelItem(dict, "hello")
                XCTAssertEqual(string.refCount, string_rc)
                PyDict_SetItem(dict, "hello", string)
                XCTAssertGreaterThan(string.refCount, string_rc)
            }
            
            PyDict_SetItem(dict, "hello", string2)
            XCTAssertEqual(string.refCount, string_rc)
            dict.decref()
            XCTAssertEqual(string_rc, string.refCount)
            XCTAssertEqual(string.refCount, 1)
            string.decref()
        }
	}
    
    func test_PythonSwiftCore_pyDict_keyValues_afterGC_DidNotChange() throws {
        initPython()
        assert(!PyHasGIL())
        try withAutoGIL {
            let dict = try Self.newDictionary()
            let string = "world!!!!".pyPointer
            let string_rc = string.refCount
            PyDict_SetItem(dict, "hello", string)
            dict.decref()
            XCTAssertEqual(string_rc, string.refCount)
            XCTAssertEqual(string.refCount, 1)
            string.decref()
        }
    }
    
    
    func test_PythonSwiftCore_pyList_shouldChangeRefCount() throws {
        initPython()
        try withAutoGIL {
            
            
            let object = try Self.newList()
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyList_Append(object, string)
            XCTAssertGreaterThan(string.refCount, string_rc)
            string.decref()
            object.decref()
        }
    }
    
    func test_PythonSwiftCore_pyList_Values_afterGC_DidNotChange() throws {
        initPython()
        assert(PyGILisReleased())
        try withAutoGIL {
            
            let object = try Self.newList()
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyList_Append(object, string)
            object.decref()
            XCTAssertEqual(string_rc, string.refCount)
            XCTAssertEqual(string.refCount, 1)
            string.decref()
        }
    }
    
    func test_PythonSwiftCore_pyTupleSetItem_shouldNotChangeRefCount() throws {
        initPython()
        assert(PyGILisReleased())
        try withAutoGIL {
            
            let object = try Self.newTuple(1)
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyTuple_SetItem(object, 0, string)
            XCTAssertEqual(string_rc, string.refCount)
            object.decref()
        }
    }
    
    func test_PythonSwiftCore_pyTuple_Values_afterGC_DidChange() throws {
        initPython()
        assert(PyGILisReleased())
        try withAutoGIL {
            
            let object = try Self.newTuple(1)
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyTuple_SetItem(object, 0, string)
            let after_rc = string.refCount
            string.incref()
            XCTAssertEqual(string.refCount, 2)
            object.decref()
            XCTAssertEqual(string.refCount, after_rc)
            XCTAssertEqual(string.refCount, 1)
            string.decref()
        }
    }
    
    func test_PythonSwiftCore_pyDict_set_shouldChangeRefCount() throws {
        initPython()
        assert(PyGILisReleased())
        try withAutoGIL {
            
            let object = try Self.newDict()
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyDict_SetItem(object, "hello", string)
           // XCTAssertEqual(string_rc, string.refCount)
            XCTAssertGreaterThan(string.refCount, string_rc)
            object.decref()
            XCTAssertEqual(string_rc, string.refCount)
        }
    }
    
    func test_PythonSwiftCore_pyDict_set_Values_afterGC_DidNotChange() throws {
        initPython()
        assert(PyGILisReleased())
        try withAutoGIL {
            
            let object = try Self.newDict()
            let string = "hello world!!!!".pyPointer
            let string_rc = string.refCount
            PyDict_SetItem(object, "hello", string)
            
            let after_rc = string.refCount
           // string.incref()
            XCTAssertEqual(after_rc, 2)
            
            let string_ref = PyDict_GetItem(object, "hello")
            XCTAssertEqual(string.refCount, 2)
            XCTAssertEqual(string_ref.refCount, 2)
            object.decref()
            XCTAssertEqual(string_ref.refCount, 1)
            XCTAssertEqual(string.refCount, 1)
            string.decref()
        }
    }
    
    func test_timing_of_gil() {
        initPython()
        assert(!PyHasGIL())
        //PyEval_SaveThread()
        let handle = {
            
        }
        _ = PyGILState_Ensure()
        let count = 1_000_000
        let tests = 3
        print("with gil always on:")
        
        var py_cfunc: PyCFunc = unsafeBitCast({ a, b, c in
            return .None
        } as _PyCFunctionFast, to: PyCFunc.self)
        var py_meth: PyMethodDef = .oneArgMethod(name: "hello") { _, _ in
            call_counts += 1
                return .None
        }
        let py_str = "hello".pyPointer
        let py_func = PyCFunction_New(&py_meth, nil)
        for _ in 0..<tests {
            let s = DispatchTime.now()
            //for _ in 0...1_000 {
                //_ = PyGILState_Ensure()
                for _ in 0..<count {
                    
                    PyObject_CallOneArg(py_func, py_str)
                    
                }
                //PyEval_SaveThread()
            //}
            let e = DispatchTime.now().uptimeNanoseconds
            print(Double(e - s.uptimeNanoseconds) / 1_000_000_000 )
        }
        PyEval_SaveThread()
        print("with gil toggle")
        for _ in 0..<tests {
            let s = DispatchTime.now()
            for _ in 0..<count {
                _ = PyGILState_Ensure()
                call_counts += 1
                    PyObject_CallOneArg(py_func, py_str)
                    
                PyEval_SaveThread()
            }
            let e = DispatchTime.now().uptimeNanoseconds
            print(Double(e - s.uptimeNanoseconds) / 1_000_000_000 )
        }
        print(call_counts)
    }
    
    
}

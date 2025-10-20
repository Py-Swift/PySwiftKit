import Foundation
import CPython





extension PythonObject {
//    @inlinable public func callAsFunction(method name: String) -> String {
//        let name = name.pyStringUTF8
//        let rtn = PyObject_CallMethodNoArgs(ptr, name)
//        Py_DecRef(name)
//        return rtn.string ?? ""
//    }
//    
//    @discardableResult
//    @inlinable public func callAsFunction(method name: String, _ args: [PyPointer]) -> PythonObject? {
//        let key = name.py_string
//        let result =  PythonObject.init(getter: PyObject_VectorcallMethod(name.py_string,[ptr] + args, args.count + 1, nil))
//        Py_DecRef(key)
//        return result
//    }
//    
//    @discardableResult
//    @inlinable public func callAsFunction(method name: String, _ args: KeyValuePairs<String, PyPointer>) -> PythonObject? {
//        var _args: [PyPointer] = [ptr]
//        let kw = PyTuple_New(args.count)
//        for (i,( key, value)) in args.enumerated() {
//            _args.append(value)
//            let k = key.py_string
//            PyTuple_SetItem(ptr, i, k)
//            defer { Py_DecRef(k) }
//        }
//        let _mname = name.py_string
//        return .init(getter: PyObject_VectorcallMethod(_mname,_args, args.count + 1, nil))
//    }
//    
    
//    @discardableResult
//    @inlinable public func callAsFunction() -> PyConvertible {
//        
//        return PyObject_CallNoArgs(ptr)
//    }
//    
//    @discardableResult
//    @inlinable public func callAsFunction(_ arg: PyConvertible) -> PyConvertible {
//        let obj = arg.pyPointer
//        let result = PyObject_CallOneArg(ptr, obj)
//        Py_DecRef(obj)
//        return result
//    }
    
    
//    @inlinable public func callAsFunction(method: String, _ args: KeyValuePairs<String, PyPointer>) -> PythonObject {
//        
//        
//        
//        return .init(getter: nil)
//    }
//
    
    @discardableResult
    public func dynamicallyCall<R: ConvertibleFromPython, T: PyConvertible>(withKeywordArguments args: KeyValuePairs<String, T>) throws -> R {
        //var keys = [PyPointer]()
        var values = [PyPointer?]()
        let kw = PyDict_New()
        
        for (key,value) in args {
            let v = value.pyPointer
            if key.isEmpty {
                //PyTuple_SetItem(tuple, i, v)
                values.append(value.pyPointer)
                continue
            }
            PyDict_SetItem(kw, key, v)
            Py_DecRef(v)
            
            
        }
        let tuple = PyTuple_New(values.count)
        for (i, element) in values.enumerated() {
            PyTuple_SetItem(tuple, i, element)
            Py_DecRef(element)
        }
        //print(ptr.printString)
        guard let result = PyObject_VectorcallDict(ptr, values, values.count, kw) else {
        //if result == nil {
            PyErr_Print()
            throw PythonError.call
        }
        //let result = PyObject_Call(ptr, tuple, kw)
        //for k in keys { Py_DecRef(k) }
        for v in values { Py_DecRef(v)}
        Py_DecRef(tuple)
        Py_DecRef(kw)
        let rtn = try R(object: result)
        result.decref()
        return rtn
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, PyConvertible>) -> PyConvertible? {
        //var keys = [PyPointer]()
        var values = [PyPointer?]()
        let kw = PyDict_New()
        
        for (key,value) in args {
            let v = value.pyPointer
            if key.isEmpty {
                //PyTuple_SetItem(tuple, i, v)
                values.append(value.pyPointer)
                continue
            }
                PyDict_SetItem(kw, key, v)
                Py_DecRef(v)
            
            
        }
        let tuple = PyTuple_New(values.count)
        for (i, element) in values.enumerated() {
            PyTuple_SetItem(tuple, i, element)
            Py_DecRef(element)
        }
        //print(ptr.printString)
        guard let result = PyObject_VectorcallDict(ptr, values, values.count, kw) else {
        //if result == nil {
            PyErr_Print()
            return nil
        }
        //let result = PyObject_Call(ptr, tuple, kw)
        //for k in keys { Py_DecRef(k) }
        for v in values { Py_DecRef(v)}
        Py_DecRef(tuple)
        Py_DecRef(kw)
        return result
    }
    
    private func _dynamicallyCall<T : Collection>(_ args: T) throws -> PythonObject
    where T.Element == (key: String, value: PythonObject) {
        //try throwPythonErrorIfPresent()
        fatalError()
        // An array containing positional arguments.
//        var positionalArgs: [PythonObject] = []
//        // A dictionary object for storing keyword arguments, if any exist.
//        var kwdictObject = PyDict_New()
//        
//        for (key, value) in args {
//            if key.isEmpty {
//                positionalArgs.append(value.pythonObject)
//                continue
//            }
//            // Initialize dictionary object if necessary.
//            if kwdictObject == nil { kwdictObject = PyDict_New()! }
//            // Add key-value pair to the dictionary object.
//            // TODO: Handle duplicate keys.
//            // In Python, `SyntaxError: keyword argument repeated` is thrown.
//            let k: PyPointer = key.pyPointer
//            let v = value.pythonObject.ptr
//            PyDict_SetItem(kwdictObject, k, v)
//            Py_DecRef(k)
//            Py_DecRef(v)
//        }
//        
//        defer { Py_DecRef(kwdictObject) } // Py_DecRef is `nil` safe.
//        
//        // Positional arguments are passed as a tuple of objects.
//        //let argTuple = pyTuple(positionalArgs)
//        let argTuple = positionalArgs.compactMap(\.ptr).pythonTuple
//        defer { Py_DecRef(argTuple) }
//        
//        // Python calls always return a non-null object when successful. If the
//        // Python function produces the equivalent of C `void`, it returns the
//        // `None` object. A `null` result of `PyObjectCall` happens when there is an
//        // error, like `self` not being a Python callable.
//        //let selfObject = base.ownedPyObject
//        //defer { Py_DecRef(selfObject) }
//        
//        let result = PyObject_Call(ptr, argTuple, kwdictObject)
//        return .init(getter: result)
    }
    
    private func _dynamicallyCall<T : Collection>(_ args: T) throws -> PythonObject
    where T.Element == (key: String, value: PyPointer) {
        //try throwPythonErrorIfPresent()
        
        // An array containing positional arguments.
        var positionalArgs: [PyPointer] = []
        // A dictionary object for storing keyword arguments, if any exist.
        var kwdictObject = PyDict_New()
        
        for (key, value) in args {
            if key.isEmpty {
                positionalArgs.append(value)
                continue
            }
            // Initialize dictionary object if necessary.
            if kwdictObject == nil { kwdictObject = PyDict_New()! }
            // Add key-value pair to the dictionary object.
            // TODO: Handle duplicate keys.
            // In Python, `SyntaxError: keyword argument repeated` is thrown.
            let k: PyPointer = key.pyPointer
            let v = value
            PyDict_SetItem(kwdictObject, k, value)
            Py_DecRef(k)
            Py_DecRef(v)
        }
        
        defer { Py_DecRef(kwdictObject) } // Py_DecRef is `nil` safe.
        
        // Positional arguments are passed as a tuple of objects.
        //let argTuple = pyTuple(positionalArgs)
        let argTuple = positionalArgs.pythonTuple
        defer { Py_DecRef(argTuple) }
        
        // Python calls always return a non-null object when successful. If the
        // Python function produces the equivalent of C `void`, it returns the
        // `None` object. A `null` result of `PyObjectCall` happens when there is an
        // error, like `self` not being a Python callable.
        //let selfObject = base.ownedPyObject
        //defer { Py_DecRef(selfObject) }
        
        let result = PyObject_Call(ptr, argTuple, kwdictObject)
        //let result =  (<#T##callable: UnsafeMutablePointer<PyObject>!##UnsafeMutablePointer<PyObject>!#>, <#T##args: UnsafePointer<UnsafeMutablePointer<PyObject>?>!##UnsafePointer<UnsafeMutablePointer<PyObject>?>!#>, <#T##nargsf: Int##Int#>, <#T##kwnames: UnsafeMutablePointer<PyObject>!##UnsafeMutablePointer<PyObject>!#>)
        return .init(getter: result!)
    }
    
    //    @discardableResult
    //    public func dynamicallyCall(withKeywordArguments args: [(key: String, value: PythonObject)] = []) throws -> PythonObject {
    //            return try _dynamicallyCall(args)
    //        }
    //    @discardableResult
    //    public func dynamicallyCall(withKeywordArguments args: [(key: String, value: PyPointer)] = []) throws -> PythonObject {
    //        return try _dynamicallyCall(args)
    //    }
}

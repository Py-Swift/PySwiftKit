import Foundation
import PySwiftKit
//import PyDeserializing
import PySerializing
import PythonCore
//import PythonTypeAlias

extension PythonPointer {
    @inlinable public func callAsFunction_<R: PyDeserialize>(_ args: [PySerialize]) throws -> R {
        
        let _args: [PyPointer?] = args.map(\.pyPointer)
        //            _args.enumerated().forEach { i, ptr in
        //                assert(ptr != nil, "arg pos \(i) is \(ptr.printString)")
        //            }
        guard let result = _args.withUnsafeBufferPointer({ PyObject_Vectorcall(self, $0.baseAddress, args.count, nil) }) else {
            throw PythonError.call
        }
        //let rtn = PyObject_VectorcallMethod(py_name, _args , _args.count, nil)
        _args.forEach(Py_DecRef)
//        for a in _args {
//            if a != self {
//                Py_DecRef(a)
//            }
//        }
        //py_name.decref()
        if R.self == PyPointer.self {
            return result as! R
        }
        
        let rtn = try R(object: result)
        Py_DecRef(result)
        return rtn
    }
    
    @inlinable public func callAsFunction_(_ args: [PySerialize]) throws -> PyPointer {
        
        let _args: [PyPointer?] = args.map(\.pyPointer)

        guard let result = _args.withUnsafeBufferPointer({ PyObject_Vectorcall(self, $0.baseAddress, args.count, nil) }) else {
            PyErr_Print()
            throw PythonError.call
        }
        _args.forEach(Py_DecRef)
 
        return result
    }
    
}

public func GenericPyCFuncCall<A: PyDeserialize, B: PyDeserialize, R: PySerialize>(args: UnsafePointer<PyPointer?>?, count: Int,_ function: @escaping ((A,B)-> R) ) -> R? {
    do {
        guard count > 1, let args = args else { throw PythonError.call }
        return function(
            try A(object: args[0]!),
            try B(object: args[1]!)
        )
    } catch let err as PythonError {
        err.raiseError()
    } catch _ { }
    return nil
}

public func GenericPyCFuncCall<A: PyDeserialize, B: PyDeserialize, C: PyDeserialize, R: PySerialize>(args: UnsafePointer<PyPointer?>?, count: Int,_ function: @escaping ((A,B,C)-> R) ) -> R? {
    do {
        guard count > 2, let args = args else { throw PythonError.index }
        return function(
            try A(object: args[0]!),
            try B(object: args[1]!),
            try C(object: args[2]!)
        )
    } catch let err as PythonError {
        err.raiseError()
    } catch _ { }
    return nil
}

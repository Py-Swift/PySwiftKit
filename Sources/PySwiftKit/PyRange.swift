//
//  PyRange.swift
//  PySwiftKit
//
import CPython

let PyRange = {
    let builtins = PyEval_GetBuiltins()!
    //pyPrint(builtins)
    let range = PyDict_GetItemString(builtins, "range")
    assert(range != nil)
    return range!
}()

public func PyRange_new(start: Int, stop: Int) throws -> PyPointer {
    
    guard
        let pystart = PyLong_FromLong(start),
        let pystop = PyLong_FromLong(stop),
        let pyrange = PyObject_Vectorcall(PyRange, [pystart, pystop], 2, nil)
    else {
        PyErr_Print()
        throw PyStandardException.typeError
    }
    
    Py_DecRef(pystart)
    Py_DecRef(pystop)
    
    return pyrange
}

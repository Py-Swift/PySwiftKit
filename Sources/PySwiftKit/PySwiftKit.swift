//
//  Untitled.swift
//  PySwiftKit
//
import CPython




public extension PyPointer {
    func decRef() { Py_DecRef(self) }
}

public func pyPrint(_ o: PyPointer) {
    PyObject_Print(o, stdout, Py_PRINT_RAW)
    print()
}

@inlinable
public func PyHasGIL() -> Bool {
    PyGILState_Check() == 1
}

@inlinable
public func PyGIL_Released() -> Bool {
    PyGILState_Check() == 0
}

@inlinable
public func withGIL(handle: @escaping () throws -> Void ) rethrows {
    let gil = PyGILState_Ensure()
    try handle()
    PyGILState_Release(gil)
}

@inlinable
public func withAutoGIL(handle: @escaping () throws -> Void ) rethrows {
    let has_gil = PyHasGIL()
    if has_gil {
        try handle()
        //PyEval_SaveThread()
        return
    }
    
    let gil = PyGILState_Ensure()
    try handle()
    PyGILState_Release(gil)
}

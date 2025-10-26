//
//  PySwiftKit.swift
//  PySwiftKit
//
import CPython
@_exported import PyProtocols
@_exported import CPySwiftObject


public extension PyPointer {
    func decRef() { Py_DecRef(self) }
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

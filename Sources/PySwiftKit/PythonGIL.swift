//
//  GIL.swift
//


import Foundation
//#if BEEWARE
import PythonCore

//#endif
@inlinable
public func PyHasGIL() -> Bool {
    PyGILState_Check() == 1
}

@inlinable
public func PyGILisReleased() -> Bool {
    PyGILState_Check() == 0
}

@inlinable
public func withGIL(handle: @escaping ()->Void ) {
    let gil = PyGILState_Ensure()
    handle()
    PyGILState_Release(gil)
}

@inlinable
public func withGIL<T>(_ target: T ,handle: @escaping (T)->Void ) {
    let gil = PyGILState_Ensure()
    handle(target)
    PyGILState_Release(gil)
}

@inlinable
public func gilCheck() -> Bool {
    PyGILState_Check() == 1
}

@discardableResult
public func gilCheck(_ title: String) -> Bool {
    let state = PyGILState_Check() == 1
    
    if state  {
        print("/* \(title) have the GIL */",state)
    } else {
        print("/* \(title) have no GIL */",state)
    }
    return state
}

@inlinable
public func withAutoGIL(handle: @escaping ()->Void ) {
    if PyGILState_Check() == 0 {
        if let state = PyThreadState_Get() {
            print("getting thread state:", state.pointee)
            gilCheck("PyThreadState_Get")
            handle()
            
            print(PyEval_RestoreThread(state) )
        } else {
            let gil = PyGILState_Ensure()
            handle()
            PyGILState_Release(gil)
        }
        
    } else {
        handle()
    }
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

extension DispatchQueue {
    
    @inlinable
    public func withGIL(handle: @escaping ()->Void ) {
        self.async {
            let gil = PyGILState_Ensure()
            handle()
            PyGILState_Release(gil)
        }
    }
}

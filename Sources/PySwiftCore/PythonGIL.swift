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
    print("autogil")
    if PyGILState_Check() == 0 {
        if let state = PyThreadState_Get() {
            print("getting thread state:", state.pointee)
            gilCheck("PyThreadState_Get")
            handle()
            
            print(PyEval_RestoreThread(state) )
            return
        }
        let gil = PyGILState_Ensure()
        handle()
        PyGILState_Release(gil)
        return
    }
    
    gilCheck("autogil")
    //
    handle()

    PyEval_SaveThread()
}

@inlinable
public func withAutoGIL(handle: @escaping () throws -> Void ) rethrows {
    let has_gil = PyHasGIL()
    //print("withAutoGIL has gil", has_gil)
    //var state: PyThreadState = .init()
    
    
    if has_gil {
        try handle()
        //PyGILState_Release(gil)
        PyEval_SaveThread()
        return
    }

    //print("ensuring gil")
    let gil = PyGILState_Ensure()
    try handle()
    //PyEval_SaveThread()
    PyGILState_Release(gil)
    //print("gil removed")
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

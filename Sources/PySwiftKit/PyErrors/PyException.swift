//
//  PyException.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 24/10/2025.
//
import CPython

public protocol PyException: Error {
    func pyException() -> PyPointer
}

public extension PyException {
    
    func pyExceptionError() {
        if let py_err = PyErr_Occurred() {
            PyErr_Print()
            py_err.decRef()
        } else {
            localizedDescription.withCString { PyErr_SetString(pyException(), $0) }
        }
    }
    
    func raiseException(exc: PyPointer, _ message: String) {
        message.withCString { PyErr_SetString(exc, $0) }
    }
    
    func triggerError(_ msg: String) {
        msg.withCString { PyErr_SetString(pyException(), $0) }
    }
    
}

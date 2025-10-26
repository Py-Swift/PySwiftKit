//
//  PySerializing.swift
//  PySwiftKit_rewrite
//
import CPython
import PySwiftKit


public func PyObject_SetAttr<T>(_ object: PyPointer, key: String, value: T) where T: PySerialize {
    let py_value = value.pyPointer()
    _ = key.withCString { PyObject_SetAttrString(object, $0, py_value) }
    Py_DecRef(py_value)
}

public func PyDict_SetItem<T>(_ object: PyPointer, key: String, value: T) throws where T: PySerialize {
    let py_value = value.pyPointer()
    _ = key.withCString { PyDict_SetItemString(object, $0, py_value) }
    Py_DecRef(py_value)
}

public func PyTuple_SetItem<T>(_ object: PyPointer, index: Int, value: T) throws where T: PySerialize {
    let py_value = value.pyPointer()
    _ = PyTuple_SetItem(object, index, py_value)
    Py_DecRef(py_value)
}

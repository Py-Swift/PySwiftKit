
import Foundation
import CPython


@inlinable public func PyBool_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyBool_Type) == 1
}

@inlinable public func PyFloat_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyFloat_Type) == 1
}

@inlinable public func PyLong_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyLong_Type) == 1
}

@inlinable public func PyUnicode_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyUnicode_Type) == 1
}




@inlinable public func PyList_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyList_Type) == 1
}

@inlinable public func PyTuple_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyBool_Type) == 1
}

@inlinable public func PyDict_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyDict_Type) == 1
}



@inlinable public func PySet_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PySet_Type) == 1
}

@inlinable public func PyBytes_Check(_ object: PyPointer) -> Bool {
	//PyObject_TypeCheck(object, &PyBytes_Type) == 1
	PyType_HasFeature(Py_TYPE(object), Py_TPFLAGS_BYTES_SUBCLASS) == 1
}

@inlinable public func PyByteArray_Check(_ object: PyPointer) -> Bool {
	PyObject_TypeCheck(object, &PyByteArray_Type) == 1
//	PyType_HasFeature(Py_TYPE(object), py_tpfl) == 1
}

@inlinable public func PyMemoryView_Check(_ object: PyPointer) -> Bool {
	Py_IS_TYPE(object, &PyMemoryView_Type) == 1
}

@inlinable public func PySequence_Check(_ object: PyPointer) -> Bool {
	PySequence_Check(object) == 1
}



@inlinable public func PyObject_TypeCheck(_ ob: UnsafeMutablePointer<PyObject>!, _ type: UnsafeMutablePointer<PyTypeObject>!) -> Bool {
	PyObject_TypeCheck(ob, type) == 1
}





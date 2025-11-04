//
//  _PySwiftObject.c
//  
//
//  Created by CodeBuilder on 21/01/2024.
//

#include "CPySwiftObject.h"

PyModuleDef_Base _PyModuleDef_HEAD_INIT = PyModuleDef_HEAD_INIT;

//long PySwiftObject_dict_offset = offsetof(PySwiftObject, dict);
long PySwiftObject_size = sizeof(PySwiftObject);

PySwiftObject* PySwiftObject_Cast(PyObject* o) {
	return (PySwiftObject *) o;
}

PyObject* PySwiftObject_New(PyTypeObject *type, PyObject *x, PyObject* y) {
    return type->tp_alloc(type, 0);
}

PySwiftObject* _PySwiftObject_Create(PyTypeObject *type, void *swift_ptr) {
    PySwiftObject *o = (PySwiftObject *)(type->tp_alloc(type, 0));
    o->swift_ptr = swift_ptr;
    return o;
}

PyObject* PySwiftObject_Create(PyTypeObject *type, void *swift_ptr) {
    PySwiftObject *o = (PySwiftObject *)(type->tp_alloc(type, 0));
    o->swift_ptr = swift_ptr;
    return o;
}

PyObject* _PySwiftObject_New(PyTypeObject *type) {
    return type->tp_alloc(type, 0);
}

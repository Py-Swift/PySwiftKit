//
//  _PySwiftObject.h
//  
//
//  Created by CodeBuilder on 21/01/2024.
//

#ifndef CPySwiftObject_h
#define CPySwiftObject_h

//#include <Python/Python.h>
#include "CPython.h"

typedef struct {
	PyObject_HEAD
	PyObject* dict;
	void* swift_ptr;
} PySwiftObject;

PyModuleDef_Base _PyModuleDef_HEAD_INIT;

//long PySwiftObject_dict_offset;
long PySwiftObject_size;

PyObject* PySwiftObject_New(PyTypeObject *type, PyObject *x, PyObject* y);
PyObject* PySwiftObject_Create(PyTypeObject *type, void *swift_object);
PySwiftObject* _PySwiftObject_Create(PyTypeObject *type, void *swift_object);
PyObject* _PySwiftObject_New(PyTypeObject *type);
PySwiftObject* PySwiftObject_Cast(PyObject* o);

inline
void* PyObject_AS_SwiftPtr(PyObject* o);


typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptr;
    int swift_info;
} PySwiftObject_A;

typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptr;
    PyObject* sub_class;
} PySwiftObject_B;

typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptr;
    int swift_info;
    PyObject* sub_class;
} PySwiftObject_AB;

typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptr;
    int swift_info;
    PyObject* sub_classes[2];
} PySwiftObject_AB2;

typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptr;
    int swift_info;
    PyObject* sub_classes[3];
} PySwiftObject_AB3;

typedef struct {
    PyObject_HEAD
    PyObject* dict;
    void* swift_ptrs[2];
    int swift_info;
} PySwiftObject2;

#endif /* CPySwiftObject_h */

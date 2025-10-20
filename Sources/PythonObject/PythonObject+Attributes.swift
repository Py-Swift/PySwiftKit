////
////  PythonPointer+Attributes.swift
////  metacam
////
////  Created by MusicMaker on 01/03/2022.
////
//
//import Foundation
//#if BEEWARE
//import CPython
//#endif
//
//extension PythonPointer {
//    
//    
//    @inlinable
//    public func getAttr(withNoDecRef key: PythonPointer, dec_ref: Bool = true) -> Int {
//        let attr = PyObject_GetAttr(self, key)
//        let value = PyLong_AsLong(attr)
//        if dec_ref { Py_DecRef(attr) }
//        return value
//    }
//    
////    @inlinable
////    func getAttr(key: PythonPointer?, dec_ref: Bool = true) -> Int {
////        let attr = PyObject_GetAttr(self, key)
////        let value = PyLong_AsLong(attr)
////        if dec_ref { Py_DecRef(attr) }
////        return value
////    }
//    
//}
//
//extension PythonObject {
//    
////    @inlinable
////    func setAttr(key: String, value: PythonPointer?) {
////        PyObject_SetAttrString(ptr, key, value)
////    }
////
////    @inlinable
////    func setAttr(key: PythonPointer?, value: PythonPointer?) {
////        PyObject_SetAttr(ptr, key, value)
////    }
//    
//    @inlinable
//    public func setAttr(key: String, value: PythonObject) {
//        PyObject_SetAttrString(ptr, key, value.ptr)
//    }
//    
//    @inlinable
//    public func setAttr(key: PythonObject, value: PythonObject) {
//        PyObject_SetAttr(ptr, key.ptr, value.ptr)
//    }
//    
//    @inlinable
//    public func getAttr(key: String) -> PythonPointer? {
//        key.withCString { string in
//            PyObject_GetAttrString(ptr, string)
//        }
//        
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonPointer) -> PythonPointer? {
//        PyObject_GetAttr(ptr, key)
//    }
//    
//    @inlinable
//    public func getAttr(key: String) -> PythonPointer {
//        PyObject_GetAttrString(ptr, key)
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonPointer) -> PythonPointer {
//        PyObject_GetAttr(ptr, key)
//    }
//    
////    @inlinable
////    func getAttr(key: PythonPointer?) -> PythonPointer {
////        PyObject_GetAttr(ptr, key)
////    }
////    
////    @inlinable
////    func getAttr(key: PythonPointer?) -> PythonPointer? {
////        PyObject_GetAttr(ptr, key)
////    }
//    
//    @inlinable
//    public func getAttr(key: String) -> PythonObject {
//        PythonObject(ptr: PyObject_GetAttrString(ptr, key), from_getter: true)
//        
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonPointer) -> PythonObject {
//        PythonObject(ptr: PyObject_GetAttr(ptr, key), from_getter: true)
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonObject) -> PythonObject {
//        PythonObject(ptr: PyObject_GetAttr(ptr, key.ptr), from_getter: true)
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonObject) -> PythonPointer {
//        PyObject_GetAttr(ptr, key.ptr)
//    }
//    
//    @inlinable
//    public func getAttr(key: PythonObject) -> PythonPointer? {
//        PyObject_GetAttr(ptr, key.ptr)
//    }
//    
//    
//
//}
//
//
//

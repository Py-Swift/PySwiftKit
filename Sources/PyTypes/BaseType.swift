//
//  File.swift
//  
//
//  Created by CodeBuilder on 19/05/2024.
//

import Foundation
import PythonCore
import PySwiftObject
import PySwiftKit


fileprivate var BaseMethods: [PyMethodDef] = [
	// hardcoded py func == def mainMain()
	.init(ml_name: makeCString(from: "funcMain"), ml_meth: {_, _ in
		print("triggered funcMain")
		return .None
	}, ml_flags: METH_VARARGS, ml_doc: nil),
	.init()
]
public extension PyTypeObject {
	
	static let PySwiftObject_dictoffset = MemoryLayout<PySwiftObject>.stride - MemoryLayout<PyObject>.stride
	static let PySwiftObject_basicsize = MemoryLayout<PySwiftObject>.stride
	
	static func BaseType(name: String) -> PyTypeObject {
		
		return .init(
            ob_base: .init(),
			tp_name: cString(name),
			tp_basicsize: PySwiftObject_dictoffset,
			tp_itemsize: 0,
			tp_dealloc: nil,
			tp_vectorcall_offset: 0,
			tp_getattr: nil,
			tp_setattr: nil,
			tp_as_async: nil,
			tp_repr: nil,
			tp_as_number: nil,
			tp_as_sequence: nil,
			tp_as_mapping: nil,
			tp_hash: nil,
			tp_call: nil,
			tp_str: nil,
			tp_getattro: PyObject_GenericGetAttr,
			tp_setattro: PyObject_GenericSetAttr,
			tp_as_buffer: nil,
			tp_flags: NewPyObjectTypeFlag.DEFAULT,
			tp_doc: nil,
			tp_traverse: nil,
			tp_clear: nil,
			tp_richcompare: nil,
			tp_weaklistoffset: 0,
			tp_iter: nil,
			tp_iternext: nil,
			tp_methods: .init(&BaseMethods),
			tp_members: nil,
			tp_getset: nil,
			tp_base: nil,
			tp_dict: nil,
			tp_descr_get: nil,
			tp_descr_set: nil,
			tp_dictoffset: PySwiftObject_dictoffset,
			tp_init: nil,
			tp_alloc: nil,
			tp_new: nil,
			tp_free: nil,
			tp_is_gc: nil,
			tp_bases: nil,
			tp_mro: nil,
			tp_cache: nil,
			tp_subclasses: nil,
			tp_weaklist: nil,
			tp_del: nil,
			tp_version_tag: 11,
			tp_finalize: nil,
			tp_vectorcall: nil
		)
	}
	
	static func BaseMappingType(name: String, mapping: UnsafeMutablePointer<PyMappingMethods>? = nil) -> PyTypeObject {
		
		return .init(
			ob_base: .init(),
			tp_name: cString(name),
			tp_basicsize: PySwiftObject_dictoffset,
			tp_itemsize: 0,
			tp_dealloc: nil,
			tp_vectorcall_offset: 0,
			tp_getattr: nil,
			tp_setattr: nil,
			tp_as_async: nil,
			tp_repr: nil,
			tp_as_number: nil,
			tp_as_sequence: nil,
			tp_as_mapping: mapping,
			tp_hash: nil,
			tp_call: nil,
			tp_str: nil,
			tp_getattro: PyObject_GenericGetAttr,
			tp_setattro: PyObject_GenericSetAttr,
			tp_as_buffer: nil,
			tp_flags: NewPyObjectTypeFlag.DEFAULT,
			tp_doc: nil,
			tp_traverse: nil,
			tp_clear: nil,
			tp_richcompare: nil,
			tp_weaklistoffset: 0,
			tp_iter: nil,
			tp_iternext: nil,
			tp_methods: .init(&BaseMethods),
			tp_members: nil,
			tp_getset: nil,
			tp_base: nil,
			tp_dict: nil,
			tp_descr_get: nil,
			tp_descr_set: nil,
			tp_dictoffset: PySwiftObject_dictoffset,
			tp_init: nil,
			tp_alloc: nil,
			tp_new: nil,
			tp_free: nil,
			tp_is_gc: nil,
			tp_bases: nil,
			tp_mro: nil,
			tp_cache: nil,
			tp_subclasses: nil,
			tp_weaklist: nil,
			tp_del: nil,
			tp_version_tag: 11,
			tp_finalize: nil,
			tp_vectorcall: nil
		)
	}
}

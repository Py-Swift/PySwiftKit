
import Foundation
@preconcurrency
import CPython

//import PyEncode




//public protocol PyTypeObjectAllProtocol: PyTypeProtocol {
//	//static var tp_new: PySwift_newfunc { get }
//	static var tp_name: UnsafePointer<CChar> { get }
//	static var tp_init: PySwift_initproc { get }
//	static var tp_dealloc: PySwift_destructor { get }
//	
//	
//	static var tp_repr: PySwift_reprfunc { get }
//	static var tp_str: PySwift_reprfunc { get }
//	static var tp_hash: PySwift_HashFunc { get }
//	static var tp_doc: UnsafePointer<CChar>? { get }
//	
//	static var tp_as_async: UnsafeMutablePointer<PyAsyncMethods>? { get set }
//	static var tp_as_number: UnsafeMutablePointer<PyNumberMethods>? { get set }
//	static var tp_as_sequence: UnsafeMutablePointer<PySequenceMethods>? { get set }
//	static var tp_as_mapping: UnsafeMutablePointer<PyMappingMethods>? { get set }
//	static var tp_as_buffer: UnsafeMutablePointer<PyBufferProcs>? { get set }
//	
//	static var tp_methods: [PyMethodDef] { get set }
//	//static var tp_members: [PyMemberDef] { get set }
//	static var tp_getset: [PyGetSetDef] { get set }
//	
//	static var tp_base: UnsafeMutablePointer<PyTypeObject> { get set }
//	
//	static var tp_iter: PySwift_getiterfunc { get }
//	static var tp_iternext: PySwift_iternextfunc { get }
//	
//	static var pyTypeObject: PyTypeObject { get  }
//	static func asPyPointer(_ target: Self) -> PyPointer
//	static func asPyPointer(unretained target: Self) -> PyPointer
//}

//extension PyTypeObjectAllProtocol {
//	
//}

public extension UnsafeMutablePointer where Pointee == PyTypeObject {

	@inline(never) static var PyType: Self { .init(&PyType_Type) }
	@inline(never) static var PyBaseObject: Self { .init(&PyBaseObject_Type) }
	@inline(never) static var PySuper: Self { .init(&PySuper_Type) }
	//static var _None: Self { .init(&pynone) }
	//static var PyNotImplemented: Self { .init(&_PyNotImplemented_Type) }
	@inline(never) static var PyByteArray: Self { .init(&PyByteArray_Type) }
	@inline(never) static var PyByteArrayIter: Self { .init(&PyByteArrayIter_Type) }
	@inline(never) static var PyBytes: Self { .init(&PyBytes_Type) }
	@inline(never) static var PyBytesIter: Self { .init(&PyBytesIter_Type) }
	@inline(never) static var PyUnicode: Self { .init(&PyUnicode_Type) }
	@inline(never) static var PyUnicodeIter: Self { .init(&PyUnicodeIter_Type) }
	@inline(never) static var PyLong: Self { .init(&PyLong_Type) }
	@inline(never) static var PyBool: Self { .init(&PyBool_Type) }
	@inline(never) static var PyFloat: Self { .init(&PyFloat_Type) }
	@inline(never) static var PyComplex: Self { .init(&PyComplex_Type) }
	@inline(never) static var PyRange: Self { .init(&PyRange_Type) }
	@inline(never) static var PyRangeIter: Self { .init(&PyRangeIter_Type) }
	@inline(never) static var PyLongRangeIter: Self { .init(&PyLongRangeIter_Type) }
	//static var PyManagedBuffer: Self { .init(&_PyManagedBuffer_Type) }
	@inline(never) static var PyMemoryView: Self { .init(&PyMemoryView_Type) }
	@inline(never) static var PyTuple: Self { .init(&PyTuple_Type) }
	@inline(never) static var PyTupleIter: Self { .init(&PyTupleIter_Type) }
	@inline(never) static var PyList: Self { .init(&PyList_Type) }
	@inline(never) static var PyListIter: Self { .init(&PyListIter_Type) }
	@inline(never) static var PyListRevIter: Self { .init(&PyListRevIter_Type) }
	@inline(never) static var PyDict: Self { .init(&PyDict_Type) }
	@inline(never) static var PyDictKeys: Self { .init(&PyDictKeys_Type) }
	@inline(never) static var PyDictValues: Self { .init(&PyDictValues_Type) }
	@inline(never) static var PyDictItems: Self { .init(&PyDictItems_Type) }
	@inline(never) static var PyDictIterKey: Self { .init(&PyDictIterKey_Type) }
	@inline(never) static var PyDictIterValue: Self { .init(&PyDictIterValue_Type) }
	@inline(never) static var PyDictIterItem: Self { .init(&PyDictIterItem_Type) }
	@inline(never) static var PyDictRevIterKey: Self { .init(&PyDictRevIterKey_Type) }
	@inline(never) static var PyDictRevIterItem: Self { .init(&PyDictRevIterItem_Type) }
	@inline(never) static var PyDictRevIterValue: Self { .init(&PyDictRevIterValue_Type) }
	@inline(never) static var PyODict: Self { .init(&PyODict_Type) }
	@inline(never) static var PyODictIter: Self { .init(&PyODictIter_Type) }
	@inline(never) static var PyODictKeys: Self { .init(&PyODictKeys_Type) }
	@inline(never) static var PyODictItems: Self { .init(&PyODictItems_Type) }
	@inline(never) static var PyODictValues: Self { .init(&PyODictValues_Type) }
	@inline(never) static var PyEnum: Self { .init(&PyEnum_Type) }
	@inline(never) static var PyReversed: Self { .init(&PyReversed_Type) }
	@inline(never) static var PySet: Self { .init(&PySet_Type) }
	@inline(never) static var PyFrozenSet: Self { .init(&PyFrozenSet_Type) }
	@inline(never) static var PySetIter: Self { .init(&PySetIter_Type) }
	@inline(never) static var PyCFunction: Self { .init(&PyCFunction_Type) }
	@inline(never) static var PyCMethod: Self { .init(&PyCMethod_Type) }
	@inline(never) static var PyModule: Self { .init(&PyModule_Type) }
	@inline(never) static var PyModuleDef: Self { .init(&PyModuleDef_Type) }
	@inline(never) static var PyFunction: Self { .init(&PyFunction_Type) }
	@inline(never) static var PyClassMethod: Self { .init(&PyClassMethod_Type) }
	@inline(never) static var PyStaticMethod: Self { .init(&PyStaticMethod_Type) }
	@inline(never) static var PyMethod: Self { .init(&PyMethod_Type) }
	@inline(never) static var PyInstanceMethod: Self { .init(&PyInstanceMethod_Type) }
	@inline(never) static var PyStdPrinter: Self { .init(&PyStdPrinter_Type) }
	@inline(never) static var PyCapsule: Self { .init(&PyCapsule_Type) }
	@inline(never) static var PyCode: Self { .init(&PyCode_Type) }
	@inline(never) static var PyFrame: Self { .init(&PyFrame_Type) }
	@inline(never) static var PyTraceBack: Self { .init(&PyTraceBack_Type) }
	@inline(never) static var PySlice: Self { .init(&PySlice_Type) }
	@inline(never) static var PyEllipsis: Self { .init(&PyEllipsis_Type) }
	@inline(never) static var PyCell: Self { .init(&PyCell_Type) }
	@inline(never) static var PySeqIter: Self { .init(&PySeqIter_Type) }
	@inline(never) static var PyCallIter: Self { .init(&PyCallIter_Type) }
	@inline(never) static var PyGen: Self { .init(&PyGen_Type) }
	@inline(never) static var PyCoro: Self { .init(&PyCoro_Type) }
	//static var PyCoroWrapper: Self { .init(&_PyCoroWrapper_Type) }
	@inline(never) static var PyAsyncGen: Self { .init(&PyAsyncGen_Type) }
	@inline(never) static var PyAsyncGenASend: Self { .init(&_PyAsyncGenASend_Type) }
	//static var PyAsyncGenWrappedValue: Self { .init(&_PyAsyncGenWrappedValue_Type) }
	//static var PyAsyncGenAThrow: Self { .init(&_PyAsyncGenAThrow_Type) }
	@inline(never) static var PyClassMethodDescr: Self { .init(&PyClassMethodDescr_Type) }
	@inline(never) static var PyGetSetDescr: Self { .init(&PyGetSetDescr_Type) }
	@inline(never) static var PyMemberDescr: Self { .init(&PyMemberDescr_Type) }
	@inline(never) static var PyMethodDescr: Self { .init(&PyMethodDescr_Type) }
	@inline(never) static var PyWrapperDescr: Self { .init(&PyWrapperDescr_Type) }
	@inline(never) static var PyDictProxy: Self { .init(&PyDictProxy_Type) }
	@inline(never) static var PyProperty: Self { .init(&PyProperty_Type) }
	//static var PyMethodWrapper: Self { .init(&_PyMethodWrapper_Type) }
	@inline(never) static var PyGenericAliasType: Self { .init(&Py_GenericAliasType) }
	@inline(never) static var PyWeakrefRefType: Self { .init(&_PyWeakref_RefType) }
	@inline(never) static var PyWeakrefProxyType: Self { .init(&_PyWeakref_ProxyType) }
	@inline(never) static var PyWeakrefCallableProxyType: Self { .init(&_PyWeakref_CallableProxyType) }
	@inline(never) static var PyPickleBuffer: Self { .init(&PyPickleBuffer_Type) }
	@inline(never) static var PyContext: Self { .init(&PyContext_Type) }
	@inline(never) static var PyContextVar: Self { .init(&PyContextVar_Type) }
	@inline(never) static var PyFilter: Self { .init(&PyFilter_Type) }
	@inline(never) static var PyMap: Self { .init(&PyMap_Type) }
	@inline(never) static var PyZip: Self { .init(&PyZip_Type) }
	@inline(never) static var PyDateTime: Self { PyDateTimeAPI!.pointee.DateTimeType! }
}

//
//  Untitled.swift
//  PySwiftKit
//
import CPython
import CPySwiftObject


public typealias PyPointer = UnsafeMutablePointer<PyObject>
public typealias PyTypePointer = UnsafeMutablePointer<PyTypeObject>


public typealias PySequenceBuffer = UnsafeBufferPointer<UnsafeMutablePointer<PyObject>?>

public typealias PyBufferPointer = UnsafeMutablePointer<Py_buffer>

public typealias CString = UnsafePointer<CChar>
public typealias MutableCString = UnsafeMutablePointer<CChar>


public typealias PythonModuleImportFunc = @convention(c) () -> PyPointer?

public typealias PyGetter = (@convention(c) (_ s: PyPointer?, _ raw: UnsafeMutableRawPointer?) -> PyPointer?)?
public typealias PySetter = (@convention(c) (_ s: PyPointer?,_ key: PyPointer?, _ raw: UnsafeMutableRawPointer?) -> Int32)?


public typealias VectorArgs = UnsafePointer<PyPointer?>?
public typealias VectorCallArgs = UnsafeMutablePointer<PyPointer?>

public typealias PyCVectorCallKeywords = (@convention(c) ( _ s: PyPointer?, _ args: VectorArgs, _ count: Int, _ kwnames: PyPointer? ) -> PyPointer? )?
public typealias PyCVectorCall = (@convention(c) ( _ s: PyPointer?, _ args: VectorArgs, _ count: Int ) -> PyPointer? )?
public typealias PyCMethodVectorCall = (@convention(c) ( _ s: PyPointer?, _ type: PyTypePointer?, _ args: VectorArgs, _ count: Int, _ kwnames: PyPointer? ) -> PyPointer? )?


public typealias PySequence_Length_func = (@convention(c) (_ s: PyPointer?) -> Py_ssize_t )?
public typealias PySequence_Concat_func = (@convention(c) (_ lhs: PyPointer?,_ rhs: PyPointer?) -> PyPointer?)?
public typealias PySequence_Repeat_func = (@convention(c) (_ s: PyPointer?,_ count: Py_ssize_t) -> PyPointer?)?
public typealias PySequence_Item_func = (@convention(c) (_ s: PyPointer?,_ idx: Py_ssize_t) -> PyPointer?)?

public typealias PySequence_Ass_Item_func = (@convention(c) (_ s: PyPointer?,_ idx: Py_ssize_t,_ item: PyPointer?) -> Int32)?
public typealias PySequence_Contains_func = (@convention(c) (_ s: PyPointer?,_ o: PyPointer?) -> Int32)?
public typealias PySequence_Inplace_Concat_func = (@convention(c) (_ lhs: PyPointer?,_ rhs: PyPointer?) -> PyPointer?)?
public typealias PySequence_Inplace_Repeat_func = (@convention(c) (_ s: PyPointer?,_ count: Py_ssize_t) -> PyPointer?)?



// PySwiftObject

public typealias PySwiftCFunc = (@convention(c) (_ s: PySwiftObjectPointer?, _ args: PyPointer?) -> PyPointer?)?
public typealias PySwiftCVectorCall = (@convention(c) ( _ s: PySwiftObjectPointer?, _ args: VectorArgs, _ count: Int ) -> PyPointer? )?
public typealias PySwiftCVectorCallKeywords = (@convention(c) ( _ s: PySwiftObjectPointer?, _ args: VectorArgs, _ count: Int, _ kwnames: PyPointer? ) -> PyPointer? )?
public typealias PySwiftCMethodVectorCall = (@convention(c) ( _ s: PySwiftObjectPointer?, _ type: PyTypePointer?, _ args: VectorArgs, _ count: Int, _ kwnames: PyPointer? ) -> PyPointer? )?


public typealias PySwiftSequence_Item_func = (@convention(c) (_ s: PySwiftObjectPointer?,_ idx: Py_ssize_t) -> PyPointer?)?

public typealias PySwift__setitem__ = (@convention(c) (_ s: PySwiftObjectPointer?,_ idx: Py_ssize_t,_ item: PyPointer?) -> Int32)?


public typealias PySwift__len__ = (@convention(c) (_ s: PySwiftObjectPointer?) -> Py_ssize_t )?
public typealias PySwift__getitem__ = (@convention(c) (_ s: PySwiftObjectPointer?,_ idx: Py_ssize_t) -> PyPointer? )?

public typealias PySwift__mgetitem__ = (@convention(c) (_ s: PySwiftObjectPointer?,_ key: PyPointer?) -> PyPointer? )?
public typealias PySwift__msetitem__ = (@convention(c) (_ s: PySwiftObjectPointer?,_ key: PyPointer?,_ item: PyPointer?) -> Int32)?

public typealias PyBuf_Get = (@convention(c) (_ s: PyPointer?,_ buf: PyBufferPointer?,_ flags: Int32) -> Int32)?
public typealias PyBuf_Release = (@convention(c) (_ s: PyPointer?,_ buf: PyBufferPointer?) -> Void )?

public typealias PySwiftBuf_Get = (@convention(c) (_ s: PySwiftObjectPointer?,_ buf: PyBufferPointer?,_ flags: Int32) -> Int32)?
public typealias PySwiftBuf_Release = (@convention(c) (_ s: PySwiftObjectPointer?,_ buf: PyBufferPointer?) -> Void )?


public typealias PySwift_HashFunc = (@convention(c) (_ s: PySwiftObjectPointer?) -> Int)?

public typealias PySwift_ReprFunc = (@convention(c) (_ s: PySwiftObjectPointer?) -> PyPointer?)?



public typealias PySwift_destructor = (@convention(c) (PySwiftObjectPointer?) -> Void)?
public typealias PySwift_visitproc = (@convention(c) (PySwiftObjectPointer?, UnsafeMutableRawPointer?) -> Int32)?

public typealias PySwift_traverseproc =  (@convention(c) (PySwiftObjectPointer?, visitproc?, UnsafeMutableRawPointer?) -> Int32)?
public typealias PySwift_newfunc = (@convention(c) (PyTypePointer?, PyPointer?, PyPointer?) -> PyPointer?)?
public typealias PySwift_initproc = (@convention(c) (PySwiftObjectPointer?, PyPointer?, PyPointer?) -> Int32)?
public typealias PySwift_unaryfunc = (@convention(c) (PySwiftObjectPointer?) -> PyPointer?)?
public typealias PySwift_reprfunc = PySwift_unaryfunc
public typealias PySwift_getattrfunc = (@convention(c) (PySwiftObjectPointer?, MutableCString?) -> PyPointer?)?
public typealias PySwift_setattrfunc = (@convention(c) (PySwiftObjectPointer?, MutableCString?, PyPointer?) -> Int32)?
public typealias PySwift_hashfunc = (@convention(c) (PySwiftObjectPointer?) -> Py_hash_t)?
public typealias PySwift_richcmpfunc = (@convention(c) (PySwiftObjectPointer?, PyPointer?, Int32) -> PyPointer?)?
public typealias PySwift_getiterfunc = PySwift_unaryfunc
public typealias PySwift_iternextfunc =  PySwift_unaryfunc
public typealias PySwift_lenfunc = (@convention(c) (PySwiftObjectPointer?) -> Py_ssize_t)?
public typealias PySwift_getbufferproc = (@convention(c) (PySwiftObjectPointer?, UnsafeMutablePointer<Py_buffer>?, Int32) -> Int32)?
public typealias PySwift_releasebufferproc = (@convention(c) (PySwiftObjectPointer?, UnsafeMutablePointer<Py_buffer>?) -> Void)?
public typealias PySwift_inquiry = (@convention(c) (PySwiftObjectPointer?) -> Int32)?

public typealias PySwift_binaryfunc = (@convention(c) (PySwiftObjectPointer?, PyPointer?) -> PyPointer?)?
public typealias PySwift_ternaryfunc = (@convention(c) (PySwiftObjectPointer?, PyPointer?, PyPointer?) -> PyPointer?)?
public typealias PySwift_ssizeargfunc = (@convention(c) (PySwiftObjectPointer?, Py_ssize_t) -> PyPointer?)?
public typealias PySwift_ssizeobjargproc = (@convention(c) (PySwiftObjectPointer?, Py_ssize_t, PyPointer?) -> Int32)?
public typealias PySwift_objobjproc = (@convention(c) (PySwiftObjectPointer?, PyPointer?) -> Int32)?
public typealias PySwift_objobjargproc = (@convention(c) (PySwiftObjectPointer?, PyPointer?, PyPointer?) -> Int32)?
public typealias PySwift_sendfunc = (@convention(c) (PySwiftObjectPointer?, PyPointer?, UnsafeMutablePointer<PyPointer?>?) -> PySendResult)?

public typealias PySwift_am_await = PySwift_unaryfunc

public typealias PySwift_am_aiter = PySwift_unaryfunc

public typealias PySwift_am_anext = PySwift_unaryfunc

public typealias PySwift_am_send = PySwift_sendfunc

public typealias PySwift_getter = (@convention(c) (_ s: PySwiftObjectPointer?, _ raw: UnsafeMutableRawPointer?) -> PyPointer?)?
public typealias PySwift_setter = (@convention(c) (_ s: PySwiftObjectPointer?,_ key: PyPointer?, _ raw: UnsafeMutableRawPointer?) -> Int32)?


// _PyCFunctionFastWithKeywords
public typealias PySwiftFunctionFastWithKeywords = (@convention(c) (PySwiftObjectPointer?, VectorArgs, Py_ssize_t, PyPointer?) -> PyPointer?)?

// _PyCFunctionFast
public typealias PySwiftFunctionFast = (@convention(c) (PySwiftObjectPointer?, VectorArgs, Py_ssize_t) -> PyPointer?)?

// PyCFunction
public typealias PySwiftFunction = (@convention(c) (PySwiftObjectPointer?, PyPointer?) -> PyPointer?)?

// PyCFunctionWithKeywords
public typealias PySwiftFunctionWithKeywords = (@convention(c) (PySwiftObjectPointer?, PyPointer?, PyPointer?) -> PyPointer?)?

// PyCMethod
public typealias PySwiftMethod = (@convention(c) (UnsafeMutablePointer<PyObject>?, UnsafeMutablePointer<PyTypeObject>?, VectorArgs, Int, PyPointer?) -> PyPointer?)?


public typealias PY_SEQUENCE_METHODS = PySequenceMethods

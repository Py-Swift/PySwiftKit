import Foundation

import PythonCore
import _PySwiftObject






// for other file

public typealias PySwift_destructor = (@convention(c) (PySwiftObjectPointer) -> Void)?
public typealias PySwift_visitproc = (@convention(c) (PySwiftObjectPointer, UnsafeMutableRawPointer?) -> Int32)?

public typealias PySwift_traverseproc =  (@convention(c) (PySwiftObjectPointer, visitproc?, UnsafeMutableRawPointer?) -> Int32)?
public typealias PySwift_newfunc = (@convention(c) (UnsafeMutablePointer<PyTypeObject>?, PyPointer?, PyPointer?) -> PyPointer?)?
public typealias PySwift_initproc = (@convention(c) (PySwiftObjectPointer, PyPointer?, PyPointer?) -> Int32)?
public typealias PySwift_unaryfunc = (@convention(c) (PySwiftObjectPointer) -> PyPointer?)?
public typealias PySwift_reprfunc = PySwift_unaryfunc
public typealias PySwift_getattrfunc = (@convention(c) (PySwiftObjectPointer, MutableCString?) -> PyPointer?)?
public typealias PySwift_setattrfunc = (@convention(c) (PySwiftObjectPointer, MutableCString?, PyPointer?) -> Int32)?
public typealias PySwift_hashfunc = (@convention(c) (PySwiftObjectPointer) -> Py_hash_t)?
public typealias PySwift_richcmpfunc = (@convention(c) (PySwiftObjectPointer, PyPointer?, Int32) -> PyPointer?)?
public typealias PySwift_getiterfunc = PySwift_unaryfunc
public typealias PySwift_iternextfunc =  PySwift_unaryfunc
public typealias PySwift_lenfunc = (@convention(c) (PySwiftObjectPointer) -> Py_ssize_t)?
public typealias PySwift_getbufferproc = (@convention(c) (PySwiftObjectPointer, UnsafeMutablePointer<Py_buffer>?, Int32) -> Int32)?
public typealias PySwift_releasebufferproc = (@convention(c) (PySwiftObjectPointer, UnsafeMutablePointer<Py_buffer>?) -> Void)?
public typealias PySwift_inquiry = (@convention(c) (PySwiftObjectPointer) -> Int32)?

public typealias PySwift_binaryfunc = (@convention(c) (PySwiftObjectPointer, PyPointer?) -> PyPointer?)?
public typealias PySwift_ternaryfunc = (@convention(c) (PySwiftObjectPointer, PyPointer?, PyPointer?) -> PyPointer?)?
public typealias PySwift_ssizeargfunc = (@convention(c) (PySwiftObjectPointer, Py_ssize_t) -> PyPointer?)?
public typealias PySwift_ssizeobjargproc = (@convention(c) (PySwiftObjectPointer, Py_ssize_t, PyPointer?) -> Int32)?
public typealias PySwift_objobjproc = (@convention(c) (PySwiftObjectPointer, PyPointer?) -> Int32)?
public typealias PySwift_objobjargproc = (@convention(c) (PySwiftObjectPointer, PyPointer?, PyPointer?) -> Int32)?
public typealias PySwift_sendfunc = (@convention(c) (PySwiftObjectPointer, PyPointer?, UnsafeMutablePointer<PyPointer?>?) -> PySendResult)?

public typealias PySwift_am_await = PySwift_unaryfunc

public typealias PySwift_am_aiter = PySwift_unaryfunc

public typealias PySwift_am_anext = PySwift_unaryfunc

public typealias PySwift_am_send = PySwift_sendfunc

public typealias PySwift_getter = (@convention(c) (_ s: PySwiftObjectPointer, _ raw: UnsafeMutableRawPointer?) -> PythonPointer?)?
public typealias PySwift_setter = (@convention(c) (_ s: PySwiftObjectPointer,_ key: PythonPointer?, _ raw: UnsafeMutableRawPointer?) -> Int32)?


// _PyCFunctionFastWithKeywords
public typealias PySwiftFunctionFastWithKeywords = (@convention(c) (PySwiftObjectPointer, VectorArgs, Py_ssize_t, PyPointer?) -> PyPointer?)?

// _PyCFunctionFast
public typealias PySwiftFunctionFast = (@convention(c) (PySwiftObjectPointer, VectorArgs, Py_ssize_t) -> PyPointer?)?

// PyCFunction
public typealias PySwiftFunction = (@convention(c) (PySwiftObjectPointer, PyPointer?) -> PyPointer?)?

// PyCMethod
public typealias PySwiftMethod = (@convention(c) (UnsafeMutablePointer<PyObject>?, UnsafeMutablePointer<PyTypeObject>?, VectorArgs, Int, PyPointer?) -> PyPointer?)?


public typealias PY_SEQUENCE_METHODS = PySequenceMethods

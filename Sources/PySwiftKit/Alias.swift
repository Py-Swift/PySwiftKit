

import Foundation

import PythonCore
import _PySwiftObject

public typealias PythonType = UnsafeMutablePointer<PyTypeObject>?
public typealias _PySwiftObjectPointer = UnsafeMutablePointer<PySwiftObject>
public typealias PySwiftObjectPointer = UnsafeMutablePointer<PySwiftObject>?
//public typealias PythonPointer = UnsafeMutablePointer<PyObject>//?
public typealias PythonPointer = PyPointer

protocol PyObjectProtocol {}
extension PythonPointer?: PyObjectProtocol {}

public typealias PythonPointerU = UnsafeMutablePointer<PyObject>
public typealias PySequenceBuffer = UnsafeBufferPointer<UnsafeMutablePointer<PyObject>?>

public typealias CString = UnsafePointer<CChar>
public typealias MutableCString = UnsafeMutablePointer<CChar>

public typealias PythonModuleImportFunc = @convention(c) () -> PythonPointer?
//public typealias PySwiftModuleImport = (CString, PythonModuleImportFunc)


public typealias PyGetter = (@convention(c) (_ s: PythonPointer?, _ raw: UnsafeMutableRawPointer?) -> PythonPointer?)?
public typealias PySetter = (@convention(c) (_ s: PythonPointer?,_ key: PythonPointer?, _ raw: UnsafeMutableRawPointer?) -> Int32)?
public typealias PySwiftGetter = (@convention(c) (_ s: PySwiftObjectPointer, _ raw: UnsafeMutableRawPointer?) -> PythonPointer?)?
public typealias PySwiftSetter = (@convention(c) (_ s: PySwiftObjectPointer,_ key: PythonPointer?, _ raw: UnsafeMutableRawPointer?) -> Int32)?


public typealias PyCFunc = (@convention(c) (_ s: PythonPointer?, _ args: PythonPointer?) -> PythonPointer?)?

public typealias VectorArgs = UnsafePointer<PythonPointer?>?
public typealias VectorCallArgs = UnsafeMutablePointer<PythonPointer?>
public typealias PyCVectorCallKeywords = (@convention(c) ( _ s: PythonPointer?, _ args: VectorArgs, _ count: Int, _ kwnames: PythonPointer? ) -> PythonPointer? )?
public typealias PyCVectorCall = (@convention(c) ( _ s: PythonPointer?, _ args: VectorArgs, _ count: Int ) -> PythonPointer? )?
public typealias PyCMethodVectorCall = (@convention(c) ( _ s: PythonPointer?, _ type: PythonType, _ args: VectorArgs, _ count: Int, _ kwnames: PythonPointer? ) -> PythonPointer? )?
 
public typealias PySwiftCFunc = (@convention(c) (_ s: PySwiftObjectPointer, _ args: PythonPointer?) -> PythonPointer?)?
public typealias PySwiftCVectorCall = (@convention(c) ( _ s: PySwiftObjectPointer, _ args: VectorArgs, _ count: Int ) -> PythonPointer? )?
public typealias PySwiftCVectorCallKeywords = (@convention(c) ( _ s: PySwiftObjectPointer, _ args: VectorArgs, _ count: Int, _ kwnames: PythonPointer? ) -> PythonPointer? )?
public typealias PySwiftCMethodVectorCall = (@convention(c) ( _ s: PySwiftObjectPointer, _ type: PythonType, _ args: VectorArgs, _ count: Int, _ kwnames: PythonPointer? ) -> PythonPointer? )?

//PySequence Methods

public typealias PySequence_Length_func = (@convention(c) (_ s: PyPointer?) -> Py_ssize_t )?
public typealias PySequence_Concat_func = (@convention(c) (_ lhs: PyPointer?,_ rhs: PyPointer?) -> PyPointer?)?
public typealias PySequence_Repeat_func = (@convention(c) (_ s: PyPointer?,_ count: Py_ssize_t) -> PyPointer?)?
public typealias PySequence_Item_func = (@convention(c) (_ s: PyPointer?,_ idx: Py_ssize_t) -> PyPointer?)?

public typealias PySwiftSequence_Item_func = (@convention(c) (_ s: PySwiftObjectPointer,_ idx: Py_ssize_t) -> PyPointer?)?

public typealias PySequence_Ass_Item_func = (@convention(c) (_ s: PyPointer?,_ idx: Py_ssize_t,_ item: PyPointer?) -> Int32)?
public typealias PySequence_Contains_func = (@convention(c) (_ s: PyPointer?,_ o: PyPointer?) -> Int32)?
public typealias PySequence_Inplace_Concat_func = (@convention(c) (_ lhs: PyPointer?,_ rhs: PyPointer?) -> PyPointer?)?
public typealias PySequence_Inplace_Repeat_func = (@convention(c) (_ s: PyPointer?,_ count: Py_ssize_t) -> PyPointer?)?

public typealias PySwift__setitem__ = (@convention(c) (_ s: PySwiftObjectPointer,_ idx: Py_ssize_t,_ item: PyPointer?) -> Int32)?


public typealias PySwift__len__ = (@convention(c) (_ s: PySwiftObjectPointer) -> Py_ssize_t )?
public typealias PySwift__getitem__ = (@convention(c) (_ s: PySwiftObjectPointer,_ idx: Py_ssize_t) -> PyPointer? )?

public typealias PySwift__mgetitem__ = (@convention(c) (_ s: PySwiftObjectPointer,_ key: PyPointer?) -> PyPointer? )?
public typealias PySwift__msetitem__ = (@convention(c) (_ s: PySwiftObjectPointer,_ key: PyPointer?,_ item: PyPointer?) -> Int32)?

public typealias PyBuf_Get = (@convention(c) (_ s: PyPointer?,_ buf: UnsafeMutablePointer<Py_buffer>?,_ flags: Int32) -> Int32)?
public typealias PyBuf_Release = (@convention(c) (_ s: PyPointer?,_ buf: UnsafeMutablePointer<Py_buffer>?) -> Void )?

public typealias PySwiftBuf_Get = (@convention(c) (_ s: PySwiftObjectPointer,_ buf: UnsafeMutablePointer<Py_buffer>?,_ flags: Int32) -> Int32)?
public typealias PySwiftBuf_Release = (@convention(c) (_ s: PySwiftObjectPointer,_ buf: UnsafeMutablePointer<Py_buffer>?) -> Void )?


public typealias PySwift_HashFunc = (@convention(c) (_ s: PySwiftObjectPointer) -> Int)?

public typealias PySwift_ReprFunc = (@convention(c) (_ s: PySwiftObjectPointer) -> PyPointer?)?



import Foundation
import PythonCore
//import PythonTypeAlias



extension Data {
    
    init(pyUnicode o: PyPointer) throws {
        guard let ptr = PyUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytes: ptr, count: PyUnicode_GetLength(o))
    }
    
    init(pyUnicodeNoCopy o: PyPointer) throws {
        guard let ptr = PyUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytesNoCopy: ptr, count: PyUnicode_GetLength(o), deallocator: .none)
    }
    
    
    
}


extension PythonPointer {
    // PyBytes -> Data
    @inlinable public func bytesAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        guard let mview = PyMemoryView_FromObject(self) else { return nil }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func strAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        guard let mview = PyMemoryView_FromObject(self) else { return nil }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytesSlicedAsData(start: Int, size: Int) -> Data? {
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [start]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        let data = Data(bytes: buf_ptr, count: size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytearrayAsData() -> Data? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    
    
    @inlinable public func bytesAsArray() -> [UInt8]? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // finally create Array<UInt8> from the buf_ptr
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release PyBuffer and MemoryView
        Py_DecRef(mview)
        return array
    }
    
    @inlinable public func bytearrayAsArray() -> [UInt8]? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release MemoryView
        Py_DecRef(mview)
        return array
    }
    
   
    
    
    
    
}

import Foundation
import PySwiftKit
import PythonCore
import PyTypes
import PyComparable


extension URL : PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyUnicode_Check(object) else { throw PythonError.unicode }
        let path = String(cString: PyUnicode_AsUTF8(object))

        if path.hasPrefix("http") {
            guard let url = URL(string: path) else { throw URLError(.badURL) }
            self = url
        } else {
            let url = URL(fileURLWithPath: path)
            self = url
        }
        
    }
    
}


extension Data: PyDeserialize {
    
    public init(object: PyPointer) throws {
        switch object {
        case .PyMemoryView:
            let data_size = PyObject_Size(object)
            // fetch PyBuffer from MemoryView
            let py_buf = PyMemoryView_GetBuffer(object)
            var indices = [0]
            // fetch RawPointer from PyBuffer, if fail return nil
            guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { throw PythonError.memory("Data from memmoryview failed") }
            // cast RawPointer as UInt8 pointer
            let uint8_pointer = buf_ptr.assumingMemoryBound(to: UInt8.self)
            // finally create Data from the UInt8 pointer
            self = Data(UnsafeMutableBufferPointer(start: uint8_pointer, count: data_size))
            // Release PyBuffer and MemoryView
            PyBuffer_Release(py_buf)
        case .PyBytes:
            self = try Self.fromBytes(bytes: object)
        case .PyByteArray:
            self = try Self.fromByteArray(bytes: object)
        default: fatalError()
        }
        
    }
    
    
    @inlinable public static func fromBytes(bytes: PyPointer) throws -> Self {
        let data_size = PyBytes_Size(bytes)
        // PyBytes to MemoryView
        guard let mview = PyMemoryView_FromObject(bytes) else { throw PythonError.type("not bytes") }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { throw PythonError.type("not bytes")}
        // cast RawPointer as UInt8 pointer
        let data = Self(
            bytes: buf_ptr,
            count: data_size
        )
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public static func fromByteArray(bytes: PyPointer) throws -> Self {
        
        let data_size = PyByteArray_Size(bytes)
        // PyBytes to MemoryView
        guard let mview = PyMemoryView_FromObject(bytes) else { throw PythonError.type("not bytes") }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { throw PythonError.type("not bytes")}
        // cast RawPointer as UInt8 pointer
        let data = Self(
            bytes: buf_ptr,
            count: data_size
        )
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
}

//
//  PySerialize+Data.swift
//  PySwiftKit
//
import CPython
import PySwiftKit
import Foundation

extension Data: PySerialize {
    public func pyPointer() -> PyPointer {
        var data = self
        var element_size = MemoryLayout<UInt8>.size
        var size = self.count //* uint8_size
        //let buffer = data.withUnsafeMutableBytes {$0.baseAddress}
        return data.withUnsafeMutableBytes { raw in
            var buffer = Py_buffer()
            
            
            buffer.buf = raw.baseAddress
            
            buffer.len = size
            buffer.readonly = 0
            buffer.itemsize = element_size
            buffer.format = .ubyte_format
            buffer.ndim = 1
            buffer.shape = .init(&size)
            buffer.strides = .init(&element_size)
            
            buffer.suboffsets = nil
            buffer.internal = nil
            
            let mem = PyMemoryView_FromBuffer(&buffer)
            let bytes = PyBytes_FromObject(mem) ?? .None
            Py_DecRef(mem)
            return bytes
        }
    }
}


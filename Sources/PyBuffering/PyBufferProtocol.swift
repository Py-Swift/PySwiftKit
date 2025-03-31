//
//  PyBufferProtocol.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 12/03/2025.
//

import PySwiftCore
import PythonCore

public protocol PyBuffer {
    //func pyBuffer() -> UnsafeMutablePointer<PyBufferProcs>
    
    func pyBufferData() -> UnsafeMutablePointer<UInt8>
    
    var count: Int { get }
    var buffer_size: Int { get }
    var buffer_element_size: Int { get }
}

public extension PyBuffer {
    
    func fillPyBuffer(ptr: UnsafeMutablePointer<Py_buffer>) {
                        //let cls: UIViewPixels = UnPackPyPointer(from: s)
                        //let size = cls.capacity
        
//        
//        ptr.pointee.buf = .init(pyBufferData())
//        
//        ptr.pointee.len = buffer_size
//        ptr.pointee.readonly = 0
//        ptr.pointee.itemsize = element_size
//        //buffer.pointee.format = .ubyte_format
//        ptr.pointee.ndim = 1
//        ptr.pointee.shape = size.stride
//        ptr.pointee.strides = element_size.stride
//        
//        ptr.pointee.suboffsets = nil
//        ptr.pointee.internal = nil
    }
    
    func pyBuffer() -> PyBufferProcs {
        .init(
            bf_getbuffer: { s, buffer, rw in
                guard let buffer = buffer else {
                    PyErr_SetString(PyExc_MemoryError, "UIViewPixels has no buffer")
                    return -1
                }
//                let cls: UIViewPixels = UnPackPyPointer(from: s)
//                let size = cls.capacity
//                buffer.pointee.buf = .init(cls.data)
                
//                buffer.pointee.len = size
//                buffer.pointee.readonly = 0
//                buffer.pointee.itemsize = element_size
//                //buffer.pointee.format = .ubyte_format
//                buffer.pointee.ndim = 1
//                buffer.pointee.shape = size.stride
//                buffer.pointee.strides = element_size.stride
                
//                buffer.pointee.suboffsets = nil
//                buffer.pointee.internal = nil

                return 0
            },
            bf_releasebuffer: nil
        )
    }
}

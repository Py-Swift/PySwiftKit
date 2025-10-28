//
//  PyBuffer.swift
//  PySwiftKit
//
import CPython

fileprivate var _ubyte_format: CChar = 66
extension UnsafeMutablePointer where Pointee == CChar {
    public static var ubyte_format: Self { .init(&_ubyte_format) }
}


extension UnsafeMutableRawBufferPointer {
    public func fill_info(
        view: UnsafeMutablePointer<Py_buffer>,
        o: UnsafeMutablePointer<PyObject>! = nil,
        len: Py_ssize_t,
        readonly: Int32 = 0,
        flags: Int32 = PyBUF_WRITE
    ) -> Int32 {
        PyBuffer_FillInfo(view, o, baseAddress, len, readonly, flags)
    }
    
    public func fill_info(
        buffer: UnsafeMutablePointer<Py_buffer>,
        o: UnsafeMutablePointer<PyObject>! = nil,
        format: UnsafeMutablePointer<CChar> = .ubyte_format,
        size: inout Py_ssize_t,
        itemsize: inout Int,
        readonly: Int32 = 0,
        flags: Int32 = PyBUF_WRITE
    ) -> Int32 {
        //var size = data.count
        buffer.pointee.obj = o
        buffer.pointee.buf = baseAddress
        
        buffer.pointee.len = size
        buffer.pointee.readonly = readonly
        buffer.pointee.itemsize = itemsize
        buffer.pointee.format = .ubyte_format
        buffer.pointee.ndim = 1
        buffer.pointee.shape = .init(&size)
        buffer.pointee.strides = .init(&itemsize)
        return 0
    }
}

extension UnsafeMutablePointer where Pointee == UInt8 {
    public func fill_info(
        buffer: UnsafeMutablePointer<Py_buffer>,
        o: UnsafeMutablePointer<PyObject>! = nil,
        format: UnsafeMutablePointer<CChar> = .ubyte_format,
        size: inout Py_ssize_t,
        itemsize: inout Int,
        readonly: Int32 = 0,
        flags: Int32 = PyBUF_WRITE
    ) -> Int32 {
        //var size = data.count
        //var element_size = 1
        buffer.pointee.obj = o
        buffer.pointee.buf = .init(self)
        
        buffer.pointee.len = size
        buffer.pointee.readonly = readonly
        buffer.pointee.itemsize = itemsize
        buffer.pointee.format = .ubyte_format
        buffer.pointee.ndim = 1
        buffer.pointee.shape = .init(&size)
        buffer.pointee.strides = .init(&itemsize)
        return 0
    }
}

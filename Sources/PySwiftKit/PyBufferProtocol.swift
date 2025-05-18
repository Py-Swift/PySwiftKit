//
//  PyBufferProtocol.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 03/05/2025.
//

import PythonCore


public protocol PyBufferProtocol {
    func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}


public protocol PyTypeProtocol {
    static var PyType: UnsafeMutablePointer<PyTypeObject> { get }
}

public protocol PyTypeObjectProtocol: PyTypeProtocol {
    //static var tp_new: PySwift_newfunc { get }
    static var tp_init: PySwift_initproc { get }
    static var tp_dealloc: PySwift_destructor? { get }
    static var pyTypeObject: PyTypeObject { get  }
    static func asPyPointer(_ target: Self) -> PyPointer
    static func asPyPointer(unretained target: Self) -> PyPointer
}

public protocol PyTypeBufferProtocol {
    static func buffer_procs() -> UnsafeMutablePointer<PyBufferProcs>
}

public protocol PySwiftBuffer: AnyObject {
    static var buffer: PyBufferProcs { get set }
    static var PyBuffer_get: getbufferproc { get }
    static var PyBuffer_release: releasebufferproc? { get }
}

extension PySwiftBuffer {
    public static var PyBuffer_release: releasebufferproc? { nil }
}

extension PyTypeBufferProtocol where Self: PySwiftBuffer {
    public static func buffer_procs() -> UnsafeMutablePointer<PyBufferProcs> { withUnsafeMutablePointer(to: &buffer, {$0}) }
}



public protocol _PyTypeBufferProtocol {
    static func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

public protocol PyClassBuffer: _PyTypeBufferProtocol, AnyObject {
    func __buffer__(src: PyPointer, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

extension PyClassBuffer {
    public static func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32 {
        guard
            s != Py_None,
            let pointee = unsafeBitCast(s, to: PySwiftObjectPointer.self)?.pointee
        else { fatalError() }
        
        return Unmanaged<Self>.fromOpaque(pointee.swift_ptr).takeUnretainedValue().__buffer__(src: s, buffer: buffer)
    }
}

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


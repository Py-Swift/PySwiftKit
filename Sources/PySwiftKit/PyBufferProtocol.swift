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

public protocol PyTypeBufferProtocol {
    static func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

public protocol PyClassBuffer: PyTypeBufferProtocol, AnyObject {
    func __buffer__(src: PyPointer, buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

extension PyClassBuffer {
    public static func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32 {
        guard
            s != PyNone,
            let pointee = unsafeBitCast(s, to: PySwiftObjectPointer.self)?.pointee
        else { fatalError() }
        
        return Unmanaged<Self>.fromOpaque(pointee.swift_ptr).takeUnretainedValue().__buffer__(src: s, buffer: buffer)
    }
}

extension UnsafeMutableRawBufferPointer {
    public func fillPyBuffer(view: UnsafeMutablePointer<Py_buffer>,
                             o: UnsafeMutablePointer<PyObject>! = nil,
                             len: Py_ssize_t,
                             readonly: Int32 = 0,
                             flags: Int32 = PyBUF_WRITE
    ) -> Int32 {
        PyBuffer_FillInfo(view, o, baseAddress, len, readonly, flags)
    }
}



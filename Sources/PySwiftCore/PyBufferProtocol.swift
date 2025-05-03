//
//  PyBufferProtocol.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 03/05/2025.
//

import PythonCore



public protocol PyBufferProtocol {
    static func __buffer__(_ s: PyPointer, _ buffer: UnsafeMutablePointer<Py_buffer>) -> Int32
}

public protocol PyClassBuffer: PyBufferProtocol, AnyObject {
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

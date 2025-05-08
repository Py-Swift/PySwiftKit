//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation
import PySwiftKit
import PythonCore

public extension Data {
	init(memoryviewNoCopy o: PyPointer) throws {
		var indices = [0]
		guard
			let py_buf = PyMemoryView_GetBuffer(o),
			let buf_ptr = PyBuffer_GetPointer(py_buf, &indices)
		else { throw PythonError.unicode }
		let data_size = PyObject_Size(o)
		
		self.init(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
	}
}


@inlinable
func createMemoryView(data: inout [UInt8],_ completion: @escaping (PythonPointer)->Void )  {
	let size = data.count //* uint8_size
	data.withUnsafeMutableBytes { buffer in
		var pybuf = Py_buffer()
		PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
		pybuf.format = nil
		guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
		completion(view)
		//PyBuffer_Release(&pybuf)
		Py_DecRef(view)
	}
}

@inlinable
func createMemoryView(data: inout Data,_ completion: @escaping (PythonPointer)->Void )  {
	let size = data.count //* uint8_size
	data.withUnsafeMutableBytes { buffer in
		var pybuf = Py_buffer()
		PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
		pybuf.format = nil
		guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
		completion(view)
		//PyBuffer_Release(&pybuf)
		Py_DecRef(view)
	}
}



////AVFoundation Pixels to MemoryView
//@inlinable
//func createMemoryView(pixels: CVPixelBuffer,_ completion: @escaping (PythonPointer)->Void )  {
//	CVPixelBufferLockBaseAddress(pixels, [])
//	let buffer = CVPixelBufferGetBaseAddress(pixels)
//	let size = CVPixelBufferGetDataSize(pixels)
//	var pybuf = Py_buffer()
//	PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
//	pybuf.format = nil
//	
//	guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
//	completion(view)
//	CVPixelBufferUnlockBaseAddress(pixels, [])
//	//PyBuffer_Release(&pybuf)
//	Py_DecRef(view)
//}
//
//extension CVPixelBuffer {
//	
//	//AVFoundation Pixels to MemoryView
//	@inlinable
//	public func withMemoryView(_ completion: @escaping (PythonPointer)->Void )  {
//		CVPixelBufferLockBaseAddress(self, [])
//		let buffer = CVPixelBufferGetBaseAddress(self)
//		let size = CVPixelBufferGetDataSize(self)
//		var pybuf = Py_buffer()
//		PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
//		guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
//		CVPixelBufferUnlockBaseAddress(self, [])
//		completion(view)
//		
//		//PyBuffer_Release(&pybuf)
//		Py_DecRef(view)
//	}
//	
//	@inlinable
//	public func withTextureData(_ completion: @escaping (_ data: PythonPointer?,_ w: PythonPointer?,_ h: PythonPointer?,_ size: PythonPointer?)->Void )  {
//		CVPixelBufferLockBaseAddress(self, [])
//		let buffer = CVPixelBufferGetBaseAddress(self)
//		let w = PyLong_FromLong(CVPixelBufferGetBytesPerRow(self) / 4)
//		let h = PyLong_FromLong(CVPixelBufferGetHeight(self))
//		let size = CVPixelBufferGetDataSize(self)
//		let _size = PyLong_FromLong(size)
//		var pybuf = Py_buffer()
//		PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
//		guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
//		CVPixelBufferUnlockBaseAddress(self, [])
//		completion(view, w, h, _size)
//		Py_DecRef(w)
//		Py_DecRef(h)
//		Py_DecRef(_size)
//		//PyBuffer_Release(&pybuf)
//		Py_DecRef(view)
//	}
//}

public extension Data {
	@inlinable
	mutating func withMemoryView(_ completion: @escaping (PythonPointer)->Void ) -> Void  {
		let size = self.count //* uint8_size
		self.withUnsafeMutableBytes { buffer in
			var pybuf = Py_buffer()
			PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
			pybuf.format = nil
			guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
			completion(view)
			//PyBuffer_Release(&pybuf)
			Py_DecRef(view)
		}
	}
	
	@inlinable
	mutating func memoryView() -> PythonPointer {
		let size = self.count //* uint8_size
		let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
		var pybuf = Py_buffer()
		PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
		return PyMemoryView_FromBuffer(&pybuf)
	}
	
	@inlinable
	mutating func pythonBytes() -> PythonPointer {
		let size = self.count //* uint8_size
		let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
		var pybuf = Py_buffer()
		PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
		let mem = PyMemoryView_FromBuffer(&pybuf)
		let bytes = PyBytes_FromObject(mem) ?? .None
		Py_DecRef(mem)
		return bytes
	}
}

extension Array where Element == UInt8 {
	@inlinable
	mutating func withMemoryView(_ completion: @escaping (PythonPointer)->Void ) -> Void {
		let size = self.count //* uint8_size
		self.withUnsafeMutableBytes { buffer in
			var pybuf = Py_buffer()
			PyBuffer_FillInfo(&pybuf, nil, buffer.baseAddress, size , 0, PyBUF_WRITE)
			pybuf.format = nil
			guard let view = PyMemoryView_FromBuffer(&pybuf) else { return }
			completion(view)
			//PyBuffer_Release(&pybuf)
			Py_DecRef(view)
		}
	}
	
	@inlinable
	mutating func memoryView() -> PythonPointer  {
		let size = self.count //* uint8_size
		let buffer = self.withUnsafeMutableBytes {$0.baseAddress}
		var pybuf = Py_buffer()
		PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
		return PyMemoryView_FromBuffer(&pybuf)
	}
}

@inlinable public func memoryviewAsDataNoCopy(view: PythonPointer) -> Data? {
	let data_size = PyObject_Size(view)
	// fetch PyBuffer from MemoryView
	let py_buf = PyMemoryView_GetBuffer(view)
	var indices = [0]
	// fetch RawPointer from PyBuffer, if fail return nil
	guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
	return Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
}


@inlinable public func memoryviewSlicedAsDataNoCopy(view: PythonPointer, start: Int, size: Int) -> Data? {
	// fetch PyBuffer from MemoryView
	let py_buf = PyMemoryView_GetBuffer(view)
	var indices = [start]
	// fetch RawPointer from PyBuffer, if fail return nil
	guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
	let data = Data(bytesNoCopy: buf_ptr, count: size, deallocator: .none)
	// Release PyBuffer and MemoryView
	return data
}


extension PyPointer {
	@inlinable public func memoryViewAsData() -> Data? {
		let data_size = PyObject_Size(self)
		// fetch PyBuffer from MemoryView
		let py_buf = PyMemoryView_GetBuffer(self)
		var indices = [0]
		// fetch RawPointer from PyBuffer, if fail return nil
		guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
		// cast RawPointer as UInt8 pointer
		let uint8_pointer = buf_ptr.assumingMemoryBound(to: UInt8.self)
		// finally create Data from the UInt8 pointer
		let data = Data(UnsafeMutableBufferPointer(start: uint8_pointer, count: data_size))
		// Release PyBuffer and MemoryView
		PyBuffer_Release(py_buf)
		return data
	}
	
	@inlinable public func memoryViewSlicedAsData(start: Int, size: Int) -> Data? {
		// fetch PyBuffer from MemoryView
		let py_buf = PyMemoryView_GetBuffer(self)
		var indices = [start]
		// fetch RawPointer from PyBuffer, if fail return nil
		guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
		return Data(bytes: buf_ptr, count: size)
	}
	
	@inlinable public func memoryViewAsArray() -> [UInt8]? {
		let data_size = PyObject_Size(self)
		// fetch PyBuffer from MemoryView
		let py_buf = PyMemoryView_GetBuffer(self)
		var indices = [0]
		// fetch RawPointer from PyBuffer, if fail return nil
		guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
		// finally create Array<UInt8> from the buf_ptr
		let array = [UInt8](UnsafeBufferPointer(
			start: buf_ptr.assumingMemoryBound(to: UInt8.self),
			count: data_size)
		)
		return array
	}
}

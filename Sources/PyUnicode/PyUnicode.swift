//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation
import PySwiftKit
import PythonCore

extension PyPointer {
	@inlinable public var unicodeString: String? {
		
		guard
			PyUnicode_Check(self),
			let ptr = PyUnicode_DATA(self),
			let kind = PyUnicode_AsKind(rawValue: PyUnicode_GetKind(self))
		else { return nil }
		
		
		let length = PyUnicode_GetLength(self)
		switch kind {
		//switch kind {
//		case .PyUnicode_WCHAR_KIND:
//			return nil
		case .PyUnicode_1BYTE_KIND:
			let size = length * MemoryLayout<Py_UCS1>.stride
			let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
			return String(data: data, encoding: .utf8)
		case .PyUnicode_2BYTE_KIND:
			let size = length * MemoryLayout<Py_UCS2>.stride
			let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
			return String(data: data, encoding: .utf16LittleEndian)
		case .PyUnicode_4BYTE_KIND:
			let size = length * MemoryLayout<Py_UCS4>.stride
			let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
			return String(data: data, encoding: .utf32LittleEndian)
		}
	}
	
	
	
	@inlinable public var unicodeData: Data? {
		guard let ptr = PyUnicode_DATA(self) else { return nil }
		return Data(bytes: ptr, count: PyUnicode_GetLength(self))
	}
	
	@inlinable public var unicodeDataNoCopy: Data? {
		guard let ptr = PyUnicode_DATA(self) else { return nil }
		return Data(bytesNoCopy: ptr, count: PyUnicode_GetLength(self), deallocator: .none)
	}
}



extension String {
	
	@inlinable public var pyStringUTF8: PythonPointer? {
		guard let data = self.data(using: .utf8) else { return nil }
		return data.withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(1, buf.baseAddress, data.count)
		}
	}
	@inlinable public var pyStringUTF16: PythonPointer? {
		guard let data = self.data(using: .utf16LittleEndian) else { return nil }
		return data.withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(2, buf.baseAddress, data.count)
		}
	}
	@inlinable public var pyStringUTF32: PythonPointer? {
		guard let data = self.data(using: .utf32LittleEndian) else { return nil }
		return data.withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(4, buf.baseAddress, data.count)
		}
	}
}

extension Data {
	@inlinable public var pyStringUTF8: PythonPointer {
		return withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(1, buf.baseAddress, count)
		}
	}
	@inlinable public var pyStringUTF16: PythonPointer {
		return withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(2, buf.baseAddress, count)
		}
	}
	@inlinable public var pyStringUTF32: PythonPointer {
		return withUnsafeBytes { buf in
			PyUnicode_FromKindAndData(4, buf.baseAddress, count)
		}
	}
}

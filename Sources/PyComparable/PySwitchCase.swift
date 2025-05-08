//
//  File.swift
//  
//
//  Created by CodeBuilder on 16/11/2023.
//

import Foundation
import PySwiftKit
import PythonCore
import PyTypes

public protocol PyTypeProtocol {
	static func ~=(l: Self, r: PyPointer) -> Bool
}


extension PyPointer {
	
	public static func ~=(l: UnsafeMutablePointer<PyTypeObject>, r: PyPointer) -> Bool  {
		return PyObject_TypeCheck(r, l) == 1
	}
	
}


extension String: PyTypeProtocol {
	public static func ~= (l: String, r: PyPointer) -> Bool {
		l.withCString { str in
			PyUnicode_CompareWithASCIIString(r, str) == 1
		}
	}
}


public extension Optional where Wrapped == UnsafeMutablePointer<PyTypeObject> {
	static func newType(_ t: PyTypeObject) -> Self {
		let new: Self = .allocate(capacity: 1)
		new?.pointee = t
		return new
	}
}



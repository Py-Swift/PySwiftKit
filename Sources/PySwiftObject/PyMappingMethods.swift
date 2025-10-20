//
//import Foundation
//import CPythonSwiftCore
//import PySwiftObject
//import CPython
//
//public struct PyMappingWrap {
//	
//}
//
//public class PyMappingMethodsWrap {
//	public let methods: UnsafeMutablePointer<PyMappingMethods>
//	public init(__len__: PySwift__len__, __getitem__: PySwift__mgetitem__, __setitem__: PySwift__msetitem__) {
//		let _methods = PyMappingMethods(
//			mp_length: unsafeBitCast(__len__, to: lenfunc.self),
//			mp_subscript: unsafeBitCast(__getitem__, to: binaryfunc.self),
//			mp_ass_subscript: unsafeBitCast(__setitem__, to: objobjargproc.self)
//		)
//		methods = .allocate(capacity: 1)
//		methods.pointee = _methods
//		
//	}
//	deinit {
//		methods.deallocate()
//	}
//}

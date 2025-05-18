import Foundation
@_exported import _PySwiftObject
import PySwiftKit
import PythonCore
//import PythonSwiftCore
//import PythonTypeAlias


//@inlinable func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
//	let _count = str.utf8.count + 1
//	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
//	str.withCString { (baseAddress) in
//		// func initialize(from: UnsafePointer<Pointee>, count: Int)
//		result.initialize(from: baseAddress, count: _count)
//	}
//	//count = _count
//	return result
//}
//
//@inlinable func makeCString(from str: String) -> UnsafePointer<Int8> {
//	let _count = str.utf8.count + 1
//	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
//	str.withCString { (baseAddress) in
//		// func initialize(from: UnsafePointer<Pointee>, count: Int)
//		result.initialize(from: baseAddress, count: _count)
//	}
//	//count = _count
//	return .init(result)
//}





func allocPySwiftObject(type: UnsafeMutablePointer<PyTypeObject>?) -> PyPointer? {
	type?.pointee.tp_alloc?(type, 0)
}


func unpackStruct<T>(_ object: PyPointer) throws -> T {
	let ps_object = unsafeBitCast(object, to: PySwiftObject.self)
	guard let raw = ps_object.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
	return raw.withMemoryRebound(to: T.self, capacity: 1) { pointer in
		pointer.pointee
	}
}

//func updateStruct<T, V>(_ object: PyPointer, key: KeyPath<T, V>, _: T.Type) throws {
//	let ps_object = unsafeBitCast(object, to: PySwiftObject.self)
//	guard let raw = ps_object.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
//    raw.withMemoryRebound(to: T.self, capacity: 1) { pointer in
//        pointer.pointee[keyPath: key]
//	}
//}

func getPropertyStruct<T,R>(_ object: PySwiftObjectPointer, key: KeyPath<T, R>) throws -> R {
	guard let raw = object?.pointee.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
	return raw.withMemoryRebound(to: T.self, capacity: 1) { pointer in
		pointer.pointer(to: key)!.pointee
	}
}

func setPropertyStruct<T,Value>(_ object: PySwiftObjectPointer, keyPath: WritableKeyPath<T, Value>, value: Value) throws {
	//item[keyPath: keyPath] = value
    guard let raw = object?.pointee.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
    return raw.withMemoryRebound(to: T.self, capacity: 1) { pointer in
        pointer.pointer(to: keyPath)!.pointee = value
    }
}

func howSwiftonizeMustDo(item: PySwiftObjectPointer) throws {
	guard let raw = item?.pointee.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
	return raw.withMemoryRebound(to: TestStruct.self, capacity: 1) { pointer in
		pointer.pointee.a = "hello"
	}
}

func setPropertyClass<Struct, Value>(for item: PySwiftObjectPointer, keyPath: WritableKeyPath<Struct, Value>, value: Value) throws {
	guard let raw = item?.pointee.swift_ptr else { throw PythonError.type("Swift Pointer not set") }
	return raw.withMemoryRebound(to: Struct.self, capacity: 1) { pointer in
		pointer.pointer(to: keyPath)!.pointee = value
	}
}

fileprivate struct TestStruct {
	var a: String
}


fileprivate func playground() throws {
	
	let py_swift_object: PySwiftObjectPointer = nil
	
	let _ = try getPropertyStruct(py_swift_object, key: \TestStruct.a )
													// wtf 	 ^^^^^^^^^^^^^
    try setPropertyStruct(py_swift_object, keyPath: \TestStruct.a, value: "hello")
	try setPropertyClass(for: py_swift_object, keyPath: \TestStruct.a, value: "hello")
	
	
//	let getter: PySwift_getter = {s, _ in
//		if let a = try? getPropertyStruct(s, key: \TestStruct.a) {
//			return a.pyPointer
//		}
//		return .None
//	}
}

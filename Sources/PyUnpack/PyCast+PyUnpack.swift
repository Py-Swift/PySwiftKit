import Foundation
import PySwiftCore
//import PyEncode
import PyDeserializing
import PythonCore
//import PythonTypeAlias
//import _PySwiftObject

@inlinable
public func optionalPyCast<R: PyDeserialize>(from o: PyPointer?) -> R? {
    guard let object = o, object != PyNone else { return nil }
    return try? R(object: object)
}

@inlinable
public func pyCast<T: PyDeserialize>(from o: PyPointer?) throws -> T {
	guard let object = o, object != PyNone else { throw PythonError.type(.init(describing: T.self)) }
	return try T(object: object)
}

@inlinable
public func pyCast<T: PyDeserialize>(from args: UnsafePointer<PyPointer?>, index: Int) throws -> T {
    guard let object = args[index], object != PyNone else { throw PythonError.type(.init(describing: T.self)) }
    return try T(object: object)
}

// consuming

@inlinable
public func optionalPyCast<R: PyDeserialize>(consuming o: PyPointer?) -> R? {
	guard let object = o, object != PyNone else { return nil }
	defer { object.decref() }
	return try? R(object: object)
}

@inlinable
public func pyCast<R: PyDeserialize>(consuming o: PyPointer?) throws -> R {
	guard let object = o, object != PyNone else { throw PythonError.type(.init(describing: R.self)) }
	defer { object.decref() }
	return try R(object: object)
}

//

@inlinable
public func UnPackPyPointer<T: AnyObject>(from o: PyPointer?) -> T {
    guard
        let object = o, object != PyNone,
        let pointee = unsafeBitCast(o, to: PySwiftObjectPointer.self)?.pointee
    else { fatalError() }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(from o: PyPointer?) -> T? {
    guard
        let object = o, object != PyNone,
        let pointee = unsafeBitCast(o, to: PySwiftObjectPointer.self)?.pointee
    else { return nil }
	//PyNone
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}


@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer, as: T.Type) -> T? {
    guard
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { return nil }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?, as: T.Type) throws -> T? {
    guard let self = self, self.notNone else { return nil }
    guard
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(describing: T.self)) }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackOptionalPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T? {
    guard
        let self = self,
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { fatalError() }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}


@inlinable
public func UnPackPySwiftObject<T: AnyObject>(with self: PySwiftObjectPointer, as: T.Type) -> T {
    guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPySwiftObject<T: AnyObject>(with self: PySwiftObjectPointer) -> T  {
    guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}



@inlinable
public func getPySwiftObject<T: AnyObject, R>(with self: PySwiftObjectPointer,key: KeyPath<T,R>, as: T.Type) -> R {
	guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
	return Unmanaged<T>.fromOpaque(pointee.swift_ptr).takeUnretainedValue()[keyPath: key]
}

@inlinable
public func getPySwiftObject<T: AnyObject, R>(with self: PySwiftObjectPointer,key: KeyPath<T,R>) -> R {
	guard let pointee = self?.pointee else { fatalError("self is not a PySwiftObject") }
	return Unmanaged<T>.fromOpaque(pointee.swift_ptr).takeUnretainedValue()[keyPath: key]
}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer, as: T.Type) -> T {
//    guard
//        PyObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { fatalError("self is not a PySwiftObject") }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer, as: T.Type) throws -> T {
    guard
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.notPySwiftObject }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?, as: T.Type) throws -> T {
    guard
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.notPySwiftObject }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}


@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T {
    guard
        let self = self,
        PyObject_TypeCheck(self, check),
        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(cString: _PyType_Name(check))) }
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
    guard let self = self, self.notNone else { return nil }
    
    guard PyObject_TypeCheck(self, check), let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
    else { throw PythonError.type(.init(cString: _PyType_Name(check))) }
    
    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) throws -> T? {
//    guard
//        let self = self,
//        PyObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { throw PythonError.attribute }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}

//@inlinable
//public func UnPackPyPointer<T: AnyObject>(with check: PythonType, from self: PyPointer?) -> T {
//    guard
//        let self = self,
//        PyObject_TypeCheck(self, check),
//        let pointee = unsafeBitCast(self, to: PySwiftObjectPointer.self)?.pointee
//    else { fatalError("self is not a PySwiftObject") }
//    return Unmanaged.fromOpaque(pointee.swift_ptr).takeUnretainedValue()
//}
//import AVFoundation
//fileprivate func playground() {
//	let py_swift = PySwiftObjectPointer.init(nilLiteral: ())!
//	
//	let string = getPySwiftObject(with: py_swift, key: \AVCaptureDevice.uniqueID )
//}

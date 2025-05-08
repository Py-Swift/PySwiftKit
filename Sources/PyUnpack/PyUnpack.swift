

import Foundation
import PySwiftKit
import PyCollection
//import PyDeserializing
import PythonCore

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T] {
	guard
		let self = self
	else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T] {
	guard
		let self = self
	else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T]? {
	guard let self = self else { throw PythonError.notPySwiftObject }
	if self.isNone { return nil }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T]? {
	guard let self = self else { throw PythonError.notPySwiftObject }
	if self.isNone { return nil }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T?] {
	guard
		let self = self
	else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T?] {
	guard
		let self = self
	else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?) throws -> [T?]? {
	guard let self = self else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

@inlinable
public func UnPackPyPointer<T: AnyObject>(with type: PythonType, from self: PyPointer?, as: T.Type) throws -> [T?]? {
	guard let self = self else { throw PythonError.notPySwiftObject }
	return try self.map { try UnPackPyPointer(with: type, from: $0) }
}

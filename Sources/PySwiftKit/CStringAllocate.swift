//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation

@inlinable public func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
	let _count = str.utf8.count + 1
	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
	str.withCString { (baseAddress) in
		// func initialize(from: UnsafePointer<Pointee>, count: Int)
		result.initialize(from: baseAddress, count: _count)
	}
	//count = _count
	return result
}

@inlinable public func makeCString(from str: String) -> UnsafePointer<Int8> {
	let _count = str.utf8.count + 1
	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
	str.withCString { (baseAddress) in
		// func initialize(from: UnsafePointer<Pointee>, count: Int)
		result.initialize(from: baseAddress, count: _count)
	}
	//count = _count
	return .init(result)
}

class CStringAllocate {
	static let `default` = CStringAllocate()
	
	var const_strings: [String: UnsafePointer<CChar>] = [:]
	var mutable_strings: [String: UnsafeMutablePointer<CChar>] = [:]
	init() {}
	
	func create(_ string: String) -> UnsafePointer<CChar> {
		if let result = const_strings[string] { return result }
		let v: UnsafePointer<CChar> = makeCString(from: string)
		const_strings[string] = v
		return v
	}
	
	func create(_ string: String) -> UnsafeMutablePointer<CChar> {
		if let result = mutable_strings[string] { return result }
		let v: UnsafeMutablePointer<CChar> = makeCString(from: string)
		mutable_strings[string] = v
		return v
	}
	
	deinit {
		for (_,v) in const_strings {
			v.deallocate()
		}
		for (_,v) in mutable_strings {
			v.deallocate()
		}
	}
}

public func cString(_ string: String) -> UnsafePointer<CChar> {
	CStringAllocate.default.create(string)
}
public func cString(_ string: String) -> UnsafeMutablePointer<CChar> {
	CStringAllocate.default.create(string)
}

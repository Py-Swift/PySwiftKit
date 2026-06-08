//
//  PySequenceProtocol.swift
//  PySwiftKit
//

public protocol PySequenceProtocol {
	func __len__() -> Int
	func __add__(_ other: PyPointer?) -> PyPointer?
	func __iadd__(_ item: PyPointer?) -> PyPointer?
	func __mul__(_ n: Int) -> PyPointer?
	func __imul__(_ n: Int) -> PyPointer?
    func __getitem__(_ i: Int) -> PyPointer?
	func __setitem__(_ i: Int, _ item: PyPointer?) -> Int32
	func __contains__(_ item: PyPointer?) -> Int32
//	func __repeat__(count: Int, value: PyPointer?) -> PyPointer?
//	func __irepeat__(count: Int, value: PyPointer?)
}

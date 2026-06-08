//
//  PyMappingProtocol.swift
//  PySwiftKit
//
import CPython


public protocol PyMappingProtocol {
	func __len__() -> Int
	func __getitem__(key: String) -> PyPointer?
}

//
//  PySwiftObjectTests.swift
//  PySwiftKit
//
import XCTest
import CPython
import PySwiftKit
@testable import PySerializing




final class PySwiftObjectTests: XCTestCase {
    
    
    func test_PySwiftObject_Cast() throws {
        let o = PySwiftObject()
        print(o)
    }
}

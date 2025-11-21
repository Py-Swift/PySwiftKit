//
//  TestHelpers.swift
//  PySwiftKit
//
import XCTest
import CPython
@testable import PySwiftKit
@testable import PySerializing



extension Optional<PyPointer> {
    func testDecRef() throws {
        XCTAssertNotNil(self)
        Py_DECREF(self)
    }
}

func PyErr_XCTAssert() {
    let err = PyErr_Occurred()
    if let err {
        err.decRef()
        PyErr_Print()
    }
    XCTAssertNil(err)
}

extension PyPointer {
    
    var refCount: Int {
        Py_REFCNT(self)
    }
    
    func printRefCount(_ label: String? = nil) {
        print("\(label ?? "\(self)"): \(refCount)")
    }
}

func test_Array<T: PySerialize & FixedWidthInteger>(_ t: T.Type) throws {
    let int_array: [T] = .init((0..<1024).map({T($0 % T.max)}))
    for _ in 0..<1000 {
        
        let int_list = int_array.pyPointer()
        
        PyErr_XCTAssert()
        
        int_list.decRef()
        
        PyErr_XCTAssert()
    }
}

func test_Array<T: PySerialize & BinaryFloatingPoint>(_ t: T.Type) throws {
    let int_array: [T] = .init((0..<256).map({T($0)}))
    for _ in 0..<1000 {
        
        let int_list = int_array.pyPointer()
        
        PyErr_XCTAssert()
        
        int_list.decRef()
        
        PyErr_XCTAssert()
    }
}

func test_Array<T: PySerialize & StringProtocol>(_ t: T.Type) throws {
    let test_array: [T] = .init((0..<256).map({T(stringLiteral: $0.description)}))
    for _ in 0..<1000 {
        
        let py_list = test_array.pyPointer()
        
        PyErr_XCTAssert()
        
        py_list.decRef()
        
        PyErr_XCTAssert()
    }
}

func test_Set<T: PySerialize & FixedWidthInteger>(_ t: T.Type) throws {
    let test_set: Set<T> = .init((0..<1024).map({T($0 % T.max)}))
    for _ in 0..<1000 {
        
        let pyset = test_set.pyPointer()
        
        PyErr_XCTAssert()
        
        pyset.decRef()
        
        PyErr_XCTAssert()
    }
}

func test_Set<T: PySerialize & BinaryFloatingPoint>(_ t: T.Type) throws {
    let test_set: Set<T> = .init((0..<1024).map({T($0)}))
    for _ in 0..<1000 {
        
        let pyset = test_set.pyPointer()
        
        PyErr_XCTAssert()
        
        pyset.decRef()
        
        PyErr_XCTAssert()
    }
}

func test_Set<T: PySerialize & StringProtocol>(_ t: T.Type) throws {
    let test_set: Set<T> = .init((0..<1024).map({T(stringLiteral: $0.description)}))
    for _ in 0..<1000 {
        
        let pyset = test_set.pyPointer()
        
        PyErr_XCTAssert()
        
        pyset.decRef()
        
        PyErr_XCTAssert()
    }
}
@MainActor
func initPy() throws {
    initPython()
    XCTAssert(PyGIL_Released())
}

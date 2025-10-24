//
//  PySerializingTests.swift
//  PySwiftKit
//

import XCTest
import CPython
import PyDateTime
@testable import PySwiftKit
@testable import PySerializing

//@testable import PyTestEnvironment



final class PyRefCountTests: XCTestCase {
    
    func test_list_append() throws {
        try initPy()
        withGIL {
            let pyint = (1234537964378 as Int).pyPointer()
            let pyint_refcnt = pyint.refCount
            pyint.printRefCount("pyint ref count before list.append")
            let pylist = PyList_New(1)
            PyList_Append(pylist, pyint)
            pyint.printRefCount("pyint ref count after list.append")
            XCTAssertEqual(pyint_refcnt + 1, pyint.refCount)
            pylist?.decRef()
            pyint.printRefCount("pyint ref count before list.decref()")
            XCTAssertEqual(pyint_refcnt, pyint.refCount)
            
        }
    }
}

final class PySerializingTests: XCTestCase {
    
    
    
    func test_Integers_Signed() throws {
        try initPy()
        withGIL {
            (1 as Int).pyPointer().decRef()
            (1 as Int64).pyPointer().decRef()
            (1 as Int32).pyPointer().decRef()
            (1 as Int16).pyPointer().decRef()
            (1 as Int8).pyPointer().decRef()
            
            PyErr_XCTAssert()
        }
    }
    
    func test_Integers_Unsigned() throws {
        try initPy()
        withGIL {
            (1 as UInt).pyPointer().decRef()
            (1 as UInt64).pyPointer().decRef()
            (1 as UInt32).pyPointer().decRef()
            (1 as UInt16).pyPointer().decRef()
            (1 as UInt8).pyPointer().decRef()
            
            PyErr_XCTAssert()
        }
    }
    
    func test_Strings() throws {
        try initPy()
        withGIL {
            "PySwiftKit".pyPointer().decRef()
            
            "Python \(3.13)".pyPointer().decRef()
            
            PyErr_XCTAssert()
        }
    }
    
    func test_Range() throws {
        try initPy()
        withGIL {
            //_PyDateTime_IMPORT()
            let pyrange = (0..<10).pyPointer()
            pyPrint(pyrange)
            pyrange.decRef()
            PyErr_XCTAssert()
            
            let pyrange2 = (0...10).pyPointer()
            pyPrint(pyrange2)
            pyrange2.decRef()
            PyErr_XCTAssert()
        }
    }
    
    
    func test_Arrays() throws {
        try initPy()
        try withGIL {
            
            let intro_array: [String] = (0..<100).map(String.init)
            let intro_list = intro_array.pyPointer()
            pyPrint(intro_list)
            intro_list.decRef()
            PyErr_XCTAssert()
            
            try test_Array(Int.self)
            try test_Array(Int64.self)
            try test_Array(Int32.self)
            try test_Array(Int16.self)
            try test_Array(Int8.self)
            
            try test_Array(UInt.self)
            try test_Array(UInt64.self)
            try test_Array(UInt32.self)
            try test_Array(UInt16.self)
            try test_Array(UInt8.self)
            
            try test_Array(Double.self)
            try test_Array(Float.self)
            //try test_Array(Float80.self)
            
            try test_Array(String.self)
            
        }
    }
    
    func test_Sets() throws {
        try initPy()
        try withGIL {
            let pyset = Set((0..<128).map(String.init)).pyPointer()
            pyPrint(pyset)
            pyset.decRef()
            PyErr_XCTAssert()
            
            try test_Set(Int.self)
            try test_Set(Int64.self)
            try test_Set(Int32.self)
            try test_Set(Int16.self)
            try test_Set(Int8.self)
            
            try test_Set(UInt.self)
            try test_Set(UInt64.self)
            try test_Set(UInt32.self)
            try test_Set(UInt16.self)
            try test_Set(UInt8.self)
            
            try test_Set(Double.self)
            try test_Set(Float.self)
            //try test_Set(Float80.self)
            
            try test_Set(String.self)
        }
    }
    
    
}

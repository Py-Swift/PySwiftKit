//
//  PySwiftWrapperTests.swift
//  PySwiftKit
//
import XCTest
import CPython
@testable import PySwiftKit
@testable import PySerializing

@testable import PySwiftWrapper


@MainActor
final class PySwiftWrapperTests: XCTestCase {
    
    func test_number_functions() throws {
        
        guard let prog = Bundle.module.path(forResource: "pyswiftwrapper_tests", ofType: "py") else {
            print("pyswiftwrapper_tests.py not found")
            throw CocoaError.error(.fileNoSuchFile)
        }
        
        var fd: UnsafeMutablePointer<FILE>?
        
        
        DispatchQueue.global().sync {
            fd = fopen(prog, "r")
        }
        
        try initPy()
        withGIL {
            var ret: Int32
            
            if let fd {
                
#if DEBUG
                print("Running main.py: \(prog)")
#endif
                
                ret = PyRun_SimpleFileEx(fd, prog, 1)
                //NSLog("App ended")
                
                fclose(fd)
                XCTAssertEqual(ret, 0)
                PyErr_XCTAssert()
                
            } else {
                ret = 1
                //NSLog("Unable to open main.py, abort.")
            }
        }
        
    }
}

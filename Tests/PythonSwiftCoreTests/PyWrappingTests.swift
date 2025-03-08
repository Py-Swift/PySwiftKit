import XCTest
@testable import PySwiftCore
@testable import PythonCore
@testable import PyExecute
@testable import PyDictionary
@testable import PyUnwrap
@testable import PyTypes
@testable import PySwiftObject

class TestClassA: PyUnwrapable {

}

class TestClassB: PyUnwrapable, PyTypeProtocol {
    
}

fileprivate struct TestStruct {
    
}

class StaticClassTest {
    static let shared = StaticClassTest()
    
    init() {
        
    }
    
    static func testA() {
        print(Self.self, "testA")
    }
    
    static func testB(count: Int, n: Int) {
        print(Self.self, "testB", n, count)
    }
}

fileprivate struct TestStructB: PyUnwrapable & PyTypeProtocol {
    static var PyType: UnsafeMutablePointer<PyTypeObject> {
        .PyLong
    }
    var pyPointer: PyPointer {
        fatalError()
    }
}

fileprivate func testWrapObject<O: AnyObject>(cls: O) -> PyPointer.Pointee {
    var new = PySwiftObject()
    new.swift_ptr = Unmanaged<O>.passRetained(cls).toOpaque()
    return unsafeBitCast(new, to: PyPointer.Pointee.self)
}

extension PyPointer {
    @inlinable
    public func pyMap<T>() throws -> [T] where T: PyUnwrapable {
        try self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let o = pointer.pointee
            print("pyMap ob_size", o.ob_base.ob_size)
            return try PySequenceBuffer(start: o.ob_item, count: o.ob_base.ob_size).map { element in
                guard let element = element else { throw PythonError.sequence }
                return try T.unpack(with: element)
            }
        }
    }
}

final class PyWrappingTests: XCTestCase {
    
    func test_PyUnwrable_extractA() throws {
        initPython()
        assert(!PyHasGIL())
        try withAutoGIL {
            let ps_objectA = TestClassA.asPyPointer(.init())
            let ps_objectB = TestClassB.asPyPointer(.init())
            
            let a: TestClassA = try .unpack(with: ps_objectA)
            let b: TestClassB = try .unpack(with: ps_objectB)
            
            print(a)
            print(b)
            let refcntA = Py_REFCNT(ps_objectA)
            let refcntB = Py_REFCNT(ps_objectB)
            let list = PyList_New(0)!
            
            //PyList_Insert(list, 0, ps_objectA)
            //PyList_Insert(list, 1, ps_objectA)
            PyList_Append(list, ps_objectA)
            PyList_Append(list, ps_objectA)
            PyList_Append(list, ps_objectA)
            //PyList_Append(list, ps_objectA)
            
            let Bs: [TestClassA] = try .unpack(with: list)
            print(Bs)
            let As: [TestClassA] = try list.pyMap()
            //let Bs: [TestClassA] = try list.pyMap()
            print(As)
            list.decref()
            
            XCTAssert(refcntA == Py_REFCNT(ps_objectA))
            XCTAssert(refcntB == Py_REFCNT(ps_objectB))
            ps_objectA.decref()
            ps_objectB.decref()
            // c = try .unpack(with: object)
            // d = try .unpack(with: object)
        }
        // let _ = (a,b,c,d)
    }
    
    func test_class_staticmethod() throws {
        initPython()
        assert(!PyHasGIL())
        try withAutoGIL {
            let m = PyModule_New("static_test")!
            PyModule_AddType(m, StaticClassTest.PyType)
            
            let globals = PyModule_GetDict(m)!
            let locals = PyDict_New()!
            try PyDict_GetItem(globals, "StaticClassTest").decref()
            
            
            let code = """
            for i in range(10):
                StaticClassTest.testA()
                StaticClassTest.testB(10, i)
            """
            PyRun_String(string: code, flag: .file, globals: globals, locals: locals)?.decref()
            globals.decref()
            locals.decref()
            m.decref()
        }
        
    }
    
}

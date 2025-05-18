import XCTest
@testable import PySwiftKit
@testable import PyExecute
@testable import PyDictionary
@testable import PyUnwrap
@testable import PyTypes
@testable import PySwiftObject
@testable import PyCallable



fileprivate struct TestStruct {
    
}

public class StaticClassTest: StaticClassTest_PyProtocol {
    static let shared = StaticClassTest()
    public var py_callback: PyCallback?
    var py_callbacks: [PyCallback] = []
    init() {
        
    }
    
    public static func testA() {
        print(Self.self, "testA")
        for cb in shared.py_callbacks {
            cb.a = 2
            cb.b = "abc"
        }
        
    }
    
    public static func testB(count: Int, n: Int) {
        print(Self.self, "testB", n, count)
    }
    public static func add_callback(cb: PyPointer) {
        shared.py_callbacks.append(.init(callback: cb))
    }
    public static func set_callback(cb: PyPointer) {
        shared.py_callback = .init(callback: cb)
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
            class SCTCallback:
                
                @property
                def a(self):
                    return 0
            
                @a.setter
                def a(self, value):
                    print(self, "a", value)
            
                @property
                def b(self):
                    return 0
            
                @a.setter
                def b(self, value):
                    print(self, "b", value)
            
            sct_cb = SCTCallback()
            sct_cb2 = SCTCallback()
            StaticClassTest.add_callback(sct_cb)
            StaticClassTest.add_callback(sct_cb2)
            
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

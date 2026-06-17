//
//  PyCapsuleProtocol.swift
//  PySwiftKit
//

import CPython


public protocol PyCapsuleProtocol {
    
    func asCapsule() -> PyPointer
    
    static func fromCapsule(object: PyPointer) -> Self
}

extension PyCapsuleProtocol {
    
    public func asCapsule() -> PyPointer {
        let raw = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        return PyCapsule_New(raw, "\(Self.self)") { object in
            object?.deallocate()
        }
    }
    
    public static func fromCapsule(object: PyPointer) -> Self {
        unsafeBitCast(PyCapsule_GetContext(object), to: Self.self)
    }
}

extension PyCapsuleProtocol where Self: AnyObject {
    
    public func asCapsule() -> PyPointer {
        PyCapsule_New(Unmanaged.passRetained(self).toOpaque(), "\(Self.self)") { object in
            object?.deallocate()
        }
    }
    
    public static func fromCapsule(object: PyPointer) -> Self {
        Unmanaged.fromOpaque(PyCapsule_GetContext(object)).takeRetainedValue()
    }
}

struct TestCapSttuct: PyCapsuleProtocol {
    
}

class TestCapClass: PyCapsuleProtocol {
    
}

func testTestCap() {
    let test_cls = TestCapClass()
    let py_test = test_cls.asCapsule()
    
    let test_st = TestCapSttuct()
    let py_test_st = test_st.asCapsule()
}

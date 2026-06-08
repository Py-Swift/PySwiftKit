//
//  PythonObject.swift
//  PySwiftKit
//
import CPython


public struct PythonObject: ~Copyable {
    
    private let ptr: PyPointer
    
    public init(_ ptr: PyPointer) {
        self.ptr = Py_NewRef(ptr)
    }
    
    public init(consume ptr: PyPointer) {
        self.ptr = ptr
    }
    
    deinit {
        Py_DecRef(ptr)
    }
}

fileprivate func inspect(_ object: borrowing PythonObject) {}
fileprivate func eat(_ object: consuming PythonObject) {}

fileprivate func test() {
    var a: PythonObject = .init(.False)
    
    eat(a)
    
    a = .init(.True)
    inspect(a)
    
}

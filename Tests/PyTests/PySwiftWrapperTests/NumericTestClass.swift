//
//  NumericTestClass.swift
//  PySwiftKit
//
@preconcurrency import CPython
@preconcurrency import PySwiftKit

@testable import PySerializing
import PyWrapperInternal
@testable import PySwiftWrapper


@PyClass(bases: [.number])
final class NumericTestClass {
    
    @PyInit
    init(value: String) {}
}


extension NumericTestClass: PyNumberProtocol {
    func nb_add(_ other: PyPointer) -> PyPointer? {
        (try! Int.casted(from: other) + 5).pyPointer()
    }
    
    func nb_subtract(_ other: PyPointer) -> PyPointer? {
        (14 - (try! Int.casted(from: other))).pyPointer()
    }
    
    func nb_multiply(_ other: PyPointer) -> PyPointer? {
        (try! Int.casted(from: other) * 3).pyPointer()
    }
    
    func nb_true_divide(_ other: PyPointer) -> PyPointer? {
        (15 / (try! Int.casted(from: other))).pyPointer()
    }
}




@PyModule
struct PySwiftTesterModule: PyModuleProtocol {
    
    static let py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        NumericTestClass.self
    ]
}

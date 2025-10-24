//
//  PySerialize+Range.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension Range: PySerialize where Self.Bound == Int{
    public func pyPointer() -> PyPointer {
        (try? PyRange_new(start: lowerBound, stop: upperBound))!
    }
}


extension ClosedRange: PySerialize where Self.Bound == Int{
    public func pyPointer() -> PyPointer {
        (try? PyRange_new(start: lowerBound, stop: upperBound + 1))!
    }
}

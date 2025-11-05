//
//  PyStrProtocol.swift
//  PySwiftKit
//


public protocol PyStrProtocol {
    func __str__() -> String
}

extension PyStrProtocol where Self: CustomStringConvertible {
    public func __str__() -> String {
        description
    }
}

//
//  PyHashable.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 19/02/2026.
//


public protocol PyHashable {
    func __hash__() -> Int
}

extension Hashable where Self: PyHashable {
    public func __hash__() -> Int {
        var hasher = Hasher()
        hasher.combine(self)
        return hasher.finalize()
    }
}

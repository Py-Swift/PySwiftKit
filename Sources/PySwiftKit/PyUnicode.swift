//
//  PyUnicode.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 26/10/2025.
//
import CPython

public extension PyUnicode_Kind {
    static let utf8 = PyUnicode_1BYTE_KIND
    static let uft16 = PyUnicode_2BYTE_KIND
    static let utf32 = PyUnicode_4BYTE_KIND
}

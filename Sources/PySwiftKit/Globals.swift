//
//  Globals.swift 
//  PySwiftKit
//
//  Created by CodeBuilder on 16/05/2025.
//
import PythonCore

public let Py_None: PyPointer = .init(&_Py_NoneStruct)

public let Py_True: PyPointer = withUnsafeMutablePointer(to: &_Py_TrueStruct) { ptr in
    ptr.withMemoryRebound(to: PyPointer.self, capacity: 1, \.pointee)
}

public let Py_False: PyPointer = withUnsafeMutablePointer(to: &_Py_FalseStruct) { ptr in
    ptr.withMemoryRebound(to: PyPointer.self, capacity: 1, \.pointee)
}

public func PyUnicode_GetKind(_ o: PyPointer) -> PyUnicode_AsKind {
    o.withMemoryRebound(to: PyASCIIObject.self, capacity: 1) { pointer in
        .init(rawValue: pointer.pointee.state.kind) ?? .PyUnicode_1BYTE_KIND
    }
}

public func PyMemoryView_GetBuffer(_ mview: PyPointer) -> UnsafeMutablePointer<Py_buffer>! {
    mview.withMemoryRebound(to: PyMemoryViewObject.self, capacity: 1) { $0.pointer(to: \.view) }
}

//import PyKit
import PySwiftKit
import Foundation

public protocol PySerialize {

    var pyPointer: PyPointer { get }
    
}
//public typealias PySerialize = _PySerialize & PyInput

//extension PyInput where Self: PySerialize {}

extension PySerialize {
    public static func ~= (l: Self, r: PyPointer) -> Bool {
        let left = l.pyPointer
        defer { Py_DecRef(left) }
        return PyObject_RichCompareBool(left, r, Py_EQ) == 1
    }
}



extension PyPointer : PySerializing.PySerialize {

    public var pyPointer: PyPointer {
        Py_XINCREF(self)
        return self
    }
    
}

extension Optional: PySerializing.PySerialize where Wrapped: PySerializing.PySerialize {
    public var pyPointer: PyPointer {
        self?.pyPointer ?? .None
    }
}

extension Error {
    public var pyPointer: PyPointer {
        localizedDescription.pyPointer
    }
}

extension Optional where Wrapped == Error {
    public var pyPointer: PyPointer {
        self?.pyPointer ?? .None
    }
}


extension RawRepresentable where RawValue: PySerialize {
    public var pyPointer: PyPointer {
        rawValue.pyPointer
    }
}

@inlinable public func PyObject_SetAttr<T>(_ o: PyPointer, _ key: CodingKey, _ value: T) where T: PySerialize {
    key.stringValue.withCString { string in
        let object = value.pyPointer
        PyObject_SetAttrString(o, string, object)
        Py_DecRef(object)
    }
}

@_disfavoredOverload
@inlinable public func PyDict_GetItem<T: PyDeserialize>(_ dict: PythonCore.PyPointer, key: String) throws -> T {
    guard let result: PyPointer = key.withCString({ ckey in
        PyDict_GetItemString(dict, ckey)
    }) else {
        PyErr_Print()
        throw PyStandardException.keyError
    }
    return try T(object: result)
}

//@inlinable public func PyDict_GetItem<T: PyDeserializeObject>(_ dict: PythonCore.PyPointer, _ key: String) throws -> T {
//    guard let result: PyPointer = key.withCString({ ckey in
//        PyDict_GetItemString(dict, ckey)
//    }) else {
//        PyErr_Print()
//        throw PyStandardException.keyError
//    }
//    return try PyCast<T>.cast(from: result)
//}



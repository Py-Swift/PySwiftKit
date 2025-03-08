import PythonCore
import PySwiftCore
import Foundation

public protocol PySerialize {

    var pyPointer: PyPointer { get }
    
}



extension PySerialize {
    public static func ~= (l: Self, r: PyPointer) -> Bool {
        let left = l.pyPointer
        defer { Py_DecRef(left) }
        return PyObject_RichCompareBool(left, r, Py_EQ) == 1
    }
}



extension PyPointer : PySerialize {

    public var pyPointer: PyPointer {
        Py_XINCREF(self)
        return self
    }
    
}

extension Optional: PySerialize where Wrapped: PySerialize {
    public var pyPointer: PyPointer {
        self?.pyPointer ?? .None
    }
}



@inlinable public func PyObject_SetAttr<T>(_ o: PyPointer, _ key: CodingKey, _ value: T) where T: PySerialize {
    key.stringValue.withCString { string in
        let object = value.pyPointer
        PyObject_SetAttrString(o, string, object)
        Py_DecRef(object)
    }
}

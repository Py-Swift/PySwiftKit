import Foundation
import PySwiftKit
import CPython
import PyTypes
import PyComparable

extension BinaryInteger where Self: PyDeserialize {
    public static var pyType: UnsafeMutablePointer<PyTypeObject> { .PyLong }
}

extension Int : PyDeserialize {
    
    public init(object: PyPointer) throws {
        //guard PyLong_Check(object) else { throw PythonError.long }
        var overflow: Int32 = 0
        self = PyLong_AsLongAndOverflow(object, &overflow)
        if overflow == 1 { throw PyStandardException.overflowError }
        if let _ = PyErr_Occurred() {
            PyErr_Print()
            throw PyStandardException.typeError
        }
    }
    
    public static func casted(from object: PyPointer) throws -> Int {
        var overflow: Int32 = 0
        let this = PyLong_AsLongAndOverflow(object, &overflow)
        if overflow == 0 {
            return this
        }
        if let _ = PyErr_Occurred() {
            PyErr_Print()
            throw PyStandardException.typeError
        }
        throw PyStandardException.overflowError
    }
    
}



extension UInt : PyDeserialize {
    
    public init(object: PyPointer) throws {
        //guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLong(object)
    }
    
    public static func casted(from object: PyPointer) throws -> UInt {
        PyLong_AsUnsignedLong(object)
    }
    
}

extension Int64: PyDeserialize {
    
    
    public init(object: PyPointer) throws {
        var overflow: Int32 = 0
        self = PyLong_AsLongLongAndOverflow(object, &overflow)
        if overflow == 1 { throw PyStandardException.overflowError }
        if let _ = PyErr_Occurred() {
            PyErr_Print()
            throw PyStandardException.typeError
        }
    }
    
    public static func casted(from object: PyPointer) throws -> Int64 {
        PyLong_AsLongLong(object)
    }
}

extension UInt64:PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLongLong(object)
    }
}

extension Int32: PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsInt(object)
    }
}

extension UInt32: PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(PyLong_AsUnsignedLong(object))
    }
}

extension Int16: PyDeserialize {
    
    public init(object: PyPointer) throws {
        var overflow: Int32 = 0
        self.init(clamping:  PyLong_AsLongAndOverflow(object, &overflow))
        if overflow == 1 { throw PyStandardException.overflowError }
        if let _ = PyErr_Occurred() {
            PyErr_Print()
            throw PyStandardException.typeError
        }
    }
    
}

extension UInt16: PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension Int8: PyDeserialize {
    
    public init(object: PyPointer) throws {
        var overflow: Int32 = 0
        self.init(clamping:  PyLong_AsLongAndOverflow(object, &overflow))
        if overflow == 1 { throw PyStandardException.overflowError }
        if let _ = PyErr_Occurred() {
            PyErr_Print()
            throw PyStandardException.typeError
        }
    }
    
}

extension UInt8: PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
}

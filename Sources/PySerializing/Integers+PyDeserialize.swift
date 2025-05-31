import Foundation
import PySwiftKit
import PythonCore
import PyTypes
import PyComparable



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
}

extension UInt : PyDeserialize {
    
    public init(object: PyPointer) throws {
        //guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLong(object)
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
        self = _PyLong_AsInt(object)
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

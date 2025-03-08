import Foundation
import PySwiftCore
import PythonCore
import PyTypes
import PyComparable



extension Int : PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLong(object)
    }
}

extension UInt : PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsUnsignedLong(object)
    }
}
extension Int64: PyDeserialize {
    
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self = PyLong_AsLongLong(object)
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
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsLong(object))
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
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
    
}

extension UInt8: PyDeserialize {
    
    public init(object: PyPointer) throws {
        guard PyLong_Check(object) else { throw PythonError.long }
        self.init(clamping: PyLong_AsUnsignedLong(object))
    }
}

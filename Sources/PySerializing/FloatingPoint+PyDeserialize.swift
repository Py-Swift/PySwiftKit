import Foundation
import PySwiftKit
import PythonCore
import PyTypes
import PyComparable

extension Double: PyDeserialize {
    
    public init(object: PyPointer) throws {

        switch object {
        case .PyFloat:
            self = PyFloat_AsDouble(object)
        case .PyLong:
            self = PyLong_AsDouble(object)
        default:
            throw PythonError.float
        }
        
    }
}

extension Float32: PyDeserialize {
    
    public init(object: PyPointer) throws {
        switch object {
        case .PyFloat:
            self.init(PyFloat_AsDouble(object))
        case .PyLong:
            self.init(PyLong_AsDouble(object))
        default:
            throw PythonError.float
        }
    }
}

import Foundation
import PySwiftKit
import PythonCore
import PyTypes
import PyComparable



extension Bool : PyDeserialize {
    
    public init(object: PyPointer) throws {
        if object == PyTrue {
            self = true
        } else if object == PyFalse {
            self = false
        } else {
            throw PythonError.attribute
        }
        
    }
    
    
}

extension String : PyDeserialize {
    
    public init(object: PyPointer) throws {
        //guard object.notNone else { throw PythonError.unicode }
        if PyUnicode_Check(object) {
            self.init(cString: PyUnicode_AsUTF8(object))
        } else {
            guard let unicode = PyUnicode_AsUTF8String(object) else { throw PythonError.unicode }
            self.init(cString: PyUnicode_AsUTF8(unicode))
            Py_DecRef(unicode)
        }
    }
    
}


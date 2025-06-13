import Foundation
import PySwiftKit
import PythonCore
import PyTypes
import PyComparable



extension Bool : PyDeserialize {
    
    public init(object: PyPointer) throws {
        if object == PySwiftKit.Py_True {
            self = true
        } else if object == PySwiftKit.Py_False {
            self = false
        } else {
            throw PyStandardException.typeError
        }
        
    }
    
    
}

extension String : PyDeserialize {
    
    public init(object: PyPointer) throws {
        //guard object.notNone else { throw PythonError.unicode }
        
        if PyUnicode_Check(object) {
//            object.withMemoryRebound(to: PyUnicodeObject.self, capacity: 1) { pointer in
//                String(cString: pointer.pointee._base.utf8)
//            }
            self.init(cString: PyUnicode_AsUTF8(object))
        } else {
            guard let unicode = PyUnicode_AsUTF8String(object) else { throw PythonError.unicode }
            self.init(cString: PyUnicode_AsUTF8(unicode))
            Py_DecRef(unicode)
        }
    }
    
}


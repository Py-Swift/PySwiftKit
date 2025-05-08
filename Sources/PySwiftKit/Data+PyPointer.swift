import Foundation
import PythonCore
//import PythonTypeAlias



extension Data {
    
    init(pyUnicode o: PyPointer) throws {
        guard let ptr = PyUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytes: ptr, count: PyUnicode_GetLength(o))
    }
    
    init(pyUnicodeNoCopy o: PyPointer) throws {
        guard let ptr = PyUnicode_DATA(o) else { throw PythonError.unicode }
        self.init(bytesNoCopy: ptr, count: PyUnicode_GetLength(o), deallocator: .none)
    }
    
    
    
}

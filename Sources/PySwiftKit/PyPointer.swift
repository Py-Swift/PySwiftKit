import Foundation
import CoreGraphics
import PythonCore
//import PythonTypeAlias

extension PyPointer {
    @inlinable public static var None: PyPointer {
        Py_IncRef(PyNone)
        return PyNone
    }
    @inlinable public static var True: PyPointer {
        Py_IncRef(PyTrue)
        return PyTrue
    }
    @inlinable public static var False: PyPointer {
        Py_IncRef(PyFalse)
        return PyFalse
        
    }
    
    //public static let StringIO: PyPointer? = pythonImport(from: "io", import_name: "StringIO")
    
    public var xINCREF: PyPointer {
            Py_IncRef(self)
            return self
        }
	
    public var xDECREF: PyPointer {
        Py_DecRef(self)
        return self
    }
    
	public var newRef: PyPointer {
		Py_NewRef(self)
	}
    //@inlinable public static func Dict: Pyk
}





@inlinable public func PyObject_GetAttr(_ o: PyPointer, _ key: String) -> PyPointer? {
    key.withCString { string in
        PyObject_GetAttrString(o, string)
    }
}

@inlinable public func PyObject_GetAttr(_ o: PyPointer, _ key: CodingKey) -> PyPointer? {
    key.stringValue.withCString { string in
        PyObject_GetAttrString(o, string)
    }
}


@inlinable public func PyObject_HasAttr(_ o: PyPointer, _ key: String) -> Bool {
    key.withCString { string in
        PyObject_HasAttrString(o, string) == 1
    }
}

@inlinable public func PyObject_HasAttr(_ o: PyPointer, _ key: CodingKey) -> Bool {
    key.stringValue.withCString { string in
        PyObject_HasAttrString(o, string) == 1
    }
}

@inlinable public func PyDict_GetItem(_ mp: PyPointer, _ key: String) throws -> PyPointer {
    try key.withCString { ckey in
        guard let result = Python.PyDict_GetItemString(mp, ckey) else { throw PyStandardException.keyError }
        return result
    }
}

@inlinable public func PyTuple_GetItem(_ o: PyPointer, _ index: Int) throws -> PyPointer {
    guard let result: PyPointer = Python.PyTuple_GetItem(o, index) else { throw PyStandardException.indexError }
    return result
}

extension PythonPointer {
    
    @inlinable
        public func getBuffer() -> UnsafeBufferPointer<PythonPointer?> {
            let fast_list = PySequence_Fast(self, nil)!
            let list_count = PySequence_FastSize(fast_list)
            let fast_items = PySequence_FastItems(fast_list)
            let buffer = PySequenceBuffer(start: fast_items, count: list_count)
            Py_DecRef(fast_list)
            return buffer
        }
    
    @inlinable public var sequence: UnsafeBufferPointer<PythonPointer?> {
        let fast_list = PySequence_Fast(self, nil)!
        
        let buffer = PySequenceBuffer(
            start: PySequence_FastItems(fast_list),
            count: PySequence_FastSize(fast_list)
        )
        Py_DecRef(fast_list)
        return buffer
    }
    
    @inlinable public var _sequence: PySequenceBuffer? {
        guard PySequence_Check(self) == 1 else { return nil }
        
        let fast_list = PySequence_Fast(self, nil)!
        let buffer = PySequenceBuffer(
			start: PySequence_FastItems(fast_list),
            count: PySequence_FastSize(fast_list)
        )
        Py_DecRef(fast_list)
        return buffer
    }
    
    
}




extension PythonPointer {
    
  
    
    
    
    
    
    @inlinable public var iterator: PythonPointer? { PyObject_GetIter(self) }
    
    @inlinable public var is_sequence: Bool { PySequence_Check(self) == 1 }
    @inlinable public var is_dict: Bool { PyDict_Check(self) }
    @inlinable public var is_tuple: Bool { PyTuple_Check(self)}
    @inlinable public var is_unicode: Bool { PyUnicode_Check(self) }
    @inlinable public var is_int: Bool { PyLong_Check(self) }
    @inlinable public var is_float: Bool {PyBool_Check(self) }
    @inlinable public var is_iterator: Bool { PyIter_Check(self) == 1}
    @inlinable public var is_bytearray: Bool { PyByteArray_Check(self) }
    @inlinable public var is_bytes: Bool { PyBytes_Check(self) }
	@inlinable public var is_None: Bool { PyObject_RichCompareBool(self, PyNone, Py_EQ) == 1 }
    @inlinable public var isNone: Bool { self == PyNone }
	@inlinable public var is_not_None: Bool { PyObject_RichCompareBool(self, PyNone, Py_EQ) == 0 }
    @inlinable public var notNone: Bool { self != PyNone }
    
    @inlinable public func decref() {
        //Py_DecRef(self)
		//Py_DECREF(self)
		_Py_DecRef(self)
    }
    
    @inlinable public func incref() {
        //Py_IncRef(self)
		_Py_IncRef(self)
		//Py_INCREF(self)
    }
    
//    @inlinable
//    func callAsFunction(method name: PythonPointer) -> Void {
//        PyObject_CallMethodNoArgs(self, name)
//    }
    

}



public enum PyUnicode_AsKind: UInt32 {
/* String contains only wstr byte characters.  This is only possible
   when the string was created with a legacy API and _PyUnicode_Ready()
   has not been called yet.  */
    case PyUnicode_WCHAR_KIND = 0
/* Return values of the PyUnicode_KIND() macro: */
    case PyUnicode_1BYTE_KIND = 1
    case PyUnicode_2BYTE_KIND = 2
    case PyUnicode_4BYTE_KIND = 4
}


@inlinable public func bytesAsDataNoCopy(bytes: PythonPointer) -> Data? {
    let data_size = PyBytes_Size(bytes)
    // PyBytes to MemoryView
	guard let mview = PyMemoryView_FromObject(bytes) else { return nil }
    // fetch PyBuffer from MemoryView
    let py_buf = PyMemoryView_GetBuffer(mview)
    var indices = [0]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}

@inlinable public func bytearrayAsDataNoCopy(bytes: PythonPointer) -> Data? {
    let data_size = PyByteArray_Size(bytes)
    // PyBytes to MemoryView
	guard let mview = PyMemoryView_FromObject(bytes) else { return nil }
    // fetch PyBuffer from MemoryView
    let py_buf = PyMemoryView_GetBuffer(mview)
    var indices = [0]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: data_size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}




@inlinable public func bytesSlicedAsDataNoCopy(bytes: PythonPointer, start: Int, size: Int) -> Data? {
    // PyBytes to MemoryView
	guard let mview = PyMemoryView_FromObject(bytes) else { return nil }
    // fetch PyBuffer from MemoryView
    let py_buf = PyMemoryView_GetBuffer(mview)
    var indices = [start]
    // fetch RawPointer from PyBuffer, if fail return nil
    guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
    let data = Data(bytesNoCopy: buf_ptr, count: size, deallocator: .none)
    // Release PyBuffer and MemoryView
    Py_DecRef(mview)
    return data
}



extension PythonPointer {
    // PyBytes -> Data
    @inlinable public func bytesAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
		guard let mview = PyMemoryView_FromObject(self) else { return nil }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func strAsData() -> Data? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
		guard let mview = PyMemoryView_FromObject(self) else { return nil }
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytesSlicedAsData(start: Int, size: Int) -> Data? {
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [start]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        let data = Data(bytes: buf_ptr, count: size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    @inlinable public func bytearrayAsData() -> Data? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let data = Data(bytes: buf_ptr, count: data_size)
        // Release MemoryView
        Py_DecRef(mview)
        return data
    }
    
    
    
    @inlinable public func bytesAsArray() -> [UInt8]? {
        let data_size = PyBytes_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // finally create Array<UInt8> from the buf_ptr
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release PyBuffer and MemoryView
        Py_DecRef(mview)
        return array
    }
    
    @inlinable public func bytearrayAsArray() -> [UInt8]? {
        let data_size = PyByteArray_Size(self)
        // PyBytes to MemoryView
        let mview = PyMemoryView_FromObject(self)!
        // fetch PyBuffer from MemoryView
        let py_buf = PyMemoryView_GetBuffer(mview)
        var indices = [0]
        // fetch RawPointer from PyBuffer, if fail return nil
        guard let buf_ptr = PyBuffer_GetPointer(py_buf, &indices) else { return nil}
        // cast RawPointer as UInt8 pointer
        let array = [UInt8](UnsafeBufferPointer(
            start: buf_ptr.assumingMemoryBound(to: UInt8.self),
            count: data_size)
        )
        // Release MemoryView
        Py_DecRef(mview)
        return array
    }
    
   
    
    
    
    
}

@inlinable public func asPyBool(_ state: Bool) -> PythonPointer {
    if state { return PyTrue }
    
    return PyFalse
}

extension Bool {
    @inlinable public var object: PythonPointer {
        if self { return PyTrue.xINCREF }
        return PyFalse.xINCREF
    }
}


extension Data {
    @inlinable public var jsonStr: PythonPointer {
        return self.withUnsafeBytes { buf in
            PyUnicode_FromKindAndData(1, buf.baseAddress, self.count)
        }
    }
}






//extension SignedInteger {
//    @inlinable public var python_int: PythonPointer {PyLong_FromLong(Int(self)) }
//    @inlinable public var pyInt: PythonPointer {PyLong_FromLong(Int(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension UnsignedInteger {
//    @inlinable public var python_int: PythonPointer { PyLong_FromUnsignedLong(UInt(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension Int {
//    @inlinable public var python_int: PythonPointer { PyLong_FromLong(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension UInt {
//    @inlinable public var python_int: PythonPointer { PyLong_FromUnsignedLong(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//
//}
//
//extension Double {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//
//extension Float {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(Double(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//#if os(iOS)
//@available(iOS 14, *)
//extension Float16 {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(Double(self)) }
//    //var python_str: PythonPointer { PyUnicode_FromString(String(self)) }
//}
//#endif
//extension CGFloat {
//    @inlinable public var python_float: PythonPointer { PyFloat_FromDouble(self) }
//    //var python_str: PythonPointer { PyUnicode_FromString("\(self)") }
//}
//extension Array where Element == PyConvertible {
//        @inlinable public var pythonList: PythonPointer {
//            let list = PyList_New(0)
//            for element in self {
//                PyList_Append(list, element.pyPointer)
//            }
//            return list
//        }
//}

//extension Array where Element == PythonPointer {
//
//
////
////    @inlinable public var pythonList: PythonPointer {
////        let list = PyList_New(0)
////        for element in self {
////            PyList_Append(list, element)
////        }
////        return list
////    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element)
//            Py_DecRef(element)
//        }
//        return tuple
//    }
//}

//extension Array where Element == String {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.withCString(PyUnicode_FromString) )
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyUnicode_FromString(element))
//        }
//        return tuple
//    }
//}
//
//extension Array where Element == URL {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.path.withCString(PyUnicode_FromString) )
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element.path.withCString(PyUnicode_FromString) )
//        }
//        return tuple
//    }
//}

//extension Array where Element == Double {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyFloat_FromDouble(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyFloat_FromDouble(element))
//        }
//        return tuple
//    }
//}


//extension Array where Element: SignedInteger  {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(Int(element)))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(Int(element)))
//        }
//        return tuple
//    }
//}

//extension Array where Element: UnsignedInteger {
//    public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return list
//    }
//
//    var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(UInt(element)))
//        }
//        return tuple
//    }
//}


//extension Array where Element == Int {
//
//    init(_ object: PythonPointer) {
//        self.init()
//
//    }
//
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromLong(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromLong(element))
//        }
//        return tuple
//    }
//}

//extension Array where Element == UInt {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, PyLong_FromUnsignedLong(element))
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, PyLong_FromUnsignedLong(element))
//        }
//        return tuple
//    }
//}

//extension Array where Element == Bool {
//    @inlinable public var pythonList: PythonPointer {
//        let list = PyList_New(0)
//        for element in self {
//            PyList_Append(list, element.object)
//        }
//        return list
//    }
//
//    @inlinable public var pythonTuple: PythonPointer {
//        let tuple = PyTuple_New(self.count)
//        for (i, element) in self.enumerated() {
//            PyTuple_SetItem(tuple, i, element.object)
//        }
//        return tuple
//    }
//}


extension PythonPointer {
    
    public var printString: String {
        debugDescription
        //if let this = self {
            //return this.debugDescription
        //}
        //return "nil"
        
    }
}

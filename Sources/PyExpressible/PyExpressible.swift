import Foundation
import PySwiftKit

import PythonCore

//extension StringInterpolationProtocol {
//	public mutating func appendLiteral(_ literal: PyPointer) {
//		switch literal {
//		case pyUnicode_Type: appendLiteral(try! .init(object: literal))
//		default: appendLiteral(try! pyCast(consuming: PyObject_Str(literal)))
//		}
//		self.appendLiteral("<NULL>")
//	}
//}

extension PyPointer: Swift.CustomStringConvertible {
	public var description: String {
		guard let str = PyObject_Str(self) else { return "\(self.debugDescription)"}
		defer { str.decref() }
		return .init(cString: PyUnicode_AsUTF8(str))
	}
	
	
}


extension PythonPointer: Swift.ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = String
    @inlinable public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = value.withCString(PyUnicode_FromString) ?? .None
    }
}

extension PyPointer: Swift.ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = PythonPointer
	
	public init(arrayLiteral elements: PythonPointer...) {
		let list = PyList_New(elements.count)
		for (i, element) in elements.enumerated() {
			//PyList_Append(list, element)
			PyList_Insert(list, i, element)
		}
		self = list ?? .None
	}
}

//extension Optional: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped == UnsafeMutablePointer<PyObject> {
//    public typealias ExtendedGraphemeClusterLiteralType = String
//    @inlinable public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        self = value.withCString(PyUnicode_FromString)
//    }
//}

extension PythonPointer: Swift.ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = String
    @inlinable public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = value.withCString(PyUnicode_FromString) ?? .None
    }
}


extension PythonPointer: Swift.ExpressibleByStringLiteral  {

    @inlinable public init(stringLiteral value: StringLiteralType) {
        self = value.withCString(PyUnicode_FromString) ?? .None
    }
}

//extension PythonPointer: ExpressibleByIntegerLiteral {
//    
//    public init(integerLiteral value: IntegerLiteralType) {
//        self = PyLong_FromLong(value)
//    }
//}


//extension PythonPointer: ExpressibleByFloatLiteral {
//    public init(floatLiteral value: FloatLiteralType) {
//        self = PyFloat_FromDouble(value)
//    }
//}


extension PyPointer: Swift.ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        
        self = Py_NewRef(value ? Py_True : Py_False)
    }
}






extension PyPointer: Swift.ExpressibleByDictionaryLiteral {
    public typealias Key = String
    
    public typealias Value = PyPointer
    
    public init(dictionaryLiteral elements: (Key, PyPointer)...) {
        self = PyDict_New()
        for (k, v) in elements {
            k.withCString{ key -> Void in
                PyDict_SetItemString(self, key, v)
                //Py_DecRef(v)
            }
        }
    }
}

extension Dictionary where Key == String, Value == PyPointer {
    
    var pythonDict: PythonPointer {
        let dict = PyDict_New()
        for (k, v) in self {
            k.withCString { key -> Void in
                PyDict_SetItemString(dict, key, v)
                //Py_DecRef(v)
            }
        }
        return dict ?? .None
    }
}

fileprivate let test_expression = {
//    let pyList: PyPointer = ["",true,false,1,2.0]
//    let aDict: [String : PythonPointer] = [
//        "int": 1,
//        "string": "str",
//    ]
//    // PyDict from [String:PyPointer]
//    //
//    let pyDict0 = aDict.pythonDict
//    
//    let pyDict1: PyPointer = [
//            "int": 1,
//            "string": "str",
//        ]
    
}

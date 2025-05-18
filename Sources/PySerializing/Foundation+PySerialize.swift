//
//  Foundation+PySerialize.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 05/01/2025.
//

import PythonCore
import PySwiftKit
import Foundation



extension Bool : PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        if self {
            return .True
        }
        return .False
    }
    
}


extension String : PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        withCString(PyUnicode_FromString) ?? .None
    }
}




extension URL : PySerializing.PySerialize {

    public var pyPointer: PyPointer {
        path.withCString(PyUnicode_FromString) ?? .None
    }
    
}

extension Int : PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(self)
    }
    
}

extension UInt : PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(self)
    }
    

    
}
extension Int64: PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLongLong(self)
    }

}

extension UInt64: PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLongLong(self)
    }
    
}

extension Int32: PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
}

extension UInt32: PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension Int16: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt16: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }

}

extension Int8: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt8: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }
}

extension Double: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }
    
}

extension CGFloat: PySerializing.PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }

}

extension Float32: PySerializing.PySerialize {
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(Double(self))
    }
}

extension Data: PySerializing.PySerialize {
    public var pyPointer: PyPointer {
        var data = self
        let size = self.count //* uint8_size
        let buffer = data.withUnsafeMutableBytes {$0.baseAddress}
        var pybuf = Py_buffer()
        PyBuffer_FillInfo(&pybuf, nil, buffer, size , 0, PyBUF_WRITE)
        let mem = PyMemoryView_FromBuffer(&pybuf)
        let bytes = PyBytes_FromObject(mem) ?? .None
        Py_DecRef(mem)
        return bytes
    }
}

extension Array: PySerializing.PySerialize where Element : PySerializing.PySerialize {

    public var pyPointer: PyPointer {
        guard let list = PyList_New(count) else { fatalError("creating new list failed, make sure GIL is active")}
        var _count = 0
        for element in self {
            PyList_SetItem(list, _count, element.pyPointer)
            _count += 1
        }
        return list
    }
    
    
    @inlinable public var pythonTuple: PythonPointer {
        let tuple = PyTuple_New(self.count)
        for (i, element) in self.enumerated() {
            PyTuple_SetItem(tuple, i, element.pyPointer)
        }
        return tuple ?? .None
    }
    
}


extension Dictionary: PySerializing.PySerialize where Key: PySerializing.PySerialize, Value: PySerializing.PySerialize  {
    

    public var pyPointer: PyPointer {
        let dict = PyDict_New()
        for (key,value) in self {
            let v = value.pyPointer
            let k = key.pyPointer
            //_ = key.withCString{PyDict_SetItemString(dict, $0, v)}
            PyDict_SetItem(dict, k, v)
            Py_DecRef(k)
        }
        return dict ?? .None
    }
}

extension Dictionary where Key == String, Value: PySerializing.PySerialize  {
    
    public var pyPointer: PyPointer {
        let dict = PyDict_New()
        for (key,value) in self {
            let v = value.pyPointer
            _ = key.withCString{PyDict_SetItemString(dict, $0, v)}
        }
        return dict ?? .None
    }
    
}

extension Dictionary where Key == StringLiteralType, Value == PySerialize  {
    

    public var pyPointer: PyPointer {
        let dict = PyDict_New()
        for (key,value) in self {
            let v = value.pyPointer
            _ = key.withCString{PyDict_SetItemString(dict, $0, v)}
            //Py_DecRef(v)
        }
        return dict ?? .None
    }
    
    
}

extension KeyValuePairs: PySerializing.PySerialize where Key: PySerializing.PySerialize, Value: PySerializing.PySerialize {
    public var pyPointer: PyPointer {
        let dict = PyDict_New()!
        for (k, v) in self {
            let key = k.pyPointer
            let o = v.pyPointer
            PyDict_SetItem(dict, key, o)
            _Py_DecRef(key)
            _Py_DecRef(o)
        }
        return dict
    }
}


extension Error where Self: PySerializing.PySerialize {
    public var pyPointer: PyPointer {
        localizedDescription.pyPointer
    }
}

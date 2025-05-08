//
//  Foundation+PySerialize.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 05/01/2025.
//

import PythonCore
import PySwiftKit
import Foundation



extension Bool : PySerialize {
    
    
    public var pyPointer: PyPointer {
        if self {
            return .True
        }
        return .False
    }
    
}


extension String : PySerialize {
    
    public var pyPointer: PyPointer {
        withCString(PyUnicode_FromString) ?? .None
    }
}




extension URL : PySerialize {

    public var pyPointer: PyPointer {
        path.withCString(PyUnicode_FromString) ?? .None
    }
    
}

extension Int : PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(self)
    }
    
}

extension UInt : PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(self)
    }
    

    
}
extension Int64: PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLongLong(self)
    }

}

extension UInt64: PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLongLong(self)
    }
    
}

extension Int32: PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }
    
}

extension UInt32: PySerialize {
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension Int16: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt16: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }

}

extension Int8: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromLong(Int(self))
    }

}

extension UInt8: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyLong_FromUnsignedLong(UInt(self))
    }
}

extension Double: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }
    
}

extension CGFloat: PySerialize {
    
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(self)
    }

}

extension Float32: PySerialize {
    
    public var pyPointer: PyPointer {
        PyFloat_FromDouble(Double(self))
    }
}

extension Data: PySerialize {
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

extension Array: PySerialize where Element : PySerialize {

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


extension Dictionary: PySerialize where Key: PySerialize, Value: PySerialize  {
    

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

extension Dictionary where Key == String, Value: PySerialize  {
    
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

extension KeyValuePairs: PySerialize where Key: PySerialize, Value: PySerialize {
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


extension Error where Self: PySerialize {
    public var pyPointer: PyPointer {
        localizedDescription.pyPointer
    }
}

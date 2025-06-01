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
        var element_size = MemoryLayout<UInt8>.size
        var size = self.count //* uint8_size
        //let buffer = data.withUnsafeMutableBytes {$0.baseAddress}
        return data.withUnsafeMutableBytes { raw in
            var buffer = Py_buffer()
            
            
            buffer.buf = raw.baseAddress
            
            buffer.len = size
            buffer.readonly = 0
            buffer.itemsize = element_size
            buffer.format = .ubyte_format
            buffer.ndim = 1
            buffer.shape = .init(&size)
            buffer.strides = .init(&element_size)
            
            buffer.suboffsets = nil
            buffer.internal = nil
            
            let mem = PyMemoryView_FromBuffer(&buffer)
            let bytes = PyBytes_FromObject(mem) ?? .None
            Py_DecRef(mem)
            return bytes
        }
        
    }
}

extension Array: PySerializing.PySerialize where Element : PySerializing.PySerialize {

    @inlinable public var pyPointer: PyPointer {
        guard let list = PyList_New(count) else { fatalError("creating new list failed, make sure GIL is active")}
        guard count > 0 else { return list}
        list.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            var ob_item = pointer.pointee.ob_item!
            //var _count = 0
            for element in self {
                //ob_item[_count] = element.pyPointer
                ob_item.pointee = element.pyPointer
                ob_item = ob_item.advanced(by: 1)
                //_count += 1
            }
        }
        return list
    }
    
    
    @inlinable public var pythonTuple: PythonPointer {
        let tuple = PyTuple_New(self.count)!
        
        tuple.withMemoryRebound(to: PyTupleObject.self, capacity: 1) { pointer in
            let obs = pointer.pointer(to: \.ob_item)!
            var _count = 0
            for element in self {
                obs[_count] = element.pyPointer
                _count += 1
            }
        }
        return tuple
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

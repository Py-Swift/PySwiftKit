import PySwiftKit
import PythonCore
import PyTypes
import PyComparable

extension Double: PyDeserialize {
    
    public init(object: PyPointer) throws {

        switch object {
        case .PyFloat:
            //self = PyFloat_AsDouble(object)
            self = unsafeBitCast(object, to: UnsafeMutablePointer<PyFloatObject>.self).pointee.ob_fval
        case .PyLong:
            var overflow: Int32 = 0
            let long = PyLong_AsLongAndOverflow(object, &overflow)
            if overflow == 1 {
                
            }
            self.init(long)
            
        default:
            throw PythonError.float
        }
        
    }
}

extension Float32: PyDeserialize {
    
    public init(object: PyPointer) throws {
        switch object {
        case .PyFloat:
            //self = PyFloat_AsDouble(object)
            self.init(
                object.withMemoryRebound(to: PyFloatObject.self, capacity: 1, { pointer in
                    pointer.pointee.ob_fval
                })
            )
        case .PyLong:
            var overflow: Int32 = 0
            let long = PyLong_AsLongAndOverflow(object, &overflow)
            if overflow == 1 {
                
            }
            self.init(long)
            
        default:
            throw PythonError.float
        }
    }
}

@available(macOS 13,iOS 16 ,*)
extension Duration: PySerializable {
    public init(object: PyPointer) throws {
        switch object {
        case .PyFloat:
            self = .seconds(try Double(object: object))
        case .PyLong:
            self = .seconds(try Int64(object: object))
        case .PyTuple:
            self = .init(
                secondsComponent: try PyTuple_GetItem(object, index: 0),
                attosecondsComponent: try PyTuple_GetItem(object, index: 1)
            )
        default: throw PyStandardException.typeError
        }
        
        
    }
    
    public var pyPointer: PyPointer {
        
        let tuple = PyTuple_New(2)!
        PyTuple_SET_ITEM(tuple, 0, components.seconds.pyPointer)
        PyTuple_SET_ITEM(tuple, 1, components.seconds.pyPointer)
        return tuple
    }
}


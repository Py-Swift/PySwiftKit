//import Foundation
//import PySwiftKit
//import PySerializing
////import PythonTypeAlias
//import PythonCore
//extension PyPointer {
//
////    @inlinable
////    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
////
////        let fast_list = PySequence_Fast(self, "fastMap only accepts Lists or Tuples")
////        let list_count = PySequence_FastSize(fast_list)
////        let fast_items = PySequence_FastItems(fast_list)
////        let buffer = UnsafeBufferPointer(start: fast_items,
////                                         count: list_count)
////        let initialCapacity = list_count
////        var result = ContiguousArray<T>()
////        result.reserveCapacity(initialCapacity)
////        for element in buffer {
////            guard let element = element else {return []}
////            result.append(try transform(element))
////        }
////        Py_DecRef(fast_list)
////        return Array(result)
////    }
//
//
////    @inlinable
////    public func map2<T>( _ transform: (Element) throws -> T) rethrows -> [T] {
////        let initialCapacity = underestimatedCount
////        var result = ContiguousArray<T>()
////        result.reserveCapacity(initialCapacity)
////
////        let fast_list = PySequence_Fast(self, "fastMap only accepts Lists or Tuples")
////        let list_count = PySequence_FastSize(fast_list)
////        let fast_items = PySequence_FastItems(fast_list)!
////        //let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
////        for i in 0..<list_count {
////            result.append(try transform(fast_items[i]!))
////        }
////        Py_DecRef(fast_list)
////        return Array(result)
////    }
//
//
//    @inlinable
//    public __consuming func array() -> [PythonPointer] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [PythonPointer]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(element!)
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
////    @inlinable
////    public __consuming func array() -> [PythonPointerU] {
////        let fast_list = PySequence_Fast(self, "")!
////        let list_count = PySequence_FastSize(fast_list)
////        let fast_items = PySequence_FastItems(fast_list)
////        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
////        var array = [PythonPointerU]()
////        array.reserveCapacity(buffer.count)
////        for element in buffer {
////            array.append(element!)
////        }
////        Py_DecRef(fast_list)
////        return array
////    }
//
//
//    @inlinable
//    public __consuming func array() -> [String] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [String]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            guard let element = element, let str = try? String(object: element) else {
//                print("Sequence contains none PyUnicode item")
//                return []
//            }
//            array.append(str)
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Int] {
//        let fast_list = PySequence_Fast(self, nil)!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Int]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(PyLong_AsLong(element))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [UInt] {
//        let fast_list = PySequence_Fast(self, nil)!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [UInt]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(PyLong_AsUnsignedLong(element))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Int64] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Int64]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(PyLong_AsLongLong(element))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [UInt64] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [UInt64]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(PyLong_AsUnsignedLongLong(element))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Int32] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Int32]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(Int32(truncatingIfNeeded: PyLong_AsLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [UInt32] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [UInt32]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(UInt32(truncatingIfNeeded: PyLong_AsUnsignedLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Int16] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Int16]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(Int16(truncatingIfNeeded: PyLong_AsLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [UInt16] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [UInt16]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(UInt16(truncatingIfNeeded: PyLong_AsUnsignedLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Int8] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Int8]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(Int8(truncatingIfNeeded: PyLong_AsLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [UInt8] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [UInt8]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(UInt8(truncatingIfNeeded: PyLong_AsUnsignedLong(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Float] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Float]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(Float(PyFloat_AsDouble(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//
//    @inlinable
//    public __consuming func array() -> [Double] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Double]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(Double(PyFloat_AsDouble(element)))
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//
//    @inlinable
//    public __consuming func array() -> [Bool] {
//        let fast_list = PySequence_Fast(self, "")!
//        let list_count = PySequence_FastSize(fast_list)
//        let fast_items = PySequence_FastItems(fast_list)
//        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
//        var array = [Bool]()
//        array.reserveCapacity(buffer.count)
//        for element in buffer {
//            array.append(PyObject_IsTrue(element) == 1)
//        }
//        Py_DecRef(fast_list)
//        return array
//    }
//}

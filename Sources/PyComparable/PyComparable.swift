//import Foundation
//#if BEEWARE
//import CPython
//#endif
//
//
//
//extension PyConvertible {
//
//    @inlinable static public func < (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_LT) == 1
//        Py_DecRef(l)
//        return result
//    }
//
//    @inlinable static public func > (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_GT) == 1
//        Py_DecRef(l)
//        return result
//    }
//
//    @inlinable static public func >= (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_GE) == 1
//        Py_DecRef(l)
//        return result
//    }
//
//    @inlinable static public func <= (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_LE) == 1
//        Py_DecRef(l)
//        return result
//    }
//
//    @inlinable static public func == (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_EQ) == 1
//        Py_DecRef(l)
//        return result
//    }
//
//    @inlinable static public func != (lhs: Self, rhs: PythonPointer) -> Bool {
//        let l = lhs.pyPointer
//        let result = PyObject_RichCompareBool(l, rhs, Py_NE) == 1
//        Py_DecRef(l)
//        return result
//    }
//}
//
//extension PythonPointer {
//
//
//    @inlinable static public func < (lhs: Self, rhs: PyConvertible) -> Bool  {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_LT) == 1
//        Py_DecRef(r)
//        return result
//    }
//
//    @inlinable static public func > (lhs: Self, rhs: PyConvertible) -> Bool {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_GT) == 1
//        Py_DecRef(r)
//        return result
//    }
//
//    @inlinable static public func >= (lhs: Self, rhs: PyConvertible) -> Bool {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_GE) == 1
//        Py_DecRef(r)
//        return result
//    }
//
//    @inlinable static public func <= (lhs: Self, rhs: PyConvertible) -> Bool {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_LE) == 1
//        Py_DecRef(r)
//        return result
//    }
//
//    @inlinable static public func == (lhs: Self, rhs: PyConvertible) -> Bool {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_EQ) == 1
//        Py_DecRef(r)
//        return result
//    }
//
//    @inlinable static public func != (lhs: Self, rhs: PyConvertible) -> Bool {
//        let r = rhs.pyPointer
//        let result = PyObject_RichCompareBool(lhs, r, Py_NE) == 1
//        Py_DecRef(r)
//        return result
//    }
////    @inlinable static func == (lhs: Self, rhs: PythonPointer) -> Bool {
////        //return PyObject_RichCompareBool(lhs, rhs, Py_EQ) == 1
////        lhs == rhs
////    }
////
////    @inlinable static func != (lhs: Self, rhs: PythonPointer) -> Bool {
////        if rhs == nil {
////            return PyObject_RichCompareBool(PyNone, lhs, Py_NE) == 1
////        }
////        return PyObject_RichCompareBool(lhs, rhs, Py_NE) == 1
////    }
//
//    @inlinable static public func < (lhs: Self, rhs: Self) -> Bool {
//        return PyObject_RichCompareBool(lhs, rhs, Py_LT) == 1
//    }
//
//    @inlinable static func <= (lhs: Self, rhs: Self) -> Bool {
//        return PyObject_RichCompareBool(lhs, rhs, Py_LE) == 1
//    }
//
//    @inlinable static func > (lhs: Self, rhs: Self) -> Bool {
//        return PyObject_RichCompareBool(lhs, rhs, Py_GT) == 1
//    }
//
//    @inlinable static func >= (lhs: Self, rhs: Self) -> Bool {
//        return PyObject_RichCompareBool(lhs, rhs, Py_GE) == 1
//    }
//
//
//    @inlinable static func += (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Add( lhs , rhs )
//    }
//    @inlinable static func -= (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Subtract( lhs , rhs )
//    }
//    @inlinable static func /= (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_TrueDivide( lhs , rhs )
//    }
//    @inlinable static func *= (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Multiply( lhs , rhs )
//    }
//    @inlinable static func + (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Add( lhs , rhs )
//    }
//    @inlinable static func - (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Subtract( lhs , rhs )
//    }
//    @inlinable static func / (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_TrueDivide( lhs , rhs )
//    }
//    @inlinable static func * (lhs:  Self, rhs: PythonPointer) -> Self {
//        return PyNumber_Multiply( lhs , rhs )
//    }
////    @inlinable static func == (lhs: Self, rhs: PythonPointerU) -> Bool {
////        return PyObject_RichCompareBool(lhs, rhs, Py_EQ) == 1
////    }
////
//
////    @inlinable static func += (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Add( lhs , rhs )
////    }
////    @inlinable static func += (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Add( lhs , rhs )
////    }
////
////    @inlinable static func -= (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Subtract( lhs , rhs )
////    }
////    @inlinable static func -= (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Subtract( lhs , rhs )
////    }
////
////    @inlinable static func /= (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_TrueDivide( lhs , rhs )
////    }
////    @inlinable static func /= (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_TrueDivide( lhs , rhs )
////    }
////
////    @inlinable static func *= (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Multiply( lhs , rhs )
////    }
////    @inlinable static func *= (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Multiply( lhs , rhs )
////    }
////
////    @inlinable static func + (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Add( lhs , rhs )
////    }
////    @inlinable static func + (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Add( lhs , rhs )
////    }
////
////    @inlinable static func - (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Subtract( lhs , rhs )
////    }
////    @inlinable static func - (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Subtract( lhs , rhs )
////    }
////
////    @inlinable static func / (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_TrueDivide( lhs , rhs )
////    }
////    @inlinable static func / (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_TrueDivide( lhs , rhs )
////    }
////
////    @inlinable static func * (lhs:  Self, rhs: PythonPointerU) -> Self {
////        return PyNumber_Multiply( lhs , rhs )
////    }
////    @inlinable static func * (lhs:  PythonPointerU, rhs: Self) -> Self {
////        return PyNumber_Multiply( lhs , rhs )
////    }
//
//}
//

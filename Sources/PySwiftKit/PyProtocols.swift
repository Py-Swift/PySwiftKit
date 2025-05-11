import Foundation
import PythonCore
//import PythonTypeAlias


public protocol PyBytesProtocol {
	func __bytes__() -> PyPointer?
}

public protocol PySequenceProtocol {
	func __len__() -> Int
	func __add__(_ other: PyPointer?) -> PyPointer?
	func __iadd__(_ item: PyPointer?) -> PyPointer?
	func __mul__(_ n: Int) -> PyPointer?
	func __imul__(_ n: Int) -> PyPointer?
    func __getitem__(_ i: Int) -> PyPointer?
	func __setitem__(_ i: Int, _ item: PyPointer?) -> Int32
	func __contains__(_ item: PyPointer?) -> Int32
//	func __repeat__(count: Int, value: PyPointer?) -> PyPointer?
//	func __irepeat__(count: Int, value: PyPointer?)
}

public protocol PyMappingProtocol {
	func __len__() -> Int
	func __getitem__(key: String) -> PyPointer?

}

public protocol PyMutableMappingProtocol: PyMappingProtocol {
	func __setitem__(_ key: PyPointer, _ item: PyPointer?) -> Int32
    func __setitem__(_ key: PyPointer, _ item: PyPointer) -> Int32
    func __delitem__(_ key: PyPointer) -> Int32
//	func __getitem__(key: String) -> PyPointer?
//	func __setitem__(key: String, value: PyPointer) -> Int32
//	func __delitem__(key: String) -> Int32
}

extension PyMutableMappingProtocol {
    public func __setitem__(_ key: PyPointer, _ item: PyPointer?) -> Int32 {
        if let item {
            __setitem__(key, item)
        } else {
            __delitem__(key)
        }
    }
}


public protocol PyHashable {
    func __hash__() -> Int
}

public protocol PyStrProtocol {
	func __str__() -> String
}

public protocol PyIntProtocol {
	func __int__() -> Int
}

public protocol PyFloatProtocol {
	func __float__() -> Double
}



public protocol PyAsyncIterableProtocol {
    func __am_aiter__(_self_: _PySwiftObjectPointer) -> PyPointer?
}

public protocol PyAsyncIteratorProtocol {
	func __am_anext__(_self_: _PySwiftObjectPointer) -> PyPointer?
}

public protocol PyAsyncProtocol: PyAsyncIteratorProtocol, PyAsyncIterableProtocol {
	func __am_await__(_self_: _PySwiftObjectPointer) -> PyPointer?
	func __am_send__(_ arg: PyPointer?, _ kwargs: UnsafeMutablePointer<PyPointer?>?) -> PySendResultFlag
}

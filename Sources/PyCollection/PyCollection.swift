
import PySwiftKit
import PythonCore
import Foundation
//import PyDeserializing
import PySerializing

extension Array : PyDeserialize where Element : PyDeserialize {
	
}

extension Array where Element: PyDeserialize {
    @_disfavoredOverload
    public init(object: PyPointer) throws {
        guard
            PyObject_TypeCheck(object, .PyList)
        else { throw PyStandardException.typeError }
        
        self = try object.map {
            guard let element = $0 else { throw PyStandardException.indexError }
            //return try Element(object: element)
            return try Element.casted(from: element)
        }//(Element.init)
        
    }
    
    public static func casted(from object: PyPointer) throws -> Array<Element> {
        guard
            PyObject_TypeCheck(object, .PyList)
        else { throw PyStandardException.typeError }
                
        return try object.map { element in
            if let element {
                try Element.casted(from: element)
            } else {
                throw PyStandardException.typeError
            }
        }
    }
}

extension Array where Element: PyDeserialize, Element: AnyObject {
    
    public init(object: PyPointer) throws {
        guard
            PyObject_TypeCheck(object, .PyList)
        else { throw PyStandardException.typeError }
        
        self = try object.map {
            guard let element = $0 else { throw PyStandardException.indexError }
            return try Element.casted(from: element)
        }//(Element.init)
        
    }
    
    public static func casted(from object: PyPointer) throws -> Self {
        guard
            PyObject_TypeCheck(object, .PyList)
        else { throw PyStandardException.typeError }
                
        return try object.map { element in
            if let element {
                try Element.casted(from: element)
            } else {
                throw PyStandardException.typeError
            }
        }

    }
}

extension Optional where Wrapped: PyDeserializeObject {
    
}

extension Array where Element: PyDeserializeObject {
    
//    public init(object: PyPointer) throws {
//        guard
//            PyObject_TypeCheck(object, .PyList)
//        else { throw PyStandardException.typeError }
//        
//        self = try object.map {
//            guard let element = $0 else { throw PyStandardException.indexError }
//            return try Element.casted(from: element)
//        }//(Element.init)
//        
//    }
//    
//    public static func casted(from object: PyPointer) throws -> Self {
//        guard
//            PyObject_TypeCheck(object, .PyList)
//        else { throw PyStandardException.typeError }
//                
//        return try object.map { element in
//            if let element {
//                try Element.casted(from: element)
//            } else {
//                throw PyStandardException.typeError
//            }
//        }
//
//    }
}

extension PyPointer {
    @inlinable public func append<T: PySerialize>(_ value: T) {
		let element = value.pyPointer
		PyList_Append(self, element)
		Py_DecRef(element)
	}
	@inlinable public func append(_ value: PyPointer) { PyList_Append(self, value) }
//    @inlinable public func append<T: PySerialize>(contentsOf: [T]) {
//		for value in contentsOf { PyList_Append(self, value.pyPointer) }
//	}
	
	@inlinable public func append(contentsOf: [PyPointer]) {
		for value in contentsOf { PyList_Append(self, value) }
	}
    
    @inlinable public func append<C>(contentsOf newElements: C) where C : Collection, C.Element: PySerialize {
        for element in newElements {
            let object = element.pyPointer
            PyList_Append(self, object)
            Py_DecRef(object)
        }
    }
	
    @inlinable public func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, C.Element: PySerialize {
		for element in newElements {
            let object = element.pyPointer
			PyList_Insert(self, i, object)
            Py_DecRef(object)
		}
	}
	
	
	
}

extension PyPointer: Swift.Sequence {
	
	public typealias Iterator = PySequenceBuffer.Iterator
    
    public var pySequence: PySequenceBuffer {
        self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
            let o = pointer.pointee
            return PySequenceBuffer(start: o.ob_item, count: o.ob_base.ob_size)
        }
    }
	
	public func makeIterator_old() -> PySequenceBuffer.Iterator {
		let fast_list = PySequence_Fast(self, nil)!
		let buffer = PySequenceBuffer(
			start: PySequence_FastItems(fast_list),
			count: PySequence_FastSize(fast_list)
		)
		
		defer { Py_DecRef(fast_list) }
		return buffer.makeIterator()
	}
	
	public func makeIterator() -> PySequenceBuffer.Iterator {
        pySequence.makeIterator()
	}
	
	@inlinable
    public func pyMap<T>(_ transform: (PyPointer) throws -> T) rethrows -> [T] where T: PyDeserialize {
		try self.withMemoryRebound(to: PyListObject.self, capacity: 1) { pointer in
			let o = pointer.pointee
            return try PySequenceBuffer(start: o.ob_item, count: o.ob_base.ob_size).map { element in
				guard let element = element else { throw PythonError.sequence }
				return try transform(element)
			}
		}
	}
}

extension PyPointer {
	
	@inlinable
    public subscript<R: PySerialize & PyDeserialize>(index: Int) -> R? {
		
		get {
			if PyList_Check(self) {
				if let element = PyList_GetItem(self, index) {
					return try? R(object: element)
				}
				return nil
			}
			if PyTuple_Check(self) {
                if let element = Python.PyTuple_GetItem(self, index) {
					return try? R(object: element)
				}
				return nil
			}
			return nil
		}
		
		set {
			if PyList_Check(self) {
				if let newValue = newValue {
					PyList_SetItem(self, index, newValue.pyPointer)
					return
				}
				PyList_SetItem(self, index, .None)
				return
			}
			if PyTuple_Check(self) {
				if let newValue = newValue {
					PyTuple_SetItem(self, index, newValue.pyPointer)
					return
				}
				PyTuple_SetItem(self, index, .None)
				return
			}
		}
	}
	
}

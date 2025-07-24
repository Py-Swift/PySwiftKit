import Foundation
import PythonCore


extension PythonObject : PyEncodable {
	
	
	public var pyPointer: PyPointer {
		ptr ?? .None
	}
	
	
}

public class PythonPointerAutoRelease {
    let ptr: PythonPointer?
    private let keep: Bool
    let createdOn = Date()
    
    public init(pointer: PythonPointer?, keep: Bool = true) {
        self.ptr = pointer
        self.keep = keep
        if keep {
            Py_IncRef(pointer)
        }
    }
    
    public init(from_getattr pointer: PythonPointer?) {
        ptr = pointer
        self.keep = true
    }
    
    deinit {
        if keep {
//            let dateFormatter_ = DateFormatter()
//            dateFormatter_.locale = Locale(identifier: "en_DK")
//            dateFormatter_.setLocalizedDateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ssZZZZZ")
//            print(dateFormatter_.string(from: Date()))
            Py_DecRef(ptr)
//            let dateFormatter = DateFormatter()
//            dateFormatter.locale = Locale(identifier: "en_DK")
//            dateFormatter.setLocalizedDateFormatFromTemplate("'T'HH:mm:ssZZZZZ")
//            print("PythonPointerAutoRelease ref count:",ptr ?? "nil", ptr?.pointee.ob_refcnt ?? "ref nil", dateFormatter.string(from: createdOn))
            //print("deinit \(ptr!) ref count is now \(ptr!.pointee.ob_refcnt)")
        }
    }
}



public class PythonObjectSlim {
    public let ptr: PythonPointer
    
    
    public init(pointer: PythonPointer?) {
        ptr = pointer!
        Py_IncRef(ptr)
    }
    
    deinit {
        Py_DecRef(ptr)
    }
    
    
}

public protocol PythonConvertible {
    /// A `PythonObject` instance representing this value.
    var pythonObject: PythonObject { get }
}

@dynamicMemberLookup
@dynamicCallable
public struct PythonObject: ConvertibleFromPython {
  
    public let ptr: PythonPointer
    public let object_autorelease: PythonPointerAutoRelease
    
    private var _iter: PySequenceBuffer.Iterator? = nil
    public var iter: PySequenceBuffer.Iterator?
    //private var iter_count: Int = 0
    
    
    
    
    public init(ptr: PythonPointer, keep_alive: Bool = false, from_getter: Bool = false) {
        //print("initing PythonObject",ptr as Any, ptr!.pointee.ob_refcnt)
        self.ptr = ptr
        if from_getter {
            self.object_autorelease = PythonPointerAutoRelease(from_getattr: ptr)
        } else {
            self.object_autorelease = PythonPointerAutoRelease(pointer: ptr, keep: keep_alive)
        }
        
        
    }
    //func dynamicallyCall(
    public init(object: PyPointer) throws {
        self = .init(getter: object)
    }
    
    public init(getter ptr: PythonPointer) {
        self.ptr = ptr
        object_autorelease = .init(from_getattr: ptr)
    }
    
    public func IncRef() {
        Py_IncRef(ptr)
    }
    
    public func DecRef() {
        Py_DecRef(ptr)
    }
    
    public var xINCREF: PyPointer {
        Py_IncRef(ptr)
        return ptr ?? .None
    }
    public var xDECREF: PyPointer {
        Py_DecRef(ptr)
        return ptr ?? .None
    }
    
    var module_dict: PythonObject { .init(ptr: PyModule_GetDict(ptr), from_getter: true) }
    
    
    
//    @inlinable public subscript(dynamicMember member: String) -> PythonPointer {
//        get {
//            //guard PyObject_HasAttrString(ptr, member) == 1 else { return nil }
//            let obj: PythonPointer = member.withCString { key in
//                PyObject_GetAttrString(ptr, key)
//            }
//            //let obj: PythonPointer = PyObject_GetAttrString(ptr, member)
//            Py_DecRef(ptr)
//            return obj
//        }
//        set {
//            let state =  member.withCString({ key -> Int32 in PyObject_SetAttrString(ptr, key, newValue) })
//            if state == 0 {
//                PyErr_Print()
//            }
//        }
//    }
//    public func test(_ args: KeyValuePairs<String, PyPointer>) {
//        
//    }
    
    
    @inlinable public subscript(dynamicMember member: String) -> PythonObject {
        get {
            let obj: PythonPointer = member.withCString { key in
                PyObject_GetAttrString(ptr, key)
            }
            return .init(getter: obj)
        }
        set {
            let state =  member.withCString({ key -> Int32 in PyObject_SetAttrString(ptr, key, newValue.ptr) })
            if state == 0 {
                PyErr_Print()
            }
        }
    }
//    
//    @inlinable public subscript(dynamicMember member: String) -> String {
//        get {
//            ptr.string ?? ""
//        }
//        set {
//            let obj = newValue.pyStringUTF8
//            PyObject_SetAttrString(ptr, member, obj)
//            obj.decref()
//        }
//    }
//    
//  
//    
//    @inlinable public subscript(dynamicMember member: String) -> Int {
//        get {
//            let obj = PyObject_GetAttrString(ptr, member)
//            Py_DecRef(obj)
//            return PyLong_AsLong(obj)
//        }
//        set {
//            let obj = PyLong_FromLong(newValue)
//            PyObject_SetAttrString(ptr, member, obj)
//            Py_DecRef(obj)
//        }
//    }

    
//    @inlinable public subscript(dynamicMember member: PythonPointer) -> PythonPointer {
//        get {
//            PyObject_GetAttr(ptr, member)
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue)
//        }
//    }
    
//    @inlinable public subscript(dynamicMember member: PythonPointer) -> PythonPointer? {
//        get {
//            PyObject_GetAttr(ptr, member)
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonPointer?) -> PythonPointer {
//        get {
//            PyObject_GetAttr(ptr, member)
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonPointer?) -> PythonPointer? {
//        get {
//            PyObject_GetAttr(ptr, member)
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonObject) -> PythonPointer {
//        get {
//            PyObject_GetAttr(ptr, member.ptr)
//        }
//        set {
//            PyObject_SetAttr(ptr, member.ptr, newValue)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonObject) -> PythonPointer? {
//        get {
//            PyObject_GetAttr(ptr, member.ptr)
//        }
//        set {
//            PyObject_SetAttr(ptr, member.ptr, newValue)
//        }
//    }
    
//    @inlinable public subscript(dynamicMember member: PythonObject) -> PythonObject {
//        get {
//            PythonObject(ptr: PyObject_GetAttr(ptr, member.ptr))
//        }
//        set {
//            PyObject_SetAttr(ptr, member.ptr, newValue.ptr)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonPointer) -> PythonObject {
//        get {
//            PythonObject(ptr: PyObject_GetAttr(ptr, member))
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue.ptr)
//        }
//    }
//
//    @inlinable public subscript(dynamicMember member: PythonPointer?) -> PythonObject {
//        get {
//            PythonObject(ptr: PyObject_GetAttr(ptr, member))
//        }
//        set {
//            PyObject_SetAttr(ptr, member, newValue.ptr)
//        }
//    }
}



extension String {
    
    @inlinable public var pyBytes: PythonObject {
        .init(getter: withCString(PyBytes_FromString)!)
    }
    @inlinable public var pyUnicode: PythonObject {
        .init(getter: withCString(PyUnicode_FromString)!)
    }
    
}

extension PythonObject {
    
    static public var None: PythonObject {
        .init(getter: .None)
    }
    
    @inlinable public var ref_count: Int { ptr.pointee.ob_refcnt }
    
    @inlinable public var int: Int { PyLong_AsLong(ptr) }
    @inlinable public var uint: UInt { PyLong_AsUnsignedLong(ptr)}
    @inlinable public var int32: Int32 { Int32(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var uint32: UInt32 { UInt32(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var int16: Int16 { Int16(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var uint16: UInt16 { UInt16(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var short: Int16 { Int16(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var ushort: UInt16 { UInt16(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var int8: Int8 { Int8(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var uint8: UInt8 { UInt8(clamping: PyLong_AsUnsignedLong(ptr)) }
    @inlinable public var double: Double { PyFloat_AsDouble(ptr) }
    @inlinable public var float: Float { Float(PyFloat_AsDouble(ptr)) }
    //@inlinable public var string: String { String.init(cString: PyUnicode_AsUTF8(ptr)) }
    
    @inlinable public var string: String? {
            
        guard let ptr = PyUnicode_DATA(self.ptr) else { return nil }
            
        let kind = PyUnicode_GetKind(self.ptr)
        let length = PyUnicode_GetLength(self.ptr)
            switch PyUnicode_AsKind(rawValue: kind) {
            case .PyUnicode_WCHAR_KIND:
                return nil
            case .PyUnicode_1BYTE_KIND:
                let size = length * MemoryLayout<Py_UCS1>.stride
                let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
                return String(data: data, encoding: .utf8)
            case .PyUnicode_2BYTE_KIND:
                let size = length * MemoryLayout<Py_UCS2>.stride
                let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
                return String(data: data, encoding: .utf16LittleEndian)
            case .PyUnicode_4BYTE_KIND:
                let size = length * MemoryLayout<Py_UCS4>.stride
                let data = Data(bytesNoCopy: ptr, count: size, deallocator: .none)
                return String(data: data, encoding: .utf32LittleEndian)
            case .none:
                print(".none",kind)
                return nil
            }
        }
    
    
    @inlinable public var iterator: PythonPointer? { PyObject_GetIter(ptr) }
    
    @inlinable public var is_sequence: Bool { PySequence_Check(ptr) == 1 }
    @inlinable public var is_dict: Bool { PyDict_Check(ptr) }
    @inlinable public var is_tuple: Bool { PyTuple_Check(ptr)}
    @inlinable public var is_unicode: Bool { PyUnicode_Check(ptr) }
    @inlinable public var is_int: Bool { PyLong_Check(ptr) }
    @inlinable public var is_float: Bool {PyBool_Check(ptr) }
    @inlinable public var is_iterator: Bool { PyIter_Check(ptr) == 1}
    @inlinable public var is_bytearray: Bool { PyByteArray_Check(ptr) }
    @inlinable public var is_bytes: Bool { PyBytes_Check(ptr) }
    
    @inlinable func decref() {
        Py_DecRef(ptr)
    }
    
    @inlinable
    public __consuming func array() -> [Self] {
        let fast_list = PySequence_Fast(ptr, "")
		let list_count = PySequence_FastSize(fast_list)
		let fast_items = PySequence_FastItems(fast_list)
        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
        var array = [Self]()
        array.reserveCapacity(buffer.count)
        for element in buffer {
            array.append(Self(ptr: element!, keep_alive: true, from_getter: false))
        }
        Py_DecRef(fast_list)
        return array
    }
    
    
}



extension PythonPointer {
    
    
    var object: PythonObject { PythonObject(ptr: self) }
    
    @inlinable
    public __consuming func array() -> [PythonObject] {
        let fast_list = PySequence_Fast(self, "")
        let list_count = PySequence_FastSize(fast_list)
        let fast_items = PySequence_FastItems(fast_list)
        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
        var array = [PythonObject]()
        array.reserveCapacity(buffer.count)
        for element in buffer {
            array.append(PythonObject(ptr: element!, keep_alive: true, from_getter: false))
        }
        Py_DecRef(fast_list)
        return array
    }
    
    @inlinable
    public __consuming func array() -> [PythonObjectSlim] {
        let fast_list = PySequence_Fast(self, "")
		let list_count = PySequence_FastSize(fast_list)
		let fast_items = PySequence_FastItems(fast_list)
        let buffer = UnsafeBufferPointer(start: fast_items, count: list_count)
        var array = [PythonObjectSlim]()
        array.reserveCapacity(buffer.count)
        for element in buffer {
            array.append(PythonObjectSlim(pointer: element))
        }
        Py_DecRef(fast_list)
        return array
    }
    
}


extension PythonObject {
	
	static func ~=(l: PythonObject, r: PyPointer) -> Bool {
		fatalError()
	}
	
	public func IsInstance(_ type: PyPointer) -> Bool {
		PyObject_IsInstance(ptr, type) == 1
	}
	
	public func IsInstance(_ type: PythonObject) -> Bool {
		PyObject_IsInstance(ptr, type.ptr) == 1
	}
	
	public func _print() {
		PyObject_CallOneArg(print_obj, ptr)
	}
	
	public func print_dict() {
		let dict: PythonObject = self.__dict__
		guard dict.ptr != nil else {
			Swift.print("nil")
			return
		}
		PyObject_CallOneArg(print_obj, dict.ptr)
	}
	
	public func print_dir() {
		if let dir = PyObject_Dir(ptr) {
			pyPrint(dir)
			dir.decref()
		}
	}
	public var isNone: Bool {
		ptr == PyNone
	}
	
	static func fromImport(_ module: String,_ name: String) -> PythonObject? {
		pythonImport(from: module, import_name: name)
	}
}


public func pythonImport(from mod: String, import_name: String) -> PythonObject? {
	let module_item_name = "\(mod)_\(import_name)"
	
	if let _import_ = importedModulesItems[module_item_name] {
		return .init(getter: _import_)
	}
	
	var module: PythonPointer?
	var module_item: PythonPointer?
	
	if let _module = importedModules[mod] {
		module = _module
	} else {
		let _module = PyImport_ImportModule(mod)
		module = _module
		print("module imported", _module!)
		importedModules[mod] = _module
	}
	
	guard let module = module else { return nil }
	
	
	if let _module_item = importedModulesItems[module_item_name] {
		module_item = _module_item
	} else {
		let _module_item = PyObject_GetAttrString(module, import_name)
		module_item = _module_item
		importedModulesItems[module_item_name] = _module_item
	}
	
	if let module_item = module_item {
		return .init(getter: module_item)
	}
	return nil
}



extension PythonObject {
	
	@discardableResult
	public func replacePyDictKey(_ key: String, new: String) -> Int32 {
		key.withCString {
			let item = PyDict_GetItemString(ptr, $0)
			_ = PyDict_DelItemString(ptr, $0)
			return new.withCString { PyDict_SetItemString(ptr, $0, item) }
		}
	}
	
	subscript(index: String) -> PyPointer {
		get {
			index.withCString { PyDict_GetItemString(ptr, $0) }
		}
		set(newValue) {
			_ = index.withCString { PyDict_SetItemString(ptr, $0, newValue) }
		}
	}
	
	subscript(index: String) -> String {
		get {
			index.withCString { (try? String(object: PyDict_GetItemString(ptr, $0) )) ?? "<Null>" }
		}
		set(newValue) {
			let item = newValue.withCString(PyUnicode_FromString)
			_ = index.withCString { PyDict_SetItemString(ptr, $0, item) }
		}
	}
}

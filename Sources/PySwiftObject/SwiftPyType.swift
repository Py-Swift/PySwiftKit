//import Foundation
//import CPythonSwiftCore
//
//import CPython
//import _PySwiftObject
//
//public struct PyTypeFunctions {
//    
//    let tp_init: initproc!
//    let tp_new: newfunc!
//    let tp_dealloc: destructor!
//    let tp_getattr: getattrfunc!
//    let tp_setattr: setattrfunc!
//    //let tp_as_number: UnsafeMutablePointer<PyNumberMethods>!
//    //let tp_as_sequence: UnsafeMutablePointer<PySequenceMethods>!
//    let tp_call: ternaryfunc!
//
//    let tp_str: PySwift_ReprFunc!
//    let tp_repr: PySwift_ReprFunc!
//    let tp_hash: PySwift_HashFunc!
//    
//    public init(
//        tp_init: initproc? = nil,
//        tp_new: newfunc? = nil,
//        tp_dealloc: destructor? = nil,
//        tp_getattr: getattrfunc? = nil,
//        tp_setattr: setattrfunc? = nil,
//        //tp_as_number: UnsafeMutablePointer<PyNumberMethods>? = nil,
//        //tp_as_sequence: UnsafeMutablePointer<PySequenceMethods>? = nil,
//        tp_call: ternaryfunc? = nil,
//
//        tp_str: PySwift_ReprFunc? = nil,
//        tp_repr: PySwift_ReprFunc? = nil,
//        tp_hash: PySwift_HashFunc? = nil) {
//
//            self.tp_init = tp_init
//            self.tp_new = tp_new
//            self.tp_dealloc = tp_dealloc
//            self.tp_getattr = tp_getattr
//            self.tp_setattr = tp_setattr
//            //self.tp_as_number = tp_as_number
//            //self.tp_as_sequence = tp_as_sequence
//            self.tp_call = tp_call
//            self.tp_str = tp_str
//            self.tp_repr = tp_repr
//            self.tp_hash = tp_hash
//    }
//
//}
//
//struct SomeSwiftPyType {
//	var get_sets: [PyGetSetDef]?
//	
//	
//	init(get_sets: [PyGetSetDef]) {
//		self.get_sets = get_sets + [.init()]
//		
//		
//	}
//}
//
//public final class SwiftPyType {
//    
//    public struct TpFlag: RawRepresentable {
//        public init?(rawValue: UInt) {
//            self.rawValue = rawValue
//        }
//        
//        public var rawValue: UInt
//        
//        public typealias RawValue = UInt
//        
//        static func |(lhs: Self, rhs: Self) -> Self {
//            .init(rawValue: lhs.rawValue | rhs.rawValue)!
//        }
//#if BEEWARE
//        static public let DEFAULT = TpFlag(rawValue: UInt(Py_TPFLAGS_DEFAULT))!
//#else
//        static public let DEFAULT = TpFlag(rawValue: UInt(Py_TPFLAGS_DEFAULT))!
//#endif
//        
//        static let BASE = TpFlag(rawValue: Py_TPFLAGS_BASETYPE)!
//        static let GC = TpFlag(rawValue: Py_TPFLAGS_HAVE_GC)!
//        static let DEFAULT_BASE = DEFAULT | BASE
//        static let DEFAULT_BASE_GC = DEFAULT_BASE | GC
//    }
//    
//    let tp_name: UnsafePointer<CChar>!
//    public let pytype: UnsafeMutablePointer<PyTypeObject>
//    
//    let methods: PyMethodDefHandler?
//    let getsets: PyGetSetDefHandler?
//    let funcs: PyTypeFunctions
//    //let sequence: PySequenceMethodsHandler?
//    let buffer: PyBufferProcsHandler?
//	let mapping: PyMappingMethodsWrap?
//    
//    public init(
//        name: String, functions: PyTypeFunctions,
//        methods: PyMethodDefHandler?,
//        getsets: PyGetSetDefHandler?,
//        //sequence: PySequenceMethodsHandler? = nil,
//		mapping: PyMappingMethodsWrap? = nil,
//        buffer: PyBufferProcsHandler? = nil,
//        module_target: PythonPointer? = nil) {
//            //PyErr_Print()
//            print("SwiftPyType:", name)
//            self.tp_name = makeCString(from: name)
//            self.methods = methods
//            self.getsets = getsets
//            self.funcs = functions
//            //self.sequence = sequence
//			self.mapping = mapping
//            self.buffer = buffer
//            pytype = .allocate(capacity: 1)
//            
//            createPyType()
//            
//            //#if os(OSX)
//            //PyModule_AddType(python_handler.python_module, pytype)
//            //#endif
//        }
//    
//	public init(name: String, functions: PyTypeFunctions, methods: PyMethodDefHandler?, getsets: PyGetSetDefHandler?, module_target: PythonPointer ) {
//		self.tp_name = makeCString(from: name)
//		self.methods = methods
//		self.getsets = getsets
//		self.funcs = functions
//		//self.sequence = nil
//		self.mapping = nil
//		self.buffer = nil
//		pytype = .allocate(capacity: 1)
//		createPyType()
//		
//	}
//	
//    
//    
//    func createPyType(_ flag: TpFlag = .DEFAULT_BASE) {
//        var py_type = NewPyType(nil)
//        
//        py_type.tp_name = tp_name
//        py_type.tp_basicsize = MemoryLayout.size(ofValue: _object.self)
//        
//        if let methods = methods {
//            py_type.tp_methods = methods.methods_ptr
//        }
//        if let getsets = getsets {
//
//            py_type.tp_getset = getsets.getsets_ptr
//        }
//        
////        if let sequence = sequence {
////            py_type.tp_as_sequence = sequence.methods
////        }
//        
//        if let buffer = buffer {
//            py_type.tp_as_buffer = buffer.buffer_ptr
//        }
//		
//		if let mapping = mapping {
//			py_type.tp_as_mapping = mapping.methods
//		}
//		
//        //py_type.tp_members = members
//        py_type.tp_flags =  flag.rawValue
//        
//        py_type.tp_new = funcs.tp_new
//        py_type.tp_init = funcs.tp_init
//        
//        py_type.tp_repr = unsafeBitCast(funcs.tp_repr, to: reprfunc.self)
//        py_type.tp_str = unsafeBitCast(funcs.tp_str, to: reprfunc.self)
//        //py_type.tp_vectorcall = nil
//        //        py_type.tp_vectorcall = {s, a, n, k  in
//        //            print("tp_vectorcall")
//        //            pyPrint(s)
//        //            pyPrint(a![0])
//        //
//        //            return returnPyNone()
//        //        }
//        //py_type.tp_vectorcall_offset = -1
//        //py_type.tp_alloc = NewPyObject_Alloc
//        py_type.tp_basicsize = PySwiftObject_size
//        py_type.tp_dictoffset = PySwiftObject_dict_offset
//        py_type.tp_dealloc = funcs.tp_dealloc
//        py_type.tp_call = funcs.tp_call
//        py_type.tp_getattr = funcs.tp_getattr
//        py_type.tp_setattr = funcs.tp_setattr
//        
//        py_type.tp_hash = unsafeBitCast(funcs.tp_hash, to: hashfunc.self)
//        
//        py_type.tp_getattro = PyObject_GenericGetAttr
//        py_type.tp_setattro = PyObject_GenericSetAttr
//        
////		py_type.tp_as_mapping.pointee = .init(
////			mp_length: PySwift__len__,
////			mp_subscript: PySwift__getitem__,
////			mp_ass_subscript: PySwift__setitem__
////		)
//		
//		
//        
//        pytype.pointee = py_type
//        
//        if PyType_Ready(pytype) < 0 {
//            PyErr_Print()
//            fatalError("PyReady failed")
//        }
//        
//    }
//    
//    deinit {
//        tp_name.deallocate()
//        pytype.deallocate()
//    }
//}
//
//
//fileprivate class TestPyTarget: PyMutableMappingProtocol {
//	func __getitem__(_ key: PythonCore.PyPointer?) -> PythonCore.PyPointer? {
//		nil
//	}
//	
//	func __setitem__(_ key: PythonCore.PyPointer?, _ item: PythonCore.PyPointer?) -> PythonCore.PyPointer? {
//		nil
//	}
//	
//	func __len__() -> Int {
//		0
//	}
//	
//	func __getitem__(key: String) -> PythonCore.PyPointer? {
//		nil
//	}
//	
//	func __setitem__(key: String, value: PythonCore.PyPointer) -> Int32 {
//		0
//	}
//	
//	func __delitem__(key: String) -> Int32 {
//		0
//	}
//}
//
//
//fileprivate func pytype_test() {
//	
////	let settest: PySwift__msetitem__ = { __self__, key, value in
////		guard let __self__ = __self__, let key = key else { return 1 }
////		do {
////			let cls = try UnPackPySwiftObject(with: __self__, as: TestPyTarget.self)
////			let key = try String(object: key)
////			return cls.__setitem__(key: key, value: value)
////		}
////		catch _ {
////			PyErr_Print()
////		}
////		return 0
////	}
////	let getTest: PySwift__mgetitem__ = { __self__, key in
////		guard let __self__ = __self__, let key = key else { return .None }
////		do {
////			let cls = try UnPackPySwiftObject(with: __self__, as: TestPyTarget.self)
////			let key = try String(object: key)
////			return cls.__getitem__(key: key)
////		}
////		catch _ {
////			PyErr_Print()
////		}
////		return .None
////	}
//}

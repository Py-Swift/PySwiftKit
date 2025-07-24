//
//import Foundation
//import PythonCoreSwiftCore
//
//import PythonCore
//
//public final class PyGetSetDefWrap {
//    let name: UnsafePointer<CChar>
//    let doc_string: UnsafePointer<CChar>!
//    let getset: PyGetSetDef
//    
//    public init(name: String, doc: String? = nil, getter: PyGetter) {
//        let _name: UnsafePointer<CChar> = .init(makeCString(from: name))
//        self.name = _name
//        var _doc_string: UnsafePointer<CChar>!
//        if let doc = doc {
//            _doc_string = .init(makeCString(from: doc))
//            
//        }
//        doc_string = _doc_string
//        getset = .init(name: _name, get: getter, set: nil, doc: _doc_string, closure: nil)
//    }
//    
//    public init(name: String, doc: String? = nil, getter: PyGetter, setter: PySetter) {
//        let _name: UnsafePointer<CChar> = .init(makeCString(from: name))
//        self.name = _name
//        var _doc_string: UnsafePointer<CChar>!
//        if let doc = doc {
//            _doc_string = .init(makeCString(from: doc))
//            
//        }
//        doc_string = _doc_string
//        getset = .init(name: _name, get: getter, set: setter, doc: _doc_string, closure: nil)
//    }
//    // self: PySwiftObjectPointer
//    public init(pySwift name: String, doc: String? = nil, getter: PySwiftGetter) {
//        let _name: UnsafePointer<CChar> = .init(makeCString(from: name))
//        self.name = _name
//        var _doc_string: UnsafePointer<CChar>!
//        if let doc = doc {
//            _doc_string = .init(makeCString(from: doc))
//            
//        }
//        doc_string = _doc_string
//        getset = .init(name: _name, get: unsafeBitCast(getter, to: PyGetter.self), set: nil, doc: _doc_string, closure: nil)
//    }
//    
//    public init(pySwift name: String, doc: String? = nil, getter: PySwiftGetter, setter: PySwiftSetter) {
//        let _name: UnsafePointer<CChar> = .init(makeCString(from: name))
//        self.name = _name
//        var _doc_string: UnsafePointer<CChar>!
//        if let doc = doc {
//            _doc_string = .init(makeCString(from: doc))
//            
//        }
//        doc_string = _doc_string
//        getset = .init(name: _name, get: unsafeBitCast(getter, to: PyGetter.self), set: unsafeBitCast(setter, to: PySetter.self), doc: _doc_string, closure: nil)
//    }
//    
//    deinit {
//        name.deallocate()
//        guard doc_string != nil else { return }
//        doc_string.deallocate()
//    }
//}
//
//public final class PyGetSetDefHandler {
//    
//    let getsets_ptr: UnsafeMutablePointer<PyGetSetDef>
//    var getsets_container: [PyGetSetDefWrap]
//    
//    public init(getsets: [PyGetSetDefWrap]) {
//        
//        getsets_container = getsets
//        let count = getsets.count
//        getsets_ptr = .allocate(capacity: count + 1)
//        for (i, prop) in getsets.enumerated() {
//            getsets_ptr[i] = prop.getset
//        }
//        getsets_ptr[count] = .init()
//    }
//    
//    public init(_ getsets: PyGetSetDefWrap...) {
//        
//        getsets_container = getsets
//        let count = getsets.count
//        getsets_ptr = .allocate(capacity: count + 1)
//        for (i, prop) in getsets.enumerated() {
//            getsets_ptr[i] = prop.getset
//        }
//        getsets_ptr[count] = .init()
//    }
//    
//    deinit {
//        getsets_ptr.deallocate()
//    }
//}

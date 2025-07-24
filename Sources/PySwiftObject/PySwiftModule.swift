//import Foundation
//import PythonCoreSwiftCore
//
//import PythonCore
//import _PySwiftObject
//
////fileprivate var py_mod = PyModuleDef(
////    m_base: PythonModuleDef_HEAD_INIT,
////    m_name: "",
////    m_doc: nil,
////    m_size: -1,
////    m_methods: nil,
////    m_slots: nil,
////    m_traverse: nil,
////    m_clear: nil,
////    m_free: nil
////)
//
//public class PyModuleDefHandler {
//    
//    public let name: UnsafePointer<CChar>
//    
//    public let module: UnsafeMutablePointer<PyModuleDef>!
//    
//    private let methods: PyMethodDefHandler?
//    
//    public init(name: String, methods: PyMethodDefHandler?) {
//        self.name = makeCString(from: name)
//        self.methods = methods
//        module = .allocate(capacity: 1)
//        module.pointee = PyModuleDef(
//            m_base: _PyModuleDef_HEAD_INIT,
//            m_name: self.name,
//            m_doc: nil,
//            m_size: -1,
//            m_methods: self.methods?.methods_ptr,
//            m_slots: nil,
//            m_traverse: nil,
//            m_clear: nil,
//            m_free: nil
//        )
//        
//    }
//    
//}
//

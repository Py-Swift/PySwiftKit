//
//import Foundation
//import PythonCoreSwiftCore
//
//import PythonCore
//
//
//
//public class PySequenceMethodWrap {
//    
//    
//    
//    let length: PySequence_Length_func
//    let concat: PySequence_Concat_func
//    let repeat_: PySequence_Repeat_func
//    let get_item: PySequence_Item_func
//    let set_item: PySequence_Ass_Item_func
//    let contains: PySequence_Contains_func
//    let inplace_concat: PySequence_Inplace_Concat_func
//    let inplace_repeat: PySequence_Inplace_Repeat_func
//    
//    public init(length: PySequence_Length_func = nil, concat: PySequence_Concat_func = nil, repeat_: PySequence_Repeat_func = nil, get_item: PySwiftSequence_Item_func = nil, set_item: PySequence_Ass_Item_func = nil, contains: PySequence_Contains_func = nil, inplace_concat: PySequence_Inplace_Concat_func = nil, inplace_repeat: PySequence_Inplace_Repeat_func = nil) {
//        self.length = length
//        self.concat = concat
//        self.repeat_ = repeat_
//        self.get_item = unsafeBitCast(get_item, to: PySequence_Item_func.self)
//        self.set_item = set_item
//        self.contains = contains
//        self.inplace_concat = inplace_concat
//        self.inplace_repeat = inplace_repeat
//    }
//}
//
////
////public class PySequenceMethodsHandler {
////    
////    public let methods: UnsafeMutablePointer<PySequenceMethods>!
////    let methods_container: PySequenceMethodWrap!
////    
////    public init(methods: PySequenceMethodWrap!) {
////        
////        if methods != nil  {
////            self.methods_container = methods
////            self.methods = .allocate(capacity: 1)
////            self.methods.initialize(to: .init(sq_length: methods.length, sq_concat: methods.concat, sq_repeat: methods.repeat_, sq_item: methods.get_item, was_sq_slice: nil, sq_ass_item: methods.set_item, was_sq_ass_slice: nil, sq_contains: methods.contains, sq_inplace_concat: methods.inplace_concat, sq_inplace_repeat: methods.inplace_repeat))
////        } else {
////            self.methods = nil
////            self.methods_container = nil
////        }
////        
////    }
////    
////}

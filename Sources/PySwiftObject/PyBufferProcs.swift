

import Foundation
//import PythonSwiftCore
//import PythonTypeAlias
import PySwiftKit
import PythonCore

public class PyBufferProcsHandler {
    
    let buffer_ptr: UnsafeMutablePointer<PyBufferProcs>
    
    init(getBuffer: PyBuf_Get, releaseBuffer: PyBuf_Release) {
        
        buffer_ptr = .allocate(capacity: 1)
        
        buffer_ptr.pointee = .init(
            bf_getbuffer: getBuffer,
            bf_releasebuffer: releaseBuffer
        )
        
    }
    
    public init(_getBuffer: PySwiftBuf_Get, _releaseBuffer: PySwiftBuf_Release) {
        
        buffer_ptr = .allocate(capacity: 1)
        
        buffer_ptr.pointee = .init(
            bf_getbuffer: unsafeBitCast(_getBuffer, to: PyBuf_Get.self),
            bf_releasebuffer: unsafeBitCast(_releaseBuffer, to: PyBuf_Release.self)
        )
        
    }
    
}

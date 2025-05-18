//
//  PyModuleDef.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 03/05/2025.
//

import PythonCore


public extension PyModuleDef_Base {
    static var HEAD_INIT: Self {
        .init(
            ob_base: .init(),
            m_init: nil,
            m_index: 0,
            m_copy: nil
        )
    }
}


public extension PyModuleDef {
    static func new(
        base: PyModuleDef_Base = .HEAD_INIT,
        name: String,
        doc: String? = nil,
        size: Int = -1,
        methods: UnsafeMutablePointer<PyMethodDef>? = nil
    ) -> Self {
        let _doc: UnsafePointer<CChar>? = if let doc {
            cString(doc)
        } else { nil }
        
        return .init(
            m_base: base,
            m_name: cString(name),
            m_doc: _doc,
            m_size: size,
            m_methods: methods,
            m_slots: nil,
            m_traverse: nil,
            m_clear: nil,
            m_free: nil
        )
    }
}





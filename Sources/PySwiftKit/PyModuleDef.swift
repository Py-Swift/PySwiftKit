//
//  PyModuleDef.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 03/05/2025.
//

import CPython

public extension PyObject {
    /// Swift equivalent of CPython's `PyObject_HEAD_INIT(NULL)` for statically-allocated objects.
    /// Since 3.12 these are immortal, so `ob_refcnt` is `_Py_IMMORTAL_REFCNT`
    /// (== `UINT_MAX` on 64-bit, GIL-enabled builds) rather than 0.
    static var HEAD_INIT: Self {
        var base = PyObject()
        base.ob_refcnt = Py_ssize_t(UInt32.max)  // _Py_IMMORTAL_REFCNT
        base.ob_type = nil
        return base
    }
}

public extension PyModuleDef_Base {
    /// Swift equivalent of the `PyModuleDef_HEAD_INIT` macro (can't use the C macro from Swift).
    static var HEAD_INIT: Self {
        .init(
            ob_base: .HEAD_INIT,
            m_init: nil,
            m_index: 0,
            m_copy: nil
        )
    }
}

func emptyPackagePath(_ module: PyPointer?) -> Int32 {
    "__path__".withCString { path in
        let emptyPaths = PyList_New(0)!
        PyObject_SetAttrString(module, path, emptyPaths)
        emptyPaths.decRef()
    }
    
    return 0
}

public extension PyModuleDef {
    
    static var emptyPackagePath: inquiry = { module in
        "__path__".withCString { path in
            let emptyPaths = PyList_New(0)!
            PyObject_SetAttrString(module, path, emptyPaths)
            emptyPaths.decRef()
        }
        
        return 0
    }
    
    static var baseSlots: [PyModuleDef_Slot] = [
        .init(slot: Py_mod_exec, value: unsafeBitCast(emptyPackagePath, to: UnsafeMutableRawPointer.self)),
        .init()
    ]
    
    static func new(
        base: PyModuleDef_Base = .HEAD_INIT,
        name: String,
        doc: String? = nil,
        // multi-phase init (m_slots is always set below) requires m_size >= 0;
        // -1 is only valid for single-phase modules. 0 == no per-module state.
        size: Int = 0,
        methods: UnsafeMutablePointer<PyMethodDef>? = nil,
        // Per-module slots for multi-phase init. When nil, fall back to the shared
        // `baseSlots` (which only wires up the package `__path__` exec slot).
        slots: UnsafeMutablePointer<PyModuleDef_Slot>? = nil
    ) -> Self {
        let _doc: UnsafePointer<CChar>? = if let doc {
            cString(doc)
        } else { nil }

        if let slots {
            return .init(
                m_base: base,
                m_name: cString(name),
                m_doc: _doc,
                m_size: size,
                m_methods: methods,
                m_slots: slots,
                m_traverse: nil,
                m_clear: nil,
                m_free: nil
            )
        }
        return .init(
            m_base: base,
            m_name: cString(name),
            m_doc: _doc,
            m_size: -1,
            m_methods: methods,
            m_slots: nil,//&baseSlots,
            m_traverse: nil,
            m_clear: nil,
            m_free: nil
        )
    }
    
    
}


import PyWrapperInfo



extension PyModuleProtocol {
    #if !PIP_MODE
    public static func addToImports() {
        
        print("addToImports", py_name)
        PyImport_AppendInittab(makeCString(from: py_name), py_init)
        
        for module in modules {
            module.addToImports()
        }
        
    }
    #endif
}

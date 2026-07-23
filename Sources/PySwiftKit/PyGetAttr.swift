//
//  PyGetAttr.swift
//  PySwiftKit
//
import CPython


// Optional hooks: check existence first rather than fetch-and-swallow —
// most apps won't define most of these, and that's the normal case,
// not an error worth routing through Python's exception machinery.
extension PyPointer {
    public func optionalAttr(_ key: String) -> PyPointer? {
        key.withCString { cKey in
            let pyKey = PyUnicode_FromString(cKey)
            defer { Py_DecRef(pyKey) }
            return (PyObject_HasAttr(self, pyKey) == 1) ? PyObject_GetAttr(self, pyKey) : nil
        }
    }
}

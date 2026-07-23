// Optional hooks: check existence first rather than fetch-and-swallow —
// most apps won't define most of these, and that's the normal case,
// not an error worth routing through Python's exception machinery.
extension PyPointer {
    func optionalAttr(_ key: String) -> PyPointer? {
        PyObject_HasAttr(self, key) ? try? PyObject_GetAttr(self, key: key) : nil
    }
}
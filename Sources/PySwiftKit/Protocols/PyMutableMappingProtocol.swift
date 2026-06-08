public protocol PyMutableMappingProtocol: PyMappingProtocol {
	func __setitem__(_ key: PyPointer, _ item: PyPointer?) -> Int32
    func __setitem__(_ key: PyPointer, _ item: PyPointer) -> Int32
    func __delitem__(_ key: PyPointer) -> Int32
//	func __getitem__(key: String) -> PyPointer?
//	func __setitem__(key: String, value: PyPointer) -> Int32
//	func __delitem__(key: String) -> Int32
}
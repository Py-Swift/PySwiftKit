public protocol PyIteratorProtocol {
    func __iter__(__self__: PyPointer) -> PyPointer?
    func __next__() -> PyPointer?
}
public protocol PyHashable {
    func __hash__() -> Int
}
//
//  PySerialize+FloatingPoint.swift
//  PySwiftKit
//
import CPython
import PySwiftKit

extension PySerialize where Self: BinaryFloatingPoint {
    public func pyPointer() -> PyPointer {
        PyFloat_FromDouble(Double(self))
    }
}


extension Double: PySerialize {
    public func pyPointer() -> PyPointer {
        PyFloat_FromDouble(self)
    }
}

extension Float: PySerialize {}
//extension Float80: PySerialize {}

#if (os(macOS) && arch(arm64)) || os(iOS)
@available(iOS 16,macOS 11, *)
extension Float16: PySerialize {}
#endif

#if os(macOS) || os(iOS)
import CoreFoundation
extension CGFloat: PySerialize {
    public func pyPointer() -> PyPointer {
        PyFloat_FromDouble(self)
    }
}
#else
// CGFloat isn't Foundation's on Linux/Android — alias it to Double, which
// already conforms above, so no separate extension is needed here.
fileprivate typealias CGFloat = Double
#endif

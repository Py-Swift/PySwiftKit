//
//  PySerializeEnum.swift
//  PySwiftKit
//
import PySwiftKit


public enum PySerializeEnum {
    case pyLong(Int)
    case pyUnicode(String)
    case pyFloat(Double)
    case pyList(PySequenceBuffer)
}

extension PyPointer {
    public func serializeEnum() -> PySerializeEnum? {
        switch self {
            case .PyLong:
                return .pyLong(PyLong_AsLong(self))
            case .PyFloat:
                return .pyFloat(PyFloat_AS_DOUBLE(self))
            case .PyUnicode:
                return .pyUnicode(.init(cString: PyUnicode_AsUTF8(self)))
            default: break
                
        }
        return nil
    }
}

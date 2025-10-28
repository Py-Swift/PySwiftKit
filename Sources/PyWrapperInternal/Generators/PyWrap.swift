//
//  PyWrap.swift
//  PySwiftKit
//
import SwiftSyntax
import SwiftSyntaxBuilder

public protocol SwiftTypeProtocol: RawRepresentable where RawValue == StringLiteralType {
    var canThrow: Bool { get }
}

extension SwiftTypeProtocol {
    public init?(typeSyntax: IdentifierTypeSyntax) {
        self.init(rawValue: typeSyntax.name.text)
    }
    
    public init?(typeSyntax: TypeSyntax) {
        self.init(rawValue: typeSyntax.trimmedDescription)
    }
}

public struct PyWrap {
    
    public enum IntegerType: String, SwiftTypeProtocol {
        case Int
        case UInt
        case Int32
        case UInt32
        case Int16
        case UInt16
        case Int8
        case UInt8
        
        public var canThrow: Bool { true }
        
    }
    
    public enum FloatingPointType: String, SwiftTypeProtocol{
        case Float
        case Double
        case CGFloat
        case Float32
        case Float16
        
        public var canThrow: Bool { true }
        
        
    }
    
    public enum RawType: String , SwiftTypeProtocol{
        case PyPointer
        case Void
        
        public var canThrow: Bool { false }
        
    }
    
    public enum FoundationType: String, SwiftTypeProtocol {
        case Data
        case Date
        case Calender
        
        public var canThrow: Bool { true }
    }
    
    public enum ObjcType: String, SwiftTypeProtocol {
        case NSObject
        case NSArray
        
        public var canThrow: Bool { true }
    }
    
    public enum SwiftType: String {
        
        
        case Int
        case UInt
        case Int32
        case UInt32
        case Int16
        case UInt16
        case Int8
        case UInt8
        case String
        
        case Float
        case Double
        case Float32
        case Float16
        
        case Data
        case Date
        case Calender
        
        case NSObject
        case NSArray
        case Void
        case PyPointer
        
        public var canThrow: Bool { true }
    }
    
    //    public enum BaseTypes: String {
    //        case Int
    //        case UInt
    //        case Int32
    //        case UInt32
    //        case Int16
    //        case UInt16
    //        case Int8
    //        case UInt8
    //        case String
    //
    //        case Float
    //        case Double
    //        case Float32
    //        case Float16
    //
    //        case Data
    //        case Date
    //        case Calender
    //
    //        case NSObject
    //        case NSArray
    //        case Void
    //        case PyPointer
    //
    //        init?(typeSyntax: TypeSyntax) {
    //            self.init(rawValue: typeSyntax.trimmedDescription)
    //        }
    //
    //
    //    }
    
    
    
}

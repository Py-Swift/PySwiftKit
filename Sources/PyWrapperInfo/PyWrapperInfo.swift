//
//  PyWrapperInfo.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import Foundation

public enum PyClassBase: String, CaseIterable {
    case async
    case sequence
    case mapping
    case buffer
    case number
    case bool
    case int
    case float
    case str
    case repr
    case hash
    
    
}

extension Array where Element == PyClassBase {
    public static var all: Self { PyClassBase.allCases }
}


public enum GILMode {
    case on
    case off
    case automatic
}


public enum ArgumentCast {
    case named(String,ArgumentCastType)
    case index(Int,ArgumentCastType)
}

public enum ArgumentCastType {
    case data(DataType)
    case array(ArrayType)
    case string(StringType)
    case callable(CallableMode)
}

extension ArgumentCastType {
    public enum DataType {
        case buffer
        case memoryview
        case bytes
        case bytearray
    }
    public enum ArrayType {
        
        case standard
        case uint8(UInt8Array)
        
        public enum UInt8Array {
            case buffer
            case memoryview
            case bytes
            case bytearray
        }
    }
    
    public enum StringType {
        case utf8
        case utf16
        case utf32
    }
    
    public enum CallableMode {
        case unlimited
        case once
    }
}

public enum Kwargs: String {
    case kw_only
    case args
    case none
}



//
//  PyDeserialize+Date.swift
//  PySwiftKit
//

import CPython
import PySwiftKit
import Foundation

extension DateComponents: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> DateComponents {
        
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour: Int32 = 0
        var min: Int32 = 0
        var sec: Int32 = 0
        var usec: Int32 = 0
        
        PyDateTime_Info(
            object,
            &year,
            &month,
            &day,
            &hour,
            &min,
            &sec,
            &usec
        )
        return .init(
            year: .init(year),
            month: .init(month),
            day: .init(day),
            hour: .init(hour),
            minute: .init(min),
            second: .init(sec),
            nanosecond: Int(usec) * 1000
        )
    }
    
    public static func casted(unsafe object: PyPointer) throws -> DateComponents {
        var year: Int32 = 0
        var month: Int32 = 0
        var day: Int32 = 0
        var hour: Int32 = 0
        var min: Int32 = 0
        var sec: Int32 = 0
        var usec: Int32 = 0
        
        PyDateTime_Info(
            object,
            &year,
            &month,
            &day,
            &hour,
            &min,
            &sec,
            &usec
        )
        return .init(
            year: .init(year),
            month: .init(month),
            day: .init(day),
            hour: .init(hour),
            minute: .init(min),
            second: .init(sec),
            nanosecond: Int(usec) * 1000
        )
    }
}

extension Date: PyDeserialize {
    public static func casted(from object: PyPointer) throws -> Date {
        switch object {
        case .PyDateTime:
            let calender = Calendar.current
            let components = try DateComponents.casted(unsafe: object)
            return calender.date(from: components)!
        case .PyFloat:
            return .init(timeIntervalSince1970: try Double.casted(unsafe: object))
        case .PyUnicode:
            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(from: try String.casted(unsafe: object)) else {
                throw PyStandardException.unicodeError
            }
            return date
        default: throw PyStandardException.typeError
        }
        
    }
    
    public static func casted(unsafe object: PyPointer) throws -> Date {
        switch object {
        case .PyDateTime:
            let calender = Calendar.current
            let components = try DateComponents.casted(unsafe: object)
            return calender.date(from: components)!
        case .PyFloat:
            return .init(timeIntervalSince1970: try Double.casted(unsafe: object))
        case .PyUnicode:
            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(from: try String.casted(unsafe: object)) else {
                throw PyStandardException.unicodeError
            }
            return date
        default: throw PyStandardException.typeError
        }
        
    }
}

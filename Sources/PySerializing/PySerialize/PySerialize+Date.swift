//
//  PySerialize+Date.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 24/10/2025.
//
import CPython
import PySwiftKit

import Foundation



extension Date: PySerialize {
    
    public func pyPointer() -> PyPointer {
        initPyDateTime()
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        
        let microsecond = if let nanosecond = components.nanosecond {
            nanosecond / 1000
        } else { 0 }
        
        return PyDateTime_Create(
            .init(components.year ?? 0),
            .init(components.month ?? 1),
            .init(components.day ?? 0),
            .init(components.hour ?? 0),
            .init(components.minute ?? 0),
            .init(components.second ?? 0),
            .init(microsecond)
        )
        
    }
}




//extension Date {
//    
//    func test() {
//        let calender = Calendar.current
//        let components = calender.dateComponents([.year, .day, .hour, .minute, .second, .nanosecond], from: self)
//        let microsecond = if let micro = components.nanosecond {
//            micro / 1000
//        } else { 0 }
//        let pydatetime = try! PyDateTime_new(
//            year: components.year ?? 0,
//            month: components.month ?? 0,
//            day: components.day ?? 0,
//            hour: components.hour,
//            minute: components.minute,
//            second: components.second,
//            microsecond: components.nanosecond
//        )
//    }
//}

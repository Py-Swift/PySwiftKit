//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation
import PythonCore
import PySwiftKit
import PySerializing




public struct PyFunction {
    let ptr: PyPointer?
    func callAsFunction() {
        
    }
    func callAsFunction<A>(_ a: A) where A: PySerialize {
        
    }
    func callAsFunction<A, B>(_ a: A, _ b: B) where A: PySerialize, B: PySerialize {
        
    }
}


fileprivate func playground() {
    PyFunction(ptr: nil)()
}

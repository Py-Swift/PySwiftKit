//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/02/2024.
//

import Foundation
import PySwiftKit
import PythonCore

public extension Dictionary where Key == String, Value == PyPointer {
	var pyDict: PyPointer { self.reduce(PyDict_New()!, PyDict_SetItem_ReducedIncRef) }
}

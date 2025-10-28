
//
//  PyDeserialize+URL.swift
//  PySwiftKit
//

import CPython
import PySwiftKit
import Foundation

extension URL: PyDeserialize {
    
    public static func casted(unsafe object: PyPointer) throws -> URL {
        guard let url = URL(string: try .casted(unsafe: object)) else { throw URLError(.badURL) }
        return url
    }
    
    public static func casted(from object: PyPointer) throws -> URL {
        guard let url = URL(string: try .casted(from: object)) else { throw URLError(.badURL) }
        return url
    }
}

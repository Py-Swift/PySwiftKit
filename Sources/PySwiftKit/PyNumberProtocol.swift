
import PythonCore

public protocol PyNumberProtocol {
    func nb_add(_ other: PyPointer) -> PyPointer?
    func nb_subtract(_ other: PyPointer) -> PyPointer?
    func nb_multiply(_ other: PyPointer) -> PyPointer?
    func nb_remainder(_ other: PyPointer) -> PyPointer?
    func nb_divmod(_ other: PyPointer) -> PyPointer?
    func nb_power(_ other: PyPointer, _ kw: PyPointer?) -> PyPointer?
    func nb_negative() -> PyPointer?
    func nb_positive() -> PyPointer?
    func nb_absolute() -> PyPointer?
    func nb_bool() -> Int32
    func nb_invert() -> PyPointer?
    func nb_lshift(_ other: PyPointer) -> PyPointer?
    func nb_rshift(_ other: PyPointer) -> PyPointer?
    func nb_and(_ other: PyPointer) -> PyPointer?
    func nb_xor(_ other: PyPointer) -> PyPointer?
    func nb_or(_ other: PyPointer) -> PyPointer?
    func nb_int() -> PyPointer?
    func nb_float() -> PyPointer?
    func nb_inplace_add(_ other: PyPointer) -> PyPointer?
    func nb_inplace_subtract(_ other: PyPointer) -> PyPointer?
    func nb_inplace_multiply(_ other: PyPointer) -> PyPointer?
    func nb_inplace_remainder(_ other: PyPointer) -> PyPointer?
    func nb_inplace_power(_ other: PyPointer, _ kw: PyPointer?) -> PyPointer?
    func nb_inplace_lshift(_ other: PyPointer) -> PyPointer?
    func nb_inplace_rshift(_ other: PyPointer) -> PyPointer?
    func nb_inplace_and(_ other: PyPointer) -> PyPointer?
    func nb_inplace_xor(_ other: PyPointer) -> PyPointer?
    func nb_inplace_or(_ other: PyPointer) -> PyPointer?
    func nb_floor_divide(_ other: PyPointer) -> PyPointer?
    func nb_true_divide(_ other: PyPointer) -> PyPointer?
    func nb_inplace_floor_divide(_ other: PyPointer) -> PyPointer?
    func nb_inplace_true_divide(_ other: PyPointer) -> PyPointer?
    func nb_index() -> PyPointer?
    func nb_matrix_multiply(_ other: PyPointer) -> PyPointer?
    func nb_inplace_matrix_multiply(_ other: PyPointer) -> PyPointer?
}

public extension PyNumberProtocol {
    func nb_add(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_add not implemented")
    }
    
    func nb_subtract(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_subtract not implemented")
    }
    
    func nb_multiply(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_multiply not implemented")
    }
    
    func nb_remainder(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_remainder not implemented")
    }
    
    func nb_divmod(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_divmod not implemented")
    }
    
    func nb_power(_ other: PyPointer, _ kw: PyPointer?) -> PyPointer? {
        fatalError("\(Self.self).nb_power not implemented")
    }
    
    func nb_negative() -> PyPointer? {
        fatalError("\(Self.self).nb_negative not implemented")
    }
    
    func nb_positive() -> PyPointer? {
        fatalError("\(Self.self).nb_positive not implemented")
    }
    
    func nb_absolute() -> PyPointer? {
        fatalError("\(Self.self).nb_absolute not implemented")
    }
    
    func nb_bool() -> Int32 {
        fatalError("\(Self.self).nb_bool not implemented")
    }
    
    func nb_invert() -> PyPointer? {
        fatalError("\(Self.self).nb_invert not implemented")
    }
    
    func nb_lshift(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_lshift not implemented")
    }
    
    func nb_rshift(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_rshift not implemented")
    }
    
    func nb_and(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_and not implemented")
    }
    
    func nb_xor(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_xor not implemented")
    }
    
    func nb_or(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_or not implemented")
    }
    
    func nb_int() -> PyPointer? {
        fatalError("\(Self.self).nb_int not implemented")
    }
    
    func nb_float() -> PyPointer? {
        fatalError("\(Self.self).nb_float not implemented")
    }
    
    func nb_inplace_add(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_add not implemented")
    }
    
    func nb_inplace_subtract(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_subtract not implemented")
    }
    
    func nb_inplace_multiply(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_multiply not implemented")
    }
    
    func nb_inplace_remainder(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_remainder not implemented")
    }
    
    func nb_inplace_power(_ other: PyPointer, _ kw: PyPointer?) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_power not implemented")
    }
    
    func nb_inplace_lshift(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_lshift not implemented")
    }
    
    func nb_inplace_rshift(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_rshift not implemented")
    }
    
    func nb_inplace_and(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_and not implemented")
    }
    
    func nb_inplace_xor(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_xor not implemented")
    }
    
    func nb_inplace_or(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_or not implemented")
    }
    
    func nb_floor_divide(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_floor_divide not implemented")
    }
    
    func nb_true_divide(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_true_divide not implemented")
    }
    
    func nb_inplace_floor_divide(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_floor_divide not implemented")
    }
    
    func nb_inplace_true_divide(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_true_divide not implemented")
    }
    
    func nb_index() -> PyPointer? {
        fatalError("\(Self.self).nb_index not implemented")
    }
    
    func nb_matrix_multiply(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_matrix_multiply not implemented")
    }
    
    func nb_inplace_matrix_multiply(_ other: PyPointer) -> PyPointer? {
        fatalError("\(Self.self).nb_inplace_matrix_multiply not implemented")
    }
    
    
}

extension PyNumberMethods {
    public static func PySwiftMethods(
        nb_add: PySwift_binaryfunc,
        nb_subtract: PySwift_binaryfunc,
        nb_multiply: PySwift_binaryfunc,
        nb_remainder: PySwift_binaryfunc,
        nb_divmod: PySwift_binaryfunc,
        nb_power: PySwift_ternaryfunc,
        nb_negative: PySwift_unaryfunc,
        nb_positive: PySwift_unaryfunc,
        nb_absolute: PySwift_unaryfunc,
        nb_bool: PySwift_inquiry,
        nb_invert: PySwift_unaryfunc,
        nb_lshift: PySwift_binaryfunc,
        nb_rshift: PySwift_binaryfunc,
        nb_and: PySwift_binaryfunc,
        nb_xor: PySwift_binaryfunc,
        nb_or: PySwift_binaryfunc,
        nb_int: PySwift_unaryfunc,
        nb_reserved: UnsafeMutableRawPointer?,
        nb_float: PySwift_unaryfunc,
        nb_inplace_add: PySwift_binaryfunc,
        nb_inplace_subtract: PySwift_binaryfunc,
        nb_inplace_multiply: PySwift_binaryfunc,
        nb_inplace_remainder: PySwift_binaryfunc,
        nb_inplace_power: PySwift_ternaryfunc,
        nb_inplace_lshift: PySwift_binaryfunc,
        nb_inplace_rshift: PySwift_binaryfunc,
        nb_inplace_and: PySwift_binaryfunc,
        nb_inplace_xor: PySwift_binaryfunc,
        nb_inplace_or: PySwift_binaryfunc,
        nb_floor_divide: PySwift_binaryfunc,
        nb_true_divide: PySwift_binaryfunc,
        nb_inplace_floor_divide: PySwift_binaryfunc,
        nb_inplace_true_divide: PySwift_binaryfunc,
        nb_index: PySwift_unaryfunc,
        nb_matrix_multiply: PySwift_binaryfunc,
        nb_inplace_matrix_multiply: PySwift_binaryfunc
    ) -> Self {
        self.init(
            nb_add: unsafeBitCast(nb_add, to: binaryfunc.self),
            nb_subtract: unsafeBitCast(nb_subtract, to: binaryfunc.self),
            nb_multiply: unsafeBitCast(nb_multiply, to: binaryfunc.self),
            nb_remainder: unsafeBitCast(nb_remainder, to: binaryfunc.self),
            nb_divmod: unsafeBitCast(nb_divmod, to: binaryfunc.self),
            nb_power: unsafeBitCast(nb_power, to: ternaryfunc.self),
            nb_negative: unsafeBitCast(nb_negative, to: unaryfunc.self),
            nb_positive: unsafeBitCast(nb_positive, to: unaryfunc.self),
            nb_absolute: unsafeBitCast(nb_absolute, to: unaryfunc.self),
            nb_bool: unsafeBitCast(nb_bool, to: inquiry.self),
            nb_invert: unsafeBitCast(nb_invert, to: unaryfunc.self),
            nb_lshift: unsafeBitCast(nb_lshift, to: binaryfunc.self),
            nb_rshift: unsafeBitCast(nb_rshift, to: binaryfunc.self),
            nb_and: unsafeBitCast(nb_and, to: binaryfunc.self),
            nb_xor: unsafeBitCast(nb_xor, to: binaryfunc.self),
            nb_or: unsafeBitCast(nb_or, to: binaryfunc.self),
            nb_int: unsafeBitCast(nb_int, to: unaryfunc.self),
            nb_reserved: nb_reserved,
            nb_float: unsafeBitCast(nb_float, to: unaryfunc.self),
            nb_inplace_add: unsafeBitCast(nb_inplace_add, to: binaryfunc.self),
            nb_inplace_subtract: unsafeBitCast(nb_inplace_subtract, to: binaryfunc.self),
            nb_inplace_multiply: unsafeBitCast(nb_inplace_multiply, to: binaryfunc.self),
            nb_inplace_remainder: unsafeBitCast(nb_inplace_remainder, to: binaryfunc.self),
            nb_inplace_power: unsafeBitCast(nb_inplace_power, to: ternaryfunc.self),
            nb_inplace_lshift: unsafeBitCast(nb_inplace_lshift, to: binaryfunc.self),
            nb_inplace_rshift: unsafeBitCast(nb_inplace_rshift, to: binaryfunc.self),
            nb_inplace_and: unsafeBitCast(nb_inplace_and, to: binaryfunc.self),
            nb_inplace_xor: unsafeBitCast(nb_inplace_xor, to: binaryfunc.self),
            nb_inplace_or: unsafeBitCast(nb_inplace_or, to: binaryfunc.self),
            nb_floor_divide: unsafeBitCast(nb_floor_divide, to: binaryfunc.self),
            nb_true_divide: unsafeBitCast(nb_true_divide, to: binaryfunc.self),
            nb_inplace_floor_divide: unsafeBitCast(nb_inplace_floor_divide, to: binaryfunc.self),
            nb_inplace_true_divide: unsafeBitCast(nb_inplace_true_divide, to: binaryfunc.self),
            nb_index: unsafeBitCast(nb_index, to: unaryfunc.self),
            nb_matrix_multiply: unsafeBitCast(nb_matrix_multiply, to: binaryfunc.self),
            nb_inplace_matrix_multiply: unsafeBitCast(nb_inplace_matrix_multiply, to: binaryfunc.self)
        )
    }
}

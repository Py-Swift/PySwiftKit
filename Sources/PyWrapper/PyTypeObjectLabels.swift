//
//  PyTypeObjectLabels.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//




import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public enum PyTypeObjectLabels: String, CaseIterable {
	case ob_base
	case tp_name
	case tp_basicsize
	case tp_itemsize
	case tp_dealloc
	case tp_vectorcall_offset
	case tp_getattr
	case tp_setattr
	case tp_as_async
	case tp_repr
	case tp_as_number
	case tp_as_sequence
	case tp_as_mapping
	case tp_hash
	case tp_call
	case tp_str
	case tp_getattro
	case tp_setattro
	case tp_as_buffer
	case tp_flags
	case tp_doc
	case tp_traverse
	case tp_clear
	case tp_richcompare
	case tp_weaklistoffset
	case tp_iter
	case tp_iternext
	case tp_methods
	case tp_members
	case tp_getset
	case tp_base
	case tp_dict
	case tp_descr_get
	case tp_descr_set
	case tp_dictoffset
	case tp_init
	case tp_alloc
	case tp_new
	case tp_free
	case tp_is_gc
	case tp_bases
	case tp_mro
	case tp_cache
	case tp_subclasses
	case tp_weaklist
	case tp_del
	case tp_version_tag
	case tp_finalize
	case tp_vectorcall
	
}



struct PyTypeSlot {
	let slot: String
	let type: PyType_typedefs
	let special_methods: [PyOverLoads]
}

enum PyOverLoads: String, CaseIterable {
	case __await__, __aiter__, __anext__
	case __add__
	case __radd__
	case __iadd__
	case __sub__
	case __rsub__
	case __isub__
	case __mul__
	case __rmul__
	case __imul__
	case __mod__
	case __rmod__
	case __imod__
	case __divmod__
	case __rdivmod__
	case __pow__
	case __rpow__
	case __ipow__
	case __neg__
	case __pos__
	case __abs__
	case __bool__
	case __invert__
	case __lshift__
	case __rlshift__
	case __ilshift__
	case __rshift__
	case __rrshift__
	case __irshift__
	case __and__
	case __rand__
	case __iand__
	case __xor__
	case __rxor__
	case __ixor__
	case __or__
	case __ror__
	case __ior__
	case __int__
	case __float__
	case __floordiv__
	case __ifloordiv__
	case __truediv__
	case __itruediv__
	case __index__
	case __matmul__
	case __rmatmul__
	case __imatmul__
	case __len__
	case __iter__
	case __next__
	case __getitem__, __setitem__, __delitem__
	case __contains__, __reversed__
	// mapping
	case keys, items, values
	
	case __buffer__
}

extension PyTypeSlot {
	
	static let am_await = PyTypeSlot(slot: "am_wait", type: .unaryfunc, special_methods: [.__await__])
	static let am_aiter = PyTypeSlot(slot: "am_aiter", type: .unaryfunc, special_methods: [.__aiter__])
	static let am_anext = PyTypeSlot(slot: "am_anext", type: .unaryfunc, special_methods: [.__anext__])
	static let am_send = PyTypeSlot(slot: "am_send", type: .unaryfunc, special_methods: [])
	static let nb_add = PyTypeSlot(slot: "nb_add", type: .unaryfunc, special_methods: [.__add__])
	static let nb_inplace_add = PyTypeSlot(slot: "nb_inplace_add", type: .unaryfunc, special_methods: [.__iadd__])
	static let nb_subtract = PyTypeSlot(slot: "nb_subtract", type: .unaryfunc, special_methods: [.__sub__])
	static let nb_inplace_subtract = PyTypeSlot(slot: "nb_inplace_subtract", type: .unaryfunc, special_methods: [.__isub__])
	static let nb_multiply = PyTypeSlot(slot: "nb_multiply", type: .unaryfunc, special_methods: [.__mul__])
	static let nb_inplace_multiply = PyTypeSlot(slot: "nb_inplace_multiply", type: .unaryfunc, special_methods: [.__imul__])
	static let nb_remainder = PyTypeSlot(slot: "nb_remainder", type: .unaryfunc, special_methods: [.__mod__, .__rmod__])
	static let nb_inplace_remainder = PyTypeSlot(slot: "nb_inplace_remainder", type: .unaryfunc, special_methods: [.__imod__])
	//static let am_await = PyTypeSlot(slot: "am_wait", type: .unaryfunc, special_methods: [])
	//static let am_await = PyTypeSlot(slot: "am_wait", type: .unaryfunc, special_methods: [])
	//static let am_await = PyTypeSlot(slot: "am_wait", type: .unaryfunc, special_methods: [])
	
}


extension PyTypeObjectLabels {
    //var nilLabel: LabeledExprSyntax { .init(label: rawValue, nilOrExpression: nil)}
    func asLabeledExpr(_ expression: ExprSyntaxProtocol?, newline: Bool = true) -> LabeledExprSyntax {
        
        if newline {
            return .init(label: rawValue, expression: ExprSyntax(nilOrExpression: expression)).newLineTab
        }
        return .init(label: rawValue, expression: ExprSyntax(nilOrExpression: expression))
        
        
    }
}

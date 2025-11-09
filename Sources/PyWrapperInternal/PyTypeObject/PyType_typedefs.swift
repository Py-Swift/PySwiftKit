
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

enum PyType_typedefs: String, CaseIterable {
	case allocfunc
	case destructor
	case freefunc
	case traverseproc
	case newfunc
	case initproc
	case reprfunc
	case getattrfunc
	case setattrfunc
	case getattrofunc
	case setattrofunc
	case descrgetfunc
	case descrsetfunc
	case hashfunc
	case richcmpfunc
	case getiterfunc
	case iternextfunc
	case lenfunc
	case getbufferproc
	case releasebufferproc
	case inquiry
	case unaryfunc
	case binaryfunc
	case ternaryfunc
	case ssizeargfunc
	case ssizeobjargproc
	case objobjproc
	case objobjargproc
	case sendfunc
	case void
}


extension PyType_typedefs {
	var exprSyntax: ExprSyntax {
		var closure: String {
			switch self {
			case .allocfunc:
			return _allocfunc_
			case .destructor: return _destructor_
			case .freefunc: return _freefunc_
			case .traverseproc: return _traverseproc_
			case .newfunc: return _newfunc_
			case .initproc: return _initproc_
			case .reprfunc: return _reprfunc_
			case .getattrfunc: return _getattrfunc_
			case .setattrfunc: return _setattrfunc_
			case .getattrofunc: return _getattrofunc_
			case .setattrofunc: return _setattrofunc_
			case .descrgetfunc: return _descrgetfunc_
			case .descrsetfunc: return _descrsetfunc_
			case .hashfunc: return _hashfunc_
			case .richcmpfunc: return _richcmpfunc_
			case .getiterfunc: return _getiterfunc_
			case .iternextfunc: return _iternextfunc_
			case .lenfunc: return _lenfunc_
			case .getbufferproc: return _getbufferproc_
			case .releasebufferproc: return _releasebufferproc_
			case .inquiry: return _inquiry_
			case .unaryfunc: return _unaryfunc_
			case .binaryfunc: return _binaryfunc_
			case .ternaryfunc: return _ternaryfunc_
			case .ssizeargfunc: return _ssizeargfunc_
			case .ssizeobjargproc: return _ssizeobjargproc_
			case .objobjproc: return _objobjproc_
			case .objobjargproc: return _objobjargproc_
			case .sendfunc: return _sendfunc_
			case .void: return _voidfunc_
			}
		}
		return ExprSyntax(stringLiteral: closure)
	}
	
	var closureExpr: ClosureExprSyntax { self.exprSyntax.as(ClosureExprSyntax.self)! }
}
func getTypeDefClosure(_ t: PyType_typedefs) -> ClosureExprSyntax {
	t.closureExpr
}


// allocfunc (PyTypeObject *, Py_ssize_t) -> PyObject *
fileprivate let  _allocfunc_ = """
{ type, size -> PyPointer? in
}
"""
// destructor (PyObject *) -> void
fileprivate let _destructor_ = """
{ s in
}
"""
// freefunc (void *) -> void
fileprivate let _freefunc_ = """
{ raw in
}
"""
// traverseproc (PyObject *, visitproc, void *) -> int
fileprivate let  _traverseproc_ = """
{ s, visit, raw -> Int32 in
}
"""
// newfunc (PyObject *, PyObject *, PyObject *) -> PyObject *
fileprivate let  _newfunc_ = """
{ s, args, kw -> PyPointer? in
}
"""

// initproc PyObject *, PyObject *, PyObject * -> int
fileprivate let  _initproc_ = """
{ s, args, kw -> Int32 in
}
"""
// reprfunc (PyObject *) -> PyObject *
fileprivate let  _reprfunc_ = """
{ s -> PyPointer? in
}
"""

// getattrfunc (PyObject *, const char *) -> PyObject *
fileprivate let  _getattrfunc_ = """
{ s, key -> PyPointer? in
}
"""

// setattrfunc (PyObject * const char * PyObject *) -> int
fileprivate let  _setattrfunc_ = """
{ s, key, v -> Int32 in
}
"""

// getattrofunc (PyObject *, PyObject *) -> PyObject *
fileprivate let  _getattrofunc_ = """
{ s, key -> PyPointer? in
}
"""

// setattrofunc (PyObject *, PyObject *, PyObject *) -> int
fileprivate let  _setattrofunc_ = """
{ s, key, v -> Int32 in
}
"""

// descrgetfunc (PyObject *, PyObject *, PyObject *) -> PyObject *
fileprivate let  _descrgetfunc_ = """
{ s, x, y -> PyPointer? in
}
"""

// descrsetfunc (PyObject *, PyObject *, PyObject *) -> int
fileprivate let  _descrsetfunc_ = """
{ s, k, v -> Int32 in
}
"""

// hashfunc (PyObject *) -> Py_hash_t
fileprivate let  _hashfunc_ = """
{ s -> Int in
}
"""

// richcmpfunc (PyObject *, PyObject *, int) -> PyObject *
fileprivate let  _richcmpfunc_ = """
{ l, r, cmp -> PyPointer? in
}
"""

// getiterfunc (PyObject *) -> PyObject *
fileprivate let  _getiterfunc_ = """
{ s -> PyPointer? in
}
"""

// iternextfunc (PyObject *) -> PyObject *
fileprivate let  _iternextfunc_ = """
{ s -> PyPointer? in
}
"""

// lenfunc (PyObject *) -> Py_ssize_t
fileprivate let  _lenfunc_ = """
{ s in
}
"""

// getbufferproc (PyObject, * Py_buffer *, int) -> int
fileprivate let  _getbufferproc_ = """
{ s, buffer, size -> Int32 in
}
"""

// releasebufferproc (PyObject *, Py_buffer *) -> void
fileprivate let  _releasebufferproc_ = """
{ s, buffer -> Void in
}
"""

// inquiry (PyObject *) -> int
fileprivate let  _inquiry_ = """
{ s -> Int32 in
}
"""

// unaryfunc (PyObject *) -> PyObject *
fileprivate let  _unaryfunc_ = """
{ s -> PyPointer? in
}
"""

// binaryfunc (PyObject *, PyObject *) -> PyObject *
fileprivate let  _binaryfunc_ = """
{ s, o -> PyPointer? in
}
"""

// ternaryfunc (PyObject *, PyObject *, PyObject *) -> PyObject *
fileprivate let  _ternaryfunc_ = """
{ s, o, kw -> PyPointer? in
}
"""

// ssizeargfunc (PyObject *, Py_ssize_t) -> PyObject *
fileprivate let  _ssizeargfunc_ = """
{ s, i -> PyPointer? in
}
"""

// ssizeobjargproc (PyObject *, Py_ssize_t, PyObject *) -> int
fileprivate let  _ssizeobjargproc_ = """
{ s, i, o -> Int32 in
}
"""

// objobjproc (PyObject *, PyObject *) -> int
fileprivate let  _objobjproc_ = """
{ s, x -> Int32 in
}
"""

// objobjargproc (PyObject *, PyObject *, PyObject *) -> int
fileprivate let  _objobjargproc_ = """
{ s, x, y -> Int32 in
}
"""

// am_send (UnsafeMutablePointer<PyObject>?, UnsafeMutablePointer<PyObject>?, UnsafeMutablePointer<UnsafeMutablePointer<PyObject>?>?) -> PySendResult
fileprivate let _sendfunc_ = """
{ s, args , kw  in
}
"""

fileprivate let _voidfunc_ = """
{ _ in
}
"""

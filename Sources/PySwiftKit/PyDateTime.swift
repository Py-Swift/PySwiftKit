////
////  PyDateTime.swift
////  PySwiftKit
////
//import CPython
//
//fileprivate var pydatetime_loaded = false
//
//public func ensurePyDateTime() {
//    if pydatetime_loaded { return }
//    initPyDateTime()
//    pydatetime_loaded.toggle()
//}
//
//let ___PyDateTime = {
//    guard let datetime_module = PyImport_ImportModule("datetime") else {
//        PyErr_Print()
//        fatalError()
//    }
//    pyPrint(datetime_module)
//    let datetime = PyObject_GetAttrString(datetime_module, "datetime")
//    assert(datetime != nil)
//    return datetime!
//}()
//
//public func PyDateTime_new(
//    year: Int,
//    month: Int,
//    day: Int,
//    hour: Int?,
//    minute: Int?,
//    second: Int?,
//    microsecond: Int?
//) throws -> PyPointer {
//    
//    guard
//        let py_year = PyLong_FromLong(year),
//        let py_month = PyLong_FromLong(month),
//        let py_day = PyLong_FromLong(day),
//        let py_hour = PyLong_FromLong(hour ?? 0),
//        let py_minute = PyLong_FromLong(minute ?? 0),
//        let py_second = PyLong_FromLong(second ?? 0),
//        let py_microsecond = PyLong_FromLong(microsecond ?? 0),
//        let pydatetime = PyObject_Vectorcall(___PyDateTime, [py_year, py_month, py_day, py_hour, py_minute, py_second, py_microsecond], 7, nil)
//    else {
//        PyErr_Print()
//        fatalError()
//    }
//    
//    Py_DecRef(py_year)
//    Py_DecRef(py_month)
//    Py_DecRef(py_day)
//    Py_DecRef(py_hour)
//    Py_DecRef(py_minute)
//    Py_DecRef(py_microsecond)
//    
//    return pydatetime
//}
//

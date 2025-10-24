//
//  PyStandardException.swift
//  PySwiftKit
//
//  Created by CodeBuilder on 24/10/2025.
//
import CPython

public enum PyStandardException: PyException {
    case arithmeticError
    case assertionError
    case attributeError
    case baseException
    case baseExceptionGroup
    case blockingIOError
    case brokenPipeError
    case bufferError
    case bytesWarning
    case childProcessError
    case connectionAbortedError
    case connectionError
    case connectionRefusedError
    case connectionResetError
    case deprecationWarning
    case eofError
    case encodingWarning
    case environmentError
    case exception
    case fileExistsError
    case fileNotFoundError
    case floatingPointError
    case futureWarning
    case generatorExit
    case ioError
    case importError
    case importWarning
    case indentationError
    case indexError
    case interruptedError
    case isADirectoryError
    case keyError
    case keyboardInterrupt
    case lookupError
    case memoryError
    case moduleNotFoundError
    case nameError
    case notADirectoryError
    case notImplementedError
    case osError
    case overflowError
    case pendingDeprecationWarning
    case permissionError
    case processLookupError
    case recursionError
    case referenceError
    case resourceWarning
    case runtimeError
    case runtimeWarning
    case stopAsyncIteration
    case stopIteration
    case syntaxError
    case syntaxWarning
    case systemError
    case systemExit
    case tabError
    case timeoutError
    case typeError
    case unboundLocalError
    case unicodeDecodeError
    case unicodeEncodeError
    case unicodeError
    case unicodeTranslateError
    case unicodeWarning
    case userWarning
    case valueError
    case warning
    case windowsError
    case zeroDivisionError
    
    public func pyException() -> PyPointer {
        getPyException(type: self)
    }
}


public func handlePyException(type: PyPointer) -> PyStandardException? {
    switch type {
    case PyExc_ArithmeticError: return .arithmeticError
    case PyExc_AssertionError: return .assertionError
    case PyExc_AttributeError: return .attributeError
    case PyExc_BaseException: return .baseException
    case PyExc_BaseExceptionGroup: return .baseExceptionGroup
    case PyExc_BlockingIOError: return .blockingIOError
    case PyExc_BrokenPipeError: return .brokenPipeError
    case PyExc_BufferError: return .bufferError
    case PyExc_BytesWarning: return .bytesWarning
    case PyExc_ChildProcessError: return .childProcessError
    case PyExc_ConnectionAbortedError: return .connectionAbortedError
    case PyExc_ConnectionError: return .connectionError
    case PyExc_ConnectionRefusedError: return .connectionRefusedError
    case PyExc_ConnectionResetError: return .connectionResetError
    case PyExc_DeprecationWarning: return .deprecationWarning
    case PyExc_EOFError: return .eofError
    case PyExc_EncodingWarning: return .encodingWarning
    case PyExc_EnvironmentError: return .environmentError
    case PyExc_Exception: return .exception
    case PyExc_FileExistsError: return .fileExistsError
    case PyExc_FileNotFoundError: return .fileNotFoundError
    case PyExc_FloatingPointError: return .floatingPointError
    case PyExc_FutureWarning: return .futureWarning
    case PyExc_GeneratorExit: return .generatorExit
    case PyExc_IOError: return .ioError
    case PyExc_ImportError: return .importError
    case PyExc_ImportWarning: return .importWarning
    case PyExc_IndentationError: return .indentationError
    case PyExc_IndexError: return .indexError
    case PyExc_InterruptedError: return .interruptedError
    case PyExc_IsADirectoryError: return .isADirectoryError
    case PyExc_KeyError: return .keyError
    case PyExc_KeyboardInterrupt: return .keyboardInterrupt
    case PyExc_LookupError: return .lookupError
    case PyExc_MemoryError: return .memoryError
    case PyExc_ModuleNotFoundError: return .moduleNotFoundError
    case PyExc_NameError: return .nameError
    case PyExc_NotADirectoryError: return .notADirectoryError
    case PyExc_NotImplementedError: return .notImplementedError
    case PyExc_OSError: return .osError
    case PyExc_OverflowError: return .overflowError
    case PyExc_PendingDeprecationWarning: return .pendingDeprecationWarning
    case PyExc_PermissionError: return .permissionError
    case PyExc_ProcessLookupError: return .processLookupError
    case PyExc_RecursionError: return .recursionError
    case PyExc_ReferenceError: return .referenceError
    case PyExc_ResourceWarning: return .resourceWarning
    case PyExc_RuntimeError: return .runtimeError
    case PyExc_RuntimeWarning: return .runtimeWarning
    case PyExc_StopAsyncIteration: return .stopAsyncIteration
    case PyExc_StopIteration: return .stopIteration
    case PyExc_SyntaxError: return .syntaxError
    case PyExc_SyntaxWarning: return .syntaxWarning
    case PyExc_SystemError: return .systemError
    case PyExc_SystemExit: return .systemExit
    case PyExc_TabError: return .tabError
    case PyExc_TimeoutError: return .timeoutError
    case PyExc_TypeError: return .typeError
    case PyExc_UnboundLocalError: return .unboundLocalError
    case PyExc_UnicodeDecodeError: return .unicodeDecodeError
    case PyExc_UnicodeEncodeError: return .unicodeEncodeError
    case PyExc_UnicodeError: return .unicodeError
    case PyExc_UnicodeTranslateError: return .unicodeTranslateError
    case PyExc_UnicodeWarning: return .unicodeWarning
    case PyExc_UserWarning: return .userWarning
    case PyExc_ValueError: return .valueError
    case PyExc_Warning: return .warning
        //case PyExc_WindowsError: return .windowsError
    case PyExc_ZeroDivisionError: return .zeroDivisionError
    default: return nil
    }
}

public func getPyException(type: PyStandardException) -> PyPointer {
    switch type {
    case .arithmeticError: PyExc_ArithmeticError
    case .assertionError: PyExc_AssertionError
    case .attributeError: PyExc_AttributeError
    case .baseException: PyExc_BaseException
    case .baseExceptionGroup: PyExc_BaseExceptionGroup
    case .blockingIOError: PyExc_BlockingIOError
    case .brokenPipeError: PyExc_BrokenPipeError
    case .bufferError: PyExc_BufferError
    case .bytesWarning: PyExc_BytesWarning
    case .childProcessError: PyExc_ChildProcessError
    case .connectionAbortedError: PyExc_ConnectionAbortedError
    case .connectionError: PyExc_ConnectionError
    case .connectionRefusedError: PyExc_ConnectionRefusedError
    case .connectionResetError: PyExc_ConnectionResetError
    case .deprecationWarning: PyExc_DeprecationWarning
    case .eofError: PyExc_EOFError
    case .encodingWarning: PyExc_EncodingWarning
    case .environmentError: PyExc_EnvironmentError
    case .exception: PyExc_Exception
    case .fileExistsError: PyExc_FileExistsError
    case .fileNotFoundError: PyExc_FileNotFoundError
    case .floatingPointError: PyExc_FloatingPointError
    case .futureWarning: PyExc_FutureWarning
    case .generatorExit: PyExc_GeneratorExit
    case .ioError: PyExc_IOError
    case .importError: PyExc_ImportError
    case .importWarning: PyExc_ImportWarning
    case .indentationError: PyExc_IndentationError
    case .indexError: PyExc_IndexError
    case .interruptedError: PyExc_InterruptedError
    case .isADirectoryError: PyExc_IsADirectoryError
    case .keyError: PyExc_KeyError
    case .keyboardInterrupt: PyExc_KeyboardInterrupt
    case .lookupError: PyExc_LookupError
    case .memoryError: PyExc_MemoryError
    case .moduleNotFoundError: PyExc_ModuleNotFoundError
    case .nameError: PyExc_NameError
    case .notADirectoryError: PyExc_NotADirectoryError
    case .notImplementedError: PyExc_NotImplementedError
    case .osError: PyExc_OSError
    case .overflowError: PyExc_OverflowError
    case .pendingDeprecationWarning: PyExc_PendingDeprecationWarning
    case .permissionError: PyExc_PermissionError
    case .processLookupError: PyExc_ProcessLookupError
    case .recursionError: PyExc_RecursionError
    case .referenceError: PyExc_ReferenceError
    case .resourceWarning: PyExc_ResourceWarning
    case .runtimeError: PyExc_RuntimeError
    case .runtimeWarning: PyExc_RuntimeWarning
    case .stopAsyncIteration: PyExc_StopAsyncIteration
    case .stopIteration: PyExc_StopIteration
    case .syntaxError: PyExc_SyntaxError
    case .syntaxWarning: PyExc_SyntaxWarning
    case .systemError: PyExc_SystemError
    case .systemExit: PyExc_SystemExit
    case .tabError: PyExc_TabError
    case .timeoutError: PyExc_TimeoutError
    case .typeError: PyExc_TypeError
    case .unboundLocalError: PyExc_UnboundLocalError
    case .unicodeDecodeError: PyExc_UnicodeDecodeError
    case .unicodeEncodeError: PyExc_UnicodeEncodeError
    case .unicodeError: PyExc_UnicodeError
    case .unicodeTranslateError: PyExc_UnicodeTranslateError
    case .unicodeWarning: PyExc_UnicodeWarning
    case .userWarning: PyExc_UserWarning
    case .valueError: PyExc_ValueError
    case .warning: PyExc_Warning
    case .windowsError: PyExc_Exception
    case .zeroDivisionError: PyExc_ZeroDivisionError
    }
}

public func setPyException(type: PyStandardException, message: String) {
    message.withCString { text in
        PyErr_SetString(getPyException(type: type), text)
    }
}

let swiftException = PyErr_NewException("SwiftError", nil, nil)

public extension Error {
    func anyErrorException() {
        localizedDescription.withCString { text in
            PyErr_SetString(swiftException, text)
        }
    }
}

public extension PyStandardException {
    func setException(_ msg: String) {
        setPyException(type: self, message: msg)
    }
}


@_exported 
import PythonCore



public enum PySendResultFlag: Int32 {
	case RETURN = 0
	case ERROR = -1
	case NEXT = 1
}

public extension PySendResultFlag {
	func result() -> PySendResult {
		.init(rawValue)
	}
}

public extension Int32 {
	static let FALSE: Self = 0
	static let TRUE: Self = 1
}

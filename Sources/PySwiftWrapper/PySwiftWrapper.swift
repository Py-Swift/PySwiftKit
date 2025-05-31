import Foundation
import PyWrapperInfo
import PySerializing

@attached(peer, names: arbitrary)
public macro PyFunction(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")

@attached(member, names: arbitrary)
@attached(extension, names: arbitrary)
public macro PyModule(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftModuleGenerator")

@attached(
    peer,
    names:
        suffixed(_tp_new),
        suffixed(_tp_init),
        suffixed(_tp_dealloc),
        suffixed(_tp_hash),
        suffixed(_tp_str),
        suffixed(_tp_repr),
        suffixed(_tp_as_async),
        suffixed(_tp_as_sequence),
        suffixed(_tp_as_mapping),
        suffixed(_tp_as_number),
        suffixed(_tp_as_buffer),
        suffixed(_buffer_procs),
        suffixed(_PyMethodDefs),
        suffixed(_PyGetSetDefs),
        suffixed(_PyType),
        suffixed(_pyTypeObject)
)
@attached(member, names: arbitrary)
@attached(
    extension,
    conformances:
        PyClassProtocol,
    names: arbitrary
)
@attached(memberAttribute)
public macro PyClass(name: String? = nil, unretained: Bool = false, bases: [PyClassBase] = [], external: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")

@attached(member, names: arbitrary)
public macro PyClassByExtension(name: String? = nil, unretained: Bool = false, bases: [PyClassBase] = [], expr: String? = nil, external: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")


@attached(peer)
public macro PyInit() = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")

@attached(peer)
public macro PyProperty(readonly: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")

@attached(peer)
public macro PyPropertyEx(expr: String, readonly: Bool = false, target: AnyObject.Type) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")


@attached(peer)
public macro PyMethod(kwargs: Kwargs = .none) = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")

@freestanding(declaration, names: arbitrary)
public macro PyWrapCode(expr: String, target: AnyObject.Type) = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")


@attached(peer, names: arbitrary)
public macro PyStaticMethod(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")

@attached(member, names: arbitrary)
public macro ImportableModules(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")


@attached(body)
public macro PyCall(name: String? = nil, gil: Bool = true, method: Bool = false, cast_options: [ArgumentCast] = []) = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

@attached(member, names: arbitrary)
public macro PyCallback(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PyCallbackGenerator")

@attached(member, names: arbitrary)
@attached(
    extension,
    conformances:
        PyDeserialize,
    names: arbitrary
)
public macro PyContainer(name: String? = nil, weak_ref: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyContainerMacro")

@freestanding(expression)
public macro ExtractPySwiftObject() = #externalMacro(module: "PySwiftGenerators", type: "ExtractPySwiftObject")

@freestanding(expression)
public macro withNoGIL(code: @escaping () -> Void) = #externalMacro(module: "PySwiftGenerators", type: "AttachedTestMacro")



@freestanding(expression)
public macro PyListNew(_ elements: Any...) = #externalMacro(module: "PySwiftGenerators", type: "PyListGenerator")


public protocol PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [PyModuleProtocol] { get }
}

public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [PyModuleProtocol] { [] }
}

public protocol PyClassProtocol {
    
}

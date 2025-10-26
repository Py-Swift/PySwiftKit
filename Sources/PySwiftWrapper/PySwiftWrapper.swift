//
//  PySwiftWrapper.swift
//  PySwiftKit
//
import Foundation
import PyWrapperInfo
import PySerializing
import PySwiftKit
import PyProtocols
import CPython


@attached(peer)
public macro PyMethod(kwargs: Kwargs = .none) = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")

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
    suffixed(_pyTypeObject),
    named(shared)
)

@attached(member, names: arbitrary)
@attached(
    extension,
    conformances:
        PyClassProtocol,
    names: arbitrary
)

@attached(memberAttribute)
public macro PyClass(
    name: String? = nil,
    unretained: Bool = false,
    bases: [PyClassBase] = [],
    base_type: PyClassBaseType = .none,
    external: Bool = false
) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")

@attached(member, names: arbitrary)
public macro PyClassByExtension(
    name: String? = nil,
    unretained: Bool = false,
    bases: [PyClassBase] = [],
    expr: String? = nil,
    external: Bool = false
) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")


@attached(peer)
public macro PyInit() = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")

@attached(peer)
public macro PyProperty(readonly: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")


public macro PyContainer(name: String? = nil, weak_ref: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyContainerMacro")

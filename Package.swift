// swift-tools-version: 6.2
import Foundation
import PackageDescription

let env = ProcessInfo.processInfo.environment

let local = false
let localGenerators = false
let dev_mode = true

let pipMode   = env["PIP_MODE"] == "1"
let isAndroid = env["SWIFT_ANDROID_HOME"] != nil

let CPython: Package.Dependency = if local {
    .package(path: "../CPython")
} else {
    .package(url: "https://github.com/py-swift/CPython", .upToNextMajor(from: .init(313, 8, 0)))
}

var platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v11)
]

let PySwiftGenerators: Package.Dependency = localGenerators
    ? .package(path: "../PySwiftGenerators")
    : .package(url: "https://github.com/Py-Swift/PySwiftGenerators", from: "0.0.12")

// When pyswiftkit-builder sets PYSWIFTGENERATORS_TOOL (pip/cibuildwheel only),
// inject -load-plugin-executable so the prebuilt binary is used instead of
// compiling swift-syntax. In all other contexts this is empty.
nonisolated(unsafe) let macroPluginFlags: [SwiftSetting] = {
    guard let tool = env["PYSWIFTGENERATORS_TOOL"], !tool.isEmpty else { return [] }
    return [.unsafeFlags(["-load-plugin-executable", "\(tool)#PySwiftGenerators"])]
}()

let dependencies: [Package.Dependency] = [
    CPython,
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    PySwiftGenerators,
]

func package_targets() -> [Target] {
    [
        .target(
            name: "CPySwiftObject",
            dependencies: ["CPython"],
            path: "Sources/CPySwiftObject",
            publicHeadersPath: ".",
            cSettings: pipMode && isAndroid ? [.define("PIP_MODE")] : [],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PySerializing",
            dependencies: ["CPython", "PySwiftKit"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PySwiftKit",
            dependencies: [
                .product(name: "CPython", package: "CPython"),
                "CPySwiftObject",
                "PyProtocols"
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PySwiftConcurrency",
            dependencies: [
                .product(name: "CPython", package: "CPython"),
                "CPySwiftObject",
                "PyProtocols"
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PyProtocols",
            dependencies: ["CPython"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PySwiftWrapper",
            dependencies: [
                .product(name: "PyWrapperInfo", package: "PySwiftGenerators"),
                "CPython",
                "PySerializing",
                "PyProtocols",
                .product(name: "PySwiftGenerators", package: "PySwiftGenerators"),
            ],
            swiftSettings: macroPluginFlags + [.swiftLanguageMode(.v5)]
        ),
    ]
}

func get_targets() -> [Target] {
    var targets = package_targets()
    add_test_targets(&targets)
    return targets
}

func add_test_targets(_ targets: inout [Target]) {
    targets.append(.testTarget(
        name: "PyTests",
        dependencies: ["CPython", "PySwiftKit", "PySerializing", "PySwiftWrapper"],
        resources: [.copy("python3.13"), .copy("pyswiftwrapper_tests.py")],
        swiftSettings: [.swiftLanguageMode(.v5)]
    ))
}

func get_products() -> [Product] {
    var products = [Product]()
    products.add_library("PySerializing")
    products.add_library("PySwiftWrapper")
    products.add_library("PySwiftKitBase", targets: ["PySwiftKit", "PySerializing", "PySwiftWrapper"])
    products.add_library("PySwiftKit", targets: ["PySwiftKit", "PySerializing", "PySwiftWrapper"], type: .dynamic)
    return products
}

let package = Package(
    name: "PySwiftKit",
    platforms: platforms,
    products: get_products(),
    dependencies: dependencies,
    targets: get_targets()
)

extension Array where Element == Product {
    mutating func add_library(_ name: String, targets: [String], type: Product.Library.LibraryType? = nil) {
        append(.library(name: name, type: type, targets: targets))
    }
    mutating func add_library(_ name: String, type: Product.Library.LibraryType? = nil) {
        add_library(name, targets: [name], type: type)
    }
}

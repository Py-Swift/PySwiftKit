// swift-tools-version: 6.2
import Foundation
import PackageDescription
import CompilerPluginSupport

let env = ProcessInfo.processInfo.environment

let local = false
let localGenerators = true
let dev_mode = true

enum PythonMode {
    case pip
    case android
    case development
    case normal
    
    static let shared = Self.current()
    
    static func current() -> Self {
        if env["PIP_MODE"] == "1" { return .pip }
        if env["PSK_DEVELOPMENT"] == "1" { return .development }
        if env["SWIFT_ANDROID_HOME"] != nil { return .android }
        return .normal
    }
    
    var cSettings: [CSetting] {
        switch self {
        case .pip:
            [.define("PIP_MODE")]
        case .android:
            [.define("PIP_MODE")]
        case .development:
            []
        case .normal:
            []
        }
    }
    
    var linkerSettings: [LinkerSetting] {
        switch self {
        case .pip:
            []
        case .android:
            []
        case .development:
            []
        case .normal:
            [.linkedFramework("Python")]
        }
    }
}

let pipMode   = env["PIP_MODE"] == "1"
let frameworkMode = env["FRAMEWORK_MODE"] == "1"
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
    : .package(url: "https://github.com/Py-Swift/PySwiftGenerators", from: "0.0.0")

let dependencies: [Package.Dependency] = [
    CPython,
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    //PySwiftGenerators,
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
]

func package_targets() -> [Target] {
    [
        .target(
            name: "CPySwiftObject",
            dependencies: ["CPython"],
            path: "Sources/CPySwiftObject",
            publicHeadersPath: ".",
            cSettings: PythonMode.shared.cSettings,
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
                "PyProtocols",
                "PyWrapperInfo"
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
            name: "PyWrapperInfo",
            dependencies: [],
            path: "Sources/PyWrapperInfo",
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
                "PyWrapperInfo",
                "CPython",
                "PySerializing",
                "PyProtocols",
                "PySwiftGenerators"
                //.product(name: "PySwiftGenerators", package: "PySwiftGenerators"),
                //.product(name: "SwiftSyntaxWrapper", package: "PySwiftGenerators"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PyWrapperInternal",
            dependencies: [
                //"SwiftSyntaxWrapper",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "PyWrapperInfo",
            ],
        ),
        .macro(
            name: "PySwiftGenerators",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                //"SwiftSyntaxWrapper",
                "PyWrapperInfo",
                "PyWrapperInternal",
            ],
            //swiftSettings: swift_settings
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
    products.add_library("PySwiftKitStatic", targets: ["PySwiftKit", "PySerializing", "PySwiftWrapper"])
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
